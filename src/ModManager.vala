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

    string path;
    int order;
    File mod_file;

    public Mod (string path, int order = 0) {
        this.path = path;
        this.order = order;
        this.mod_file = File.new_for_path(path);
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
}

public class ModManager {
    public string game_path;
    public string data_path;
    public string mods_path;
    public Gee.ArrayList<Mod> mod_list;
    public Gee.ArrayList<string> game_pack_files;
    public Gee.ArrayList<string> excluded_mod_list;

    public ModManager (string path, bool autoscan = true) {
        this.with_mods_path(path, path+"/data/mods", autoscan);
    }

    public ModManager.with_mods_path (string game_path, string mods_path, bool autoscan = true) {
        this.game_path = game_path;
        this.data_path = game_path + "/data";
        this.mods_path = mods_path;
        this.mod_list = new Gee.ArrayList<Mod> ();
        if (autoscan) {
            this.update_mods_list();
        }
        this.game_pack_files = this.get_default_game_pack_files();
        this.excluded_mod_list = this.get_default_excluded_mod_files();
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

    public void update_mods_list() {
    // Updates the list of mods stored in "this.mod_list" with the mods found in "this.mods_path"
        this.update_mods_list_from_path(this.game_path);
    }

    public void update_mods_list_from_path(string path) {
    // Updates the list of mods stored in this.mod_list with the mods found in "path"
        Gee.ArrayList<string> modlist = this.get_mods_list_from_path(path);
        int i = 0;
        foreach (string mod in modlist) {
            this.mod_list.add(new Mod(mod, i));
            i += 1;
        }
    }

    public Gee.ArrayList<string> get_mods_list_from_path(string path) {
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
        string relative_path;

        while (((child_file_info = enumerator.next_file (null)) != null)) {
            mod = new Mod(path+"/"+child_file_info.get_name());
            if (!this.check_mod_excluded(mod)) modlist.add(mod.get_relative_path(this.data_path));
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

}
