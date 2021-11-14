/*
* Copyright (C) 2018  Eduard Berloso Clarà <eduard.bc.95@gmail.com>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero General Public License as published
* by the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*/


public class Mod {

    public string path;
    public string name;
    public string normalized_name;
    public int order;
    public bool installed;
    public File mod_file;

    // UI elements
    public Gtk.Switch installed_switch;
    public Gtk.Entry order_entry;
    public Gtk.Label name_label;

    public Mod (string path, int order = 0) {
        this.with_data_path(path, order, null);
    }

    public Mod.with_data_path(string path, int order = 0, string? data_path) {
        this.path = path;
        this.order = order;
        this.mod_file = File.new_for_path(path);
        this.name = this.mod_file.get_basename ();
        this.normalized_name = this.normalize_mod_name_for_linux(this.name);
        if (data_path != null) this.installed = this.check_is_installed(data_path);
    }

    public string normalize_mod_name_for_linux(string st) {
    // Returns a copy of "st" normalized for linux. Bassiclly is lowercased and with underscope. Mods names in linux must be lowercase.
        return st.strip().normalize().down().replace(" ", "_");
    }

    public string get_relative_path(string data_path) {
    // Returns the relative path from "data_path" to "this.path"
        File data_file = File.new_for_path(data_path);
        return data_file.get_relative_path(this.mod_file);
    }

    public bool is_valid() {
    // Rerturns true if the "this.mod_file" is a valid mod file for NTW.
    // By now, it only checks that the extension is ".pack"
        string[] aux = this.mod_file.get_basename().split(".");
        if (aux.length < 1) return false;
        return aux[aux.length -1] == "pack";
    }

    public bool check_is_installed(string data_path) {
    // Check if this is installed in "data_path".
    // A Mod is installed if there is a file in the "data_path" with "this.normalized_name"
        File data_file = File.new_for_path (data_path);
        if (!data_file.query_exists()) return false;
        FileEnumerator enumerator = data_file.enumerate_children ("standard::*", FileQueryInfoFlags.NONE, null);
        FileInfo child_file_info = null;

        while (((child_file_info = enumerator.next_file (null)) != null)) {
            if (child_file_info.get_name() == this.normalized_name) return true;
        }
        return false;
    }
    public bool update_is_installed(string data_path) {
        this.installed = this.check_is_installed(data_path);
        return this.installed;
    }

    public bool install(string data_path, string user_script_path) {
    // Installs "this" in "data_path". Installing means creating a symbolinc ling from "this" inside "data_mod" using the "this.normalized_name".
    // Then, "this.normalized_name" is writed in "user_script_path" file.
    // Calling install with an already installed mod does nothing.
        File data_file = File.new_for_path (data_path);
        if (!data_file.query_exists()) {
            string err = "Error: directory '"+data_path+"' does not exist, the mod '"+this.name+"'can not be installed.";
            throw new Error(Quark.from_string(err), -1, err);
        } else if (!this.check_is_installed(data_path)) {
            File new_mod_file = File.new_for_path (data_path+"/"+this.normalized_name);
            new_mod_file.make_symbolic_link(this.path);
        }
        this.add_user_scripts_line(user_script_path);
        return this.update_is_installed(data_path);
    }

    public bool uninstall(string data_path, string user_script_path) {
    // Uninstalls "this" from "data_path". Uninstalling means deleting a symbolinc link from "this" inside "data_path" using the "this.normalized_name".
    // Then, "this..normalized_name" is deleted from "user_script_path" file.
    // Calling uninstall_mode with an already uninstalled mod does nothing.
    // If the file foun in "data_path" is not a symbolic link, it can not be uninstalled
    // Returns true if "this" can be uinstalled. Otherwise returns false
        File data_file = File.new_for_path (data_path);
        if (!data_file.query_exists()) {
            string err = "Error: directory '"+data_path+"' does not exist, the mod '"+this.name+"'can not be uninstalled.";
            throw new Error(Quark.from_string(err), -1, err);
        } else if (this.check_is_installed(data_path)) {
            File new_mod_file = File.new_for_path (data_path+"/"+this.normalized_name);
            FileInfo info = new_mod_file.query_info("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            if (!info.get_is_symlink()) {
                string err = "Error: mod '"+this.name+"' can not be uninstalled because it is not a symbolic link.";
                throw new Error(Quark.from_string(err), -1, err);
            }
            new_mod_file.delete(null);
        }
        this.remove_user_scripts_line(user_script_path);
        return !this.update_is_installed(data_path);
    }

