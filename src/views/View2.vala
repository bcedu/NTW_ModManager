using App.Controllers;
using Gtk;
namespace App.Views {

    public class View2 : AppView, VBox {

        private ScrolledWindow mods_list;
        private Gtk.Button install_mods_btn;
        private Gtk.Button refresh_mods_btn;

        public View2 (AppController controler) {
            Gtk.Box title_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

            Gtk.Label title = new Gtk.Label (_("Mods List"));
            title.get_style_context ().add_class ("h4");
            title.halign = Gtk.Align.CENTER;
            title_box.pack_start (title, true, true, 10);

            this.refresh_mods_btn = new Gtk.Button.from_icon_name ("view-refresh", Gtk.IconSize.BUTTON);
            title_box.pack_end (this.refresh_mods_btn, false, false, 10);

            this.pack_start (title_box, false, false, 10);

            mods_list = this.init_mods_list(controler);
            this.pack_start (mods_list, true, true, 10);

            install_mods_btn = new Gtk.Button.with_label("Install/uninstall selected mods");
            this.pack_start (install_mods_btn, false, false, 10);


            this.get_style_context().add_class ("app_view");
            this.show_all();
        }

        private ScrolledWindow init_mods_list(AppController c) {
            return c.modmanager.get_ui();
        }

        public string get_id() {
            return "view2";
        }

        public void connect_signals(AppController controler) {
            install_mods_btn.clicked.connect(() => {
                controler.modmanager.update_installed_mods();
                this.update_view(controler);
            });
            refresh_mods_btn.clicked.connect(() => {
                this.update_view(controler);
            });
        }

        public void update_view(AppController controler) {
            controler.update_modmanager();
        }


        public void update_view_on_hide(AppController controler) {
        }

    }

}
