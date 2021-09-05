using App;

class TestNTW : Gee.TestCase {

    ModManager modmanager;
    private string fixtures_path = GLib.Environment.get_current_dir() + "/tests/fixtures";

    public TestNTW() {
        // assign a name for this class
        base("TestNTW");
        // add test methods
        add_test(" * Test default mods and data path (test_default_mods_and_data_path)", test_default_mods_and_data_path);
        add_test(" * Test no mod is detected as all files are from game (test_get_mods_list_from_path_no_packs_found)", test_get_mods_list_from_path_no_packs_found);
        add_test(" * Test some mods are detected (test_get_mods_list_from_path_some_packs_found)", test_get_mods_list_from_path_some_packs_found);
        add_test(" * Test some mods are detected ignoring game files (test_get_mods_list_from_path_ignores_game_files)", test_get_mods_list_from_path_ignores_game_files);
    }

    public override void set_up () {
        this.modmanager = new ModManager(this.fixtures_path+"/Napoleon Total War", false);
    }

    public override void tear_down () {
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

    public void test_default_mods_and_data_path() {
        assert (this.modmanager.mods_path == this.modmanager.game_path+"/data/mods");
        assert (this.modmanager.data_path == this.modmanager.game_path+"/data");
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
        expected.add("mods/this_is_a_mods.pack");
        expected.add("mods/this_is_a_mods_2.pack");
        expected.add("mods/this_is_a_mods_3.pack");
    }

    public void test_get_mods_list_from_path_ignores_game_files() {
        Gee.ArrayList<string> aux = this.modmanager.get_mods_list_from_path(this.modmanager.data_path);
        assert (aux.size == 1);
        Gee.ArrayList<string> expected = new Gee.ArrayList<string>();
        expected.add("mods/this_is_a_mods_4.pack");
    }

}