    public void add_user_scripts_line(string user_script_path) {
    // Adds the line "mod this.normalized_name" to the file "user_script_path" if it is not already there
        File user_file = File.new_for_path (user_script_path);
        if (!user_file.query_exists()) {
            string err = "Error: file '"+user_script_path+"' does not exist, the mod '"+this.name+"'can not be installed.";
            throw new Error(Quark.from_string(err), -1, err);
        } else {
            FileIOStream iostream = user_file.open_readwrite ();
            DataInputStream reader = new DataInputStream (iostream.input_stream);
            string? line = null;
            string to_write = "mod "+this.normalized_name+";";
            bool found = false;
	        while ((line = reader.read_line ()) != null) {
	            if (line == to_write) found = true;
	        }
	        if (!found) {
	            iostream.seek (0, SeekType.END);
		        OutputStream ostream = iostream.output_stream;
		        DataOutputStream dostream = new DataOutputStream (ostream);
		        dostream.put_string (to_write+"\n");
	        }
        }
    }

    public void remove_user_scripts_line(string user_script_path) {
    // Removes the line "mod this.normalized_name" to the file "user_script_path" if it is already there
        File user_file = File.new_for_path (user_script_path);
        if (!user_file.query_exists()) {
            string err = "Error: file '"+user_script_path+"' does not exist, the mod '"+this.name+"'can not be uninstalled.";
            throw new Error(Quark.from_string(err), -1, err);
        } else {
            FileIOStream iostream = user_file.open_readwrite ();
            DataInputStream reader = new DataInputStream (iostream.input_stream);
            string? line = null;
            string to_write = "mod "+this.normalized_name+";";
            bool found = false;
            string all_content = "";
	        while ((line = reader.read_line ()) != null) {
	            if (line == to_write) found = true;
	            all_content += line+"\n";
	        }
	        if (found) {
	            all_content = all_content.replace(to_write+"\n", "");
	            all_content = all_content.replace(to_write, "");
	            FileOutputStream ostream = user_file.replace (null, false, FileCreateFlags.NONE);
		        DataOutputStream dostream = new DataOutputStream (ostream);
		        dostream.put_string (all_content);
	        }
        }
    }

    public void save_data(string stored_mods_data_path) {
    // Stores the info of "this" that needs to be stored in "stored_mods_data_path"
    // "stored_mods_data_path" is a csv file. The first columns is the path of the Mod and the second columns is it's current order
    // If there is another line where the first column is the current Mod, it is relaced. Otherwise is added at the end of the file
        File user_file = File.new_for_path (stored_mods_data_path);
        if (!user_file.query_exists()) {
            string err = "Error: file '"+stored_mods_data_path+"' does not exist, the mod '"+this.name+"'can not be saved.";
            throw new Error(Quark.from_string(err), -1, err);
        } else {
            FileIOStream iostream = user_file.open_readwrite ();
            DataInputStream reader = new DataInputStream (iostream.input_stream);
            string? line = null;
            string to_write = this.path+";"+this.order.to_string();
            string to_search = this.path;
            string to_delete = "";
            string all_content = "";
	        while ((line = reader.read_line ()) != null) {
	            if (line.split(";")[0] == to_search) to_delete = line;
	            all_content += line+"\n";
	        }
	        if (to_delete != "") {
	            all_content = all_content.replace(to_delete+"\n", "");
	            all_content = all_content.replace(to_delete, "");
	        }
	        all_content += to_write;
            FileOutputStream ostream = user_file.replace (null, false, FileCreateFlags.NONE);
	        DataOutputStream dostream = new DataOutputStream (ostream);
	        dostream.put_string (all_content);
        }
    }

