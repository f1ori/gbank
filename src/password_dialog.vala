/*  This file is part of gbank, a Gtk+ Online Banking Software using HBCI
 *  Copyright (C) 2015 Florian Richter
 *
 *  gbank is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  gbank is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with gbank.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * password dialog
 */
public class PasswordDialog : Gtk.Dialog {
    public Gtk.Entry password_entry;

    public PasswordDialog(Gtk.Window parent, string prompt) {
        this.title = "Enter Password";
        this.set_transient_for (parent);
        this.set_modal (true);
        this.border_width = 5;
        set_default_size (500, 180);
        var label = new Gtk.Label (prompt);
        password_entry = new Gtk.Entry();
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        password_entry.set_visibility (false);
        password_entry.set_activates_default(true);

        var content = get_content_area () as Gtk.Box;
        content.pack_start (label, false, true);
        content.pack_start (password_entry, false, true);
        content.spacing = 10;

        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        var ok_button = add_button ("OK", Gtk.ResponseType.OK);
        set_default_response (Gtk.ResponseType.OK);
        ok_button.can_default = true;
        set_default (ok_button);
        show_all();
    }

}
