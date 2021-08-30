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


public class ModManager {
    public string game_path;

    public ModManager (string path) {
        this.game_path = path;
    }

    public void set_game_path(string path) {
        this.game_path = path;
    }

    public string get_game_path() {
        return this.game_path;
    }
}