    public void load_data(string stored_mods_data_path) {
    // Updates "this" info from the data found in "stored_mods_data_path"
    // "stored_mods_data_path" is a csv file. The first columns is the path of the Mod and the second columns is it's current order
        File user_file = File.new_for_path (stored_mods_data_path);
        if (!user_file.query_exists()) {
            string err = "Error: file '"+stored_mods_data_path+"' does not exist, the mod '"+this.name+"'can not be loaded.";
            throw new Error(Quark.from_string(err), -1, err);
        } else {
            FileIOStream iostream = user_file.open_readwrite ();
            DataInputStream reader = new DataInputStream (iostream.input_stream);
            string? line = null;
            string to_search = this.path;
	        while ((line = reader.read_line ()) != null) {
	            if (line.split(";")[0] == to_search) {
	                string[] mod_data = line.split(";");
	                this.order = int.parse(mod_data[1]);
	                if (this.order_entry != null) this.order_entry.set_text(this.order.to_string());
	            }
	        }
        }
    }

    public Gtk.Box get_ui() {
    /// Returns the representation of this as a Gtk.Widget
        Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        if (this.installed_switch == null) {
            this.installed_switch = new Gtk.Switch();
            this.installed_switch.set_active(this.installed);
        } else {
            this.installed_switch.set_active(this.installed);
        }
        if (this.order_entry == null) {
            this.order_entry = new Gtk.Entry();
            this.order_entry.set_text(this.order.to_string());
            this.order_entry.set_width_chars(2);
            this.order_entry.set_alignment(0.5f);
        } else {
            this.order_entry.set_text(this.order.to_string());
        }
        if (this.name_label == null) {
            this.name_label = new Gtk.Label(this.name);
            this.name_label.set_xalign(0);
        } else {
            this.name_label = new Gtk.Label(this.name);
        }
        box.pack_start(this.installed_switch, false, false, 10);
        box.pack_start(this.order_entry, false, false, 10);
        box.pack_start(this.name_label, true, true, 0);
        return box;
    }

}

public class ModManager {
    public string game_path;
    public string data_path;
    public string mods_path;
    public string preferences_script_path;
    public string user_script_path;
    public string game_name;
    public string stored_data_path;
    public string stored_mods_data_path;
    public Gee.ArrayList<Mod> mod_list;
    public Gee.ArrayList<string> game_pack_files;
    public Gee.ArrayList<string> excluded_mod_list;

    public Gtk.ScrolledWindow mod_list_ui;

    public ModManager (string path, bool autoscan = true) {
        this.with_mods_path(path, path+"/data/mods", autoscan);
    }

    public ModManager.with_mods_path (string game_path, string mods_path, bool autoscan = true) {
        this.with_mods_and_scripts_path(game_path, mods_path, null, autoscan);
    }

    public ModManager.with_scripts_path (string game_path, string scripts_path, bool autoscan = true) {
        this.with_mods_and_scripts_path(game_path, game_path+"/data/mods", scripts_path, autoscan);
    }

    public ModManager.with_mods_and_scripts_path (string game_path, string mods_path, string? scripts_path, bool autoscan = true) {
        File file;
        this.stored_data_path = Environment.get_user_config_dir();
        this.stored_mods_data_path = this.stored_data_path + "/" + App.Configs.Constants.ID;
        file = File.new_for_path (this.stored_mods_data_path);
        if (!file.query_exists() && file.get_parent() != null && file.get_parent().query_exists()) {
            file.create(FileCreateFlags.NONE);
        }

        this.game_path = game_path;
        this.data_path = game_path + "/data";
        this.mods_path = mods_path;
        this.game_name = File.new_for_path(game_path).get_basename ();

        string aux = this.get_default_scripts_path();
        if (scripts_path != null) aux = scripts_path;
        this.preferences_script_path = aux+"/preferences.script.txt";
        this.user_script_path = aux+"/user.script.txt";
        file = File.new_for_path (user_script_path);
        if (!file.query_exists() && file.get_parent() != null && file.get_parent().query_exists()) {
            file.create(FileCreateFlags.NONE);
        }

        this.mod_list = new Gee.ArrayList<Mod> ();
        this.game_pack_files = this.get_default_game_pack_files();
        this.excluded_mod_list = this.get_default_excluded_mod_files();
        if (autoscan) {
            this.update_mods_list();
        }
    }

    public void save_mod_list() {
    // Stores the info of each Mod in this.mod_list that needs to be stored in this.stored_mods_data_path
    // this.stored_mods_data_path is a csv file. The first columns is the path of the Mod and the second columns is it's current order
        foreach (Mod m in this.mod_list) {
            m.save_data(this.stored_mods_data_path);
        }
    }

