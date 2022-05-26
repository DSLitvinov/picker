namespace Picker {
    public class Window : Hdy.ApplicationWindow {
        private Gtk.Button pick_button;
        private Picker.ColorArea color_area;
        private Picker.FormatArea format_area;
        private Picker.ColorController color_controller;

        public Window (Gtk.Application app) {
            Object (
                application: app
            );
        }

        construct {
            create_layout ();

            color_controller = ColorController.get_instance ();

            var color_picker = new ColorPicker ();

            pick_button.clicked.connect (() => {
                color_picker.show ();
            });

            delete_event.connect (() => {
                save_state_to_gsettings ();
            });

            load_state_from_gsettings ();
            load_css ();
        }

        private void create_layout () {
            Hdy.init ();
            var window_grid = new Gtk.Grid ();
            default_width = 480;
            default_height = 240;
            resizable = false;

            var headerbar = new Hdy.HeaderBar () {
                show_close_button = true,
                title = "Picker"
            };

            var header_style = headerbar.get_style_context ();
            header_style.add_class (Gtk.STYLE_CLASS_FLAT);

            var window_handle = new Hdy.WindowHandle ();
            window_handle.add (window_grid);

            color_area = new Picker.ColorArea ();

            var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10) {
                vexpand = true,
                valign = Gtk.Align.START,
                margin = 10,
            };

            pick_button = new Gtk.Button.with_label ("Pick Color");
            pick_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            var format_label = new Gtk.Label ("Format");
            format_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            format_label.xalign = 0;
            format_area = new Picker.FormatArea ();

            vbox.add (format_label);
            vbox.add (format_area);
            vbox.add (pick_button);

            window_grid.attach (headerbar, 0, 0);
            window_grid.attach (vbox, 0, 1);
            window_grid.attach (color_area, 1, 0, 1, 2);
            add (window_handle);
        }

        private void load_state_from_gsettings () {
            var settings = Settings.get_instance ();
            int pos_x, pos_y;
            settings.get ("position", "(ii)", out pos_x, out pos_y);
            move (pos_x, pos_y);

            color_controller.load_history_from_gsettings ();
            format_area.load_format_from_gsettings ();
        }

        private void save_state_to_gsettings () {
            var settings = Settings.get_instance ();
            int pos_x, pos_y;
            get_position (out pos_x, out pos_y);
            settings.set ("position", "(ii)", pos_x, pos_y);

            color_controller.save_history_to_gsettings ();
            format_area.save_format_to_gsettings ();
        }

        private void load_css () {
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/phoneybadger/picker/application.css");

            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }
    }
}
