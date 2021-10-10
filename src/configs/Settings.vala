namespace App.Configs {

    public class AppSettings : Granite.Services.Settings {

        // Window settings
        public int window_width { get; set; }
        public int window_height { get; set; }
        public int window_posx { get; set; }
        public int window_posy { get; set; }
        public int window_state { get; set; }

        // ModManager settings
        public string default_game_path { get; set; }
        public string default_user_script_path { get; set; }

        private static AppSettings _settings;

        public static unowned AppSettings get_default () throws Error {
            if (_settings == null) _settings = new AppSettings ();
            return _settings;
        }

        private AppSettings () throws Error {
            base ("com.github.bcedu.ntw3_hb_setup.settings");
        }
    }

}