    public Gtk.ScrolledWindow get_ui() {
    /// Returns the representation of this as a Gtk.Widget
        this.mod_list_ui = new Gtk.ScrolledWindow(null, null);
        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        foreach (Mod m in this.mod_list) {
            box.pack_start(m.get_ui(), true, false, 2);
        }
        this.mod_list_ui.add(box);
        return this.mod_list_ui;
    }

    public Gtk.ScrolledWindow update_ui() {
    /// Returns the representation of this as a Gtk.Widget
        if (this.mod_list_ui == null) mod_list_ui = new Gtk.ScrolledWindow(null, null);
        else {
            this.mod_list_ui.forall ((element) => {
                if (!(element is Gtk.ScrolledWindow)) {
                    this.mod_list_ui.remove(element);
                }
            });
        }
        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        foreach (Mod m in this.mod_list) {
            box.pack_start(m.get_ui(), true, false, 2);
        }
        this.mod_list_ui.add(box);
        this.mod_list_ui.show_all();
        return this.mod_list_ui;
    }

    public string get_default_scripts_path() {
        return Environment.get_home_dir()+"/.Creative Assembly/"+this.game_name+"/scripts";
    }

    public void set_game_path(string path) {
        this.game_path = path;
    }

    public string get_game_path() {
        return this.game_path;
    }

    public void set_mods_path(string path) {
        this.mods_path = path;
    }

    public string get_mods_path() {
        return this.mods_path;
    }

    public void set_user_script_path(string path) {
        this.preferences_script_path = path+"/preferences.script.txt";
        this.user_script_path = path+"/user.script.txt";
        File file = File.new_for_path (this.user_script_path);
        if (!file.query_exists() && file.get_parent() != null && file.get_parent().query_exists()) {
            file.create(FileCreateFlags.NONE);
        }
    }

    public string get_user_script_path() {
        return this.user_script_path.replace("user.script.txt", "");
    }

    public void update_mods_list() {
    // Updates the list of mods stored in "this.mod_list" with the mods found in "this.mods_path".
    // Before updating it we store the current data of mods with this.save_mod_list
        this.save_mod_list();
        this.update_mods_list_from_path(this.mods_path, this.stored_mods_data_path);
    }

    public void update_mods_list_from_path(string path, string? stored_mods_data_path = "") {
    // Updates the list of mods stored in this.mod_list with the mods found in "path"
    // If "stored_mods_data_path" is given, before creating each mod we search stored info in "stored_mods_data_path"
        Gee.ArrayList<string> modlist = this.get_mods_list_from_path(path);
        this.mod_list = new Gee.ArrayList<Mod> ();
        int i = 0;
        Mod m;
        foreach (string mod in modlist) {
            m = new Mod.with_data_path(mod, i, this.data_path);
            if (stored_mods_data_path != "") m.load_data(this.stored_mods_data_path);
            m.installed = this.check_mod_is_installed(m);
            this.mod_list.add(m);
            i += 1;
        }
    }

    public Gee.ArrayList<string> get_mods_list_from_path(string path, bool recursive = true) {
    // Returns a list of string with the relative path from "this.data_path" to any .pack file found in "path".
    // The main .pack files from NTW stored in "this.game_pack_files" are ignored as they are not mods.
    // The mods listed in "this.excluded_mod_list" (empty by default) are also excluded.
        Gee.ArrayList<string> modlist = new Gee.ArrayList<string> ();

        // Si no existeix no fem res evidentment. Lo important es que no peti
        File file = File.new_for_path (path);
        if (!file.query_exists()) return modlist;

        // Recorrem els fitxers. Segueix enllaços simbolics.
        Mod mod;
        FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NONE, null);
        FileInfo child_file_info = null;

