using App;

class TestNTW : Gee.TestCase {

    public TestNTW() {
        // assign a name for this class
        base("TestNTW");
        // add test methods
        add_test(" * Test dummy to test the test (test_dummy)", test_dummy);
    }

    public override void set_up () {
    }

    public override void tear_down () {
    }

    private uint8[] get_fixture_content(string path, bool delete_final_byte) {
        string abs_path = Environment.get_variable("TESTDIR")+"/fixtures/" + path;
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

    public void test_dummy() {
        assert (1 != 1);
    }

}
