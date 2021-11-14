using App.Controllers;
using Gtk;

namespace App.Views {

    public class InitialView : AppView, VBox {

        private Granite.Widgets.Welcome welcome;
        private Gtk.FileChooserDialog file_chooser;
        private int open_index;

        public InitialView (AppController controler) {
            welcome = new Granite.Widgets.Welcome (_("Welcome"), _("This is your first run. You must set the path of Napoleon Total War"));
            this.pack_start (welcome, true, true, 0);

            welcome.margin_start = welcome.margin_end = 6;
            open_index = welcome.append ("folder-open", _("Set path"), _("Select the path where Napoleon Total War is installed"));

            this.get_style_context().add_class ("app_view");
            this.show_all();

            if (controler.modmanager != null) {
                print("\n"+"Modmanager no es null"+"\n");
                controler.set_registered_view("view2");
            }

            print("\n"+"Vista 1 començada!!!!"+"\n");
        }

        public string get_id() {
            return "init";
        }

        public void connect_signals (AppController controler) {
            // Connect welcome button activated
            this.welcome.activated.connect ((index) => {
                if (index == open_index) {
                    this.file_chooser = new Gtk.FileChooserDialog (
                        _("Select the path where Napoleon Total War is installed"), controler.window, Gtk.FileChooserAction.SELECT_FOLDER, _("Cancel"),
                        Gtk.ResponseType.CANCEL, _("Open"), Gtk.ResponseType.ACCEPT
                    );
                    this.file_chooser.response.connect((response) => {
                        if (response == Gtk.ResponseType.ACCEPT) {
                            string dir_selected = "";
                            string? sel = file_chooser.get_filename ();
                            if (sel != null) {
                                dir_selected = sel;
                                bool ok = controler.set_game_path(dir_selected);
                                if (ok) controler.set_registered_view("view2");
                            }
                            file_chooser.destroy ();
                        } else {
                            file_chooser.destroy();
                        }
                    });

                    file_chooser.run ();
                }
            });
        }

        public void update_view(AppController controler) {

        }

        public void update_view_on_hide(AppController controler) {
            this.update_view(controler);
        }

    }

}