        while (((child_file_info = enumerator.next_file (null)) != null)) {
            print("\n--------------> Check file: "+child_file_info.get_name()+"\n");
            mod = new Mod(path+"/"+child_file_info.get_name());
            if (!this.check_mod_excluded(mod)) modlist.add(mod.get_relative_path(this.data_path));
            else if (recursive && child_file_info.get_file_type() == FileType.DIRECTORY) {
                foreach (string aux in this.get_mods_list_from_path(path+"/"+child_file_info.get_name())) {
                    modlist.add(aux);
                }
            }
        }
        return modlist;
    }

    public Gee.ArrayList<string> get_default_game_pack_files() {
    // Returns an ArrayList with the base pack files from Napoleon Total War. This are pack files from the main games, not mods.
        Gee.ArrayList<string> aux = new Gee.ArrayList<string> ();
        aux.add("variantmodels2.pack");
        aux.add("variantmodels.pack");
        aux.add("sound.pack");
        aux.add("rigidmodels.pack");
        aux.add("patch_media2.pack");
        aux.add("patch_media.pack");
        aux.add("patch7.pack");
        aux.add("patch6.pack");
        aux.add("patch5.pack");
        aux.add("patch4.pack");
        aux.add("patch3.pack");
        aux.add("patch2.pack");
        aux.add("patch.pack");
        aux.add("media.pack");
        aux.add("local_en_patch.pack");
        aux.add("local_en.pack");
        aux.add("data.pack");
        aux.add("buildings.pack");
        aux.add("boot.pack");
        aux.add("battleterrain.pack");
        return aux;
    }

    public Gee.ArrayList<string> get_default_excluded_mod_files() {
    // TODO
    // TOTEST
    // Returns an ArrayList with theexcluded mods.
        Gee.ArrayList<string> aux = new Gee.ArrayList<string> ();
        return aux;
    }

    public bool check_mod_excluded(Mod mod) {
    // Returns true if
    //     the the relative path from "this.data_path" to "mod" is listed in "this.game_pack_files"
    //     or "this.excluded_mod_list"
    //     or it is not a pack file
        bool is_game_file = this.game_pack_files.contains(mod.get_relative_path(this.data_path));
        bool is_excluded_file = this.excluded_mod_list.contains(mod.get_relative_path(this.data_path));
        bool is_valid_mod = mod.is_valid();
        return is_game_file || is_excluded_file || !is_valid_mod;
    }

    public bool check_mod_is_installed(Mod mod) {
    // Check if the mod is installed.
    // A Mod is installed if there is a file in the "this.data_path" with "mod.normalized_name"
        return mod.check_is_installed(this.data_path);
    }

    public bool install_mod(Mod mod) {
    // Installs "mod" in "this.data_path". Installing means creating a symbolinc link from "mod" inside "this.data_path" using the "mod.normalized_name".
    // Then, "mod.normalized_name" is writed in "this.user_script_path" file.
    // Calling install_mode with an already installed mod does nothing.
    // Returns true if "mod" can be installed. Otherwise returns false
        return mod.install(this.data_path, this.user_script_path);
    }

    public bool uninstall_mod(Mod mod) {
    // Uninstalls "mod" from "this.data_path". Uninstalling means deleting a symbolinc link from "mod" inside "this.data_path" using the "mod.normalized_name".
    // Then, "mod.normalized_name" is deleted from "this.user_script_path" file.
    // Calling uninstall_mode with an already uninstalled mod does nothing.
    // If the file foun in "this.data_path" is not a symbolic link, it can not be uninstalled
    // Returns true if "mod" can be uinstalled. Otherwise returns false
        return mod.uninstall(this.data_path, this.user_script_path);
    }

    public void sort_mod_list() {
    // Replaces this.mod_list with a sorted version of this.mod_list. Mods from this.mod_list are sorted by Mod.order
        CompareDataFunc<Mod> cmpfunc = (a, b) => {
		    return (a.order <= b.order)? -1 : 1;
	    };
	    this.mod_list.sort(cmpfunc);
    }

    public void update_installed_mods() {
    // Check all mods from this.mod_list. If a mod "m" has "m.installed_switch" set to true, it is installed. Otherwise it is uninstalled.
        int i = 0;
        // Primer bucle per desinstalar-ho tot
        foreach (Mod m in this.mod_list) {
            m.order = int.parse(m.order_entry.get_text());
            this.uninstall_mod(m);
        }
        // Segon bucle per instalar tot lo que toqui.
        // Ho fem en 2 bucles perque en el de isntalar l'hem de recorre ordenat
        this.sort_mod_list();
        foreach (Mod m in this.mod_list) {
            if (m.installed_switch == null) {
                // DO NOTHING
            } else if (m.installed_switch.state) {
                this.install_mod(m);
            } else {
                // DO NOTHING
            }
        }
    }

}
