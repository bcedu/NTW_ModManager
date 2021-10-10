using App.Controllers;
using Gtk;
using App.Widgets;

namespace App.Views {


    public class ViewConf : AppView, VBox {
        private Gtk.Button conf_button;

        private Gtk.Entry current_game_path;
        private Gtk.Button edit_current_game_path;

        private Gtk.Entry current_scripts_path;
        private Gtk.Button edit_current_scripts_path;


        public ViewConf (AppController controler) {
            conf_button = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON);
            conf_button.tooltip_text = _("Configuration");
            controler.window.headerbar.pack_end(conf_button);

            // Game path configurator
            Gtk.Label title = new Gtk.Label (_("Configuration"));
            title.get_style_context ().add_class ("h4");
            title.halign = Gtk.Align.CENTER;
            this.pack_start (title, false, false, 10);

            Box hbox = new Box(Orientation.HORIZONTAL, 0);
            this.pack_start (hbox, false, false, 10);

            Gtk.Label lb_current_game_path = new Gtk.Label(_("Total War game path:"));
            hbox.pack_start (lb_current_game_path, false, false, 10);

            current_game_path = new Gtk.Entry();
            current_game_path.editable = false;
            if (controler.modmanager != null) current_game_path.set_text(controler.modmanager.get_game_path());
            hbox.pack_start (current_game_path, true, true, 0);

            edit_current_game_path = new Gtk.Button.from_icon_name ("folder-new", Gtk.IconSize.BUTTON);
            hbox.pack_start (edit_current_game_path, false, false, 10);

            Box scripts_hbox = new Box(Orientation.HORIZONTAL, 0);
            this.pack_start (scripts_hbox, false, false, 10);

            Gtk.Label lb_current_scripts_path = new Gtk.Label(_("user.scripts.txt folder:"));
            scripts_hbox.pack_start (lb_current_scripts_path, false, false, 10);

            current_scripts_path = new Gtk.Entry();
            current_scripts_path.editable = false;
            if (controler.modmanager != null) current_scripts_path.set_text(controler.modmanager.get_user_script_path());
            scripts_hbox.pack_start (current_scripts_path, true, true, 0);

            edit_current_scripts_path = new Gtk.Button.from_icon_name ("folder-new", Gtk.IconSize.BUTTON);
            scripts_hbox.pack_start (edit_current_scripts_path, false, false, 10);

            this.show_all();
        }

        public string get_id() {
            return "view3";
        }

        public void connect_signals(AppController controler) {
            conf_button.clicked.connect(() => {
                if (controler.view_controller.get_current_view ().get_id () != "view3") {
                    controler.add_registered_view ("view3");
                }
            });
            edit_current_game_path.clicked.connect(() => {
                Gtk.FileChooserDialog file_chooser = new Gtk.FileChooserDialog (
                    _("Select the path where Total War game is installed"), controler.window, Gtk.FileChooserAction.SELECT_FOLDER, _("Cancel"),
                    Gtk.ResponseType.CANCEL, _("Open"), Gtk.ResponseType.ACCEPT
                );
                file_chooser.response.connect((response) => {
                    if (response == Gtk.ResponseType.ACCEPT) {
                        string dir_selected = "";
                        string? sel = file_chooser.get_filename ();
                        if (sel != null) {
                            dir_selected = sel;
                            controler.set_game_path(dir_selected);
                            this.update_view(controler);
                        }
                        file_chooser.destroy ();
                    } else {
                        file_chooser.destroy();
                    }
                });

                file_chooser.run ();
            });

            edit_current_scripts_path.clicked.connect(() => {
                Gtk.FileChooserDialog file_chooser = new Gtk.FileChooserDialog (
                    _("Select the folder where user.scripts.txt file is located"), controler.window, Gtk.FileChooserAction.SELECT_FOLDER, _("Cancel"),
                    Gtk.ResponseType.CANCEL, _("Open"), Gtk.ResponseType.ACCEPT
                );
                file_chooser.response.connect((response) => {
                    if (response == Gtk.ResponseType.ACCEPT) {
                        string dir_selected = "";
                        string? sel = file_chooser.get_filename ();
                        if (sel != null) {
                            dir_selected = sel;
                            controler.set_user_script_path(dir_selected);
                            this.update_view(controler);
                        }
                        file_chooser.destroy ();
                    } else {
                        file_chooser.destroy();
                    }
                });

                file_chooser.run ();
            });
        }

        public void update_view(AppController controler) {
            controler.window.headerbar.back_button.set_label (_("Back"));
            conf_button.visible = false;
            if (controler.modmanager != null) current_game_path.set_text(controler.modmanager.get_game_path());
            if (controler.modmanager != null) current_scripts_path.set_text(controler.modmanager.get_user_script_path());
        }

        public void update_view_on_hide(AppController controler) {
            conf_button.visible = true;
        }

    }

}

