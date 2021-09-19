using App;

class TestNTW : Gee.TestCase {

    ModManager modmanager;
    private string fixtures_path = GLib.Environment.get_current_dir() + "/tests/fixtures";

    public TestNTW() {
        // assign a name for this class
        base("TestNTW");
        // add test methods
        add_test(" * (test_default_mods_and_data_and_scripts_path) Test default mods, data and scripts path", test_default_mods_and_data_and_scripts_path);
        add_test(" * (test_get_mods_list_from_path_no_packs_found) Test no mod is detected as all files are from game", test_get_mods_list_from_path_no_packs_found);
        add_test(" * (test_get_mods_list_from_path_some_packs_found) Test some mods are detected", test_get_mods_list_from_path_some_packs_found);
        add_test(" * (test_get_mods_list_from_path_ignores_game_files) Test some mods are detected ignoring game files", test_get_mods_list_from_path_ignores_game_files);
        add_test(" * (test_update_mods_list) Test mods list is build from mods path", test_update_mods_list);
        add_test(" * (test_update_mods_list_autoscan) Test mods list is build on constructor", test_update_mods_list_autoscan);
        add_test(" * (test_check_is_installed) Test check if a Mod is installed in a path", test_check_is_installed);
        add_test(" * (test_install_mod_uninstall_mod) Test install a mod an uninstall it", test_install_mod_uninstall_mod);
    }

    public override void set_up () {
        this.modmanager = new ModManager.with_scripts_path(this.fixtures_path+"/Napoleon Total War", this.fixtures_path+"/scripts", false);
    }

    public override void tear_down () {
        // Netegem els fitxers preferences i user script per deixarlos com han de estar al inici de cada test
        File file = File.new_for_path (this.fixtures_path+"/scripts/user.script.txt");
        if (file.query_exists()) file.delete();
        file = File.new_for_path (this.fixtures_path+"/scripts/preferences.script.txt");
        FileIOStream io = file.open_readwrite();
        var writer = new DataOutputStream(io.output_stream);
        writer.put_string("LINIA DE PROVA 1;\nLINIA DE PROVA 2;");
    }

    private uint8[] get_fixture_content(string path, bool delete_final_byte) {
        string abs_path = this.fixtures_path + path;
        File file = File.new_for_path (abs_path);
        var file_stream = file.read ();
        var data_stream = new DataInputStream (file_stream);
        uint8[]  contents;
        try {
            try {
                string etag_out;
                file.load_contents (null, out contents, out etag_out);
            }catch (Error e){
                error("%s", e.message);
            }
        }catch (Error e){
            error("%s", e.message);
        }
        if (delete_final_byte) return contents[0:contents.length-1];
        else return contents;
    }

    public void assert_strings(uint8[] res1, uint8[] res2) {
        string s1 = (string)res1;
        string s2 = (string)res2;
        if (s1 == null) s1 = " ";
        if (s2 == null) s2 = " ";
        s1 = s1.strip();
        s2 = s2.strip();
        //print("\nCHECK:\n|"+s1+"|"+s2+"|\n");
        assert (s1 == s2);
    }

    public void test_default_mods_and_data_and_scripts_path() {
        ModManager aux = new ModManager(this.fixtures_path+"/Napoleon Total War", false);
        assert (aux.game_name == "Napoleon Total War");
        assert (aux.mods_path == aux.game_path+"/data/mods");
        assert (aux.data_path == aux.game_path+"/data");
        assert (aux.preferences_script_path == Environment.get_home_dir()+".Creative Assembly/Napoleon Total War/scripts/preferences.script.txt");
        assert (aux.user_script_path == Environment.get_home_dir()+".Creative Assembly/Napoleon Total War/scripts/user.script.txt");
    }

    public void test_get_mods_list_from_path_no_packs_found() {
        ModManager aux_modmanager = new ModManager(this.fixtures_path+"/Napoleon Total War_no_mods", false);
        Gee.ArrayList<string> aux = aux_modmanager.get_mods_list_from_path(aux_modmanager.data_path);
        assert (aux.size == 0);
    }

    public void test_get_mods_list_from_path_some_packs_found() {
        Gee.ArrayList<string> aux = this.modmanager.get_mods_list_from_path(this.modmanager.mods_path);
        assert (aux.size == 3);
        Gee.ArrayList<string> expected = new Gee.ArrayList<string>();
        expected.add("mods/this_is_a Mod.pack");
        expected.add("mods/this_is_a_mod_2.pack");
        expected.add("mods/this_is_a_mod_3.pack");
        for (int i = 0; i < expected.size; i++) {
            assert(expected.get(i) == aux.get(i));
        }
    }

    public void test_get_mods_list_from_path_ignores_game_files() {
        Gee.ArrayList<string> aux = this.modmanager.get_mods_list_from_path(this.modmanager.data_path);
        assert (aux.size == 1);
        Gee.ArrayList<string> expected = new Gee.ArrayList<string>();
        expected.add("this_is_a_mod_4.pack");
        for (int i = 0; i < expected.size; i++) {
            assert(expected.get(i) == aux.get(i));
        }
    }

    public void test_update_mods_list() {
        assert (this.modmanager.mods_path == this.modmanager.game_path+"/data/mods");
        this.modmanager.update_mods_list();
        assert (this.modmanager.mod_list.size == 3);
    }

    public void test_update_mods_list_autoscan() {
        assert (this.modmanager.mods_path == this.modmanager.game_path+"/data/mods");
        this.modmanager = new ModManager(this.fixtures_path+"/Napoleon Total War", true);
        assert (this.modmanager.mod_list.size == 3);
    }

    public void test_mod_normalized_name() {
        Mod aux = new Mod("test/a/NO normalizat.pack");
        assert (aux.name == "NO normalizat.pack");
        assert (aux.normalized_name == "no_normalizat.pack");
    }

    public void test_check_is_installed() {
        Mod aux = new Mod(this.modmanager.mods_path+"/this_is_a Mod.pack");
        assert (this.modmanager.check_mod_is_installed(aux) == false);
        aux = new Mod(this.modmanager.mods_path+"/this_is_a_mod_4.pack");
        assert (this.modmanager.check_mod_is_installed(aux) == true);
    }

    public void test_install_mod_uninstall_mod() {
        Mod aux = new Mod(this.modmanager.mods_path+"/this_is_a Mod.pack");
        // Installem mod
        bool installed = this.modmanager.install_mod(aux);
        assert (this.modmanager.check_mod_is_installed(aux) == true);
        assert (installed == true);
        assert_strings("mod this_is_a_mod.pack;".data, get_fixture_content ("/scripts/user.script.txt", false));
        // Si ho cridem per segona vegada no falla ni fa res
        installed = this.modmanager.install_mod(aux);
        assert (this.modmanager.check_mod_is_installed(aux) == true);
        assert (installed == true);
        assert_strings("mod this_is_a_mod.pack;".data, get_fixture_content ("/scripts/user.script.txt", false));

        // Instalem un altre mod
        Mod aux2 = new Mod(this.modmanager.mods_path+"/this_is_a_mod_2.pack");
        installed = this.modmanager.install_mod(aux2);
        assert (this.modmanager.check_mod_is_installed(aux2) == true);
        assert (installed == true);
        assert_strings("mod this_is_a_mod.pack;\nmod this_is_a_mod_2.pack;".data, get_fixture_content ("/scripts/user.script.txt", false));
        // Si ho cridem per segona vegada no falla ni fa res
        aux2 = new Mod(this.modmanager.mods_path+"/this_is_a_mod_2.pack");
        installed = this.modmanager.install_mod(aux2);
        assert (this.modmanager.check_mod_is_installed(aux2) == true);
        assert (installed == true);
        assert_strings("mod this_is_a_mod.pack;\nmod this_is_a_mod_2.pack;".data, get_fixture_content ("/scripts/user.script.txt", false));

        // Desinstallem el primer mod
        bool uninstalled = this.modmanager.uninstall_mod(aux);
        assert (this.modmanager.check_mod_is_installed(aux) == false);
        assert (uninstalled == true);
        assert_strings("mod this_is_a_mod_2.pack;".data, get_fixture_content ("/scripts/user.script.txt", false));
        // Si ho cridem per segona vegada no falla ni fa res
        uninstalled = this.modmanager.uninstall_mod(aux);
        assert (this.modmanager.check_mod_is_installed(aux) == false);
        assert (uninstalled == true);
        assert_strings("mod this_is_a_mod_2.pack;".data, get_fixture_content ("/scripts/user.script.txt", false));

        // Desinstallem el segon mod
        uninstalled = this.modmanager.uninstall_mod(aux2);
        assert (this.modmanager.check_mod_is_installed(aux2) == false);
        assert (uninstalled == true);
        assert_strings("".data, get_fixture_content ("/scripts/user.script.txt", false));
        // Si ho cridem per segona vegada no falla ni fa res
        uninstalled = this.modmanager.uninstall_mod(aux2);
        assert (this.modmanager.check_mod_is_installed(aux2) == false);
        assert (uninstalled == true);
        assert_strings("".data, get_fixture_content ("/scripts/user.script.txt", false));
    }

}
