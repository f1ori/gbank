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
 * main application object
 */
class GBank : Gtk.Application {
    private Banking banking;
    private GBankDatabase database;

    private BankingUI banking_ui;
    private MainWindow main_window;

    public GBank () {
        Object (application_id: "com.github.gbank", flags: GLib.ApplicationFlags.FLAGS_NONE);
    }

    /* Override the 'startup' signal of GLib.Application. */
    protected override void startup () {
        base.startup ();

        var menu = new GLib.Menu ();
        menu.append ("About", "win.about");
        menu.append ("Quit", "app.quit");
        this.app_menu = menu;

        var quit_action = new GLib.SimpleAction ("quit", null);
        quit_action.activate.connect (this.quit);
        this.add_action (quit_action);

        try {
            // setup main components
            database = new GBankDatabase();
            banking = new Banking();
            main_window = new MainWindow (this);
            banking_ui = new BankingUI(main_window);

            main_window.set_banking_ui(banking_ui);
            banking.set_banking_ui(banking_ui);
       } catch (Error e) {
            new Gtk.MessageDialog (null,
                Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                Gtk.MessageType.ERROR, Gtk.ButtonsType.CLOSE,
                "Creation failed: %s", e.message).run();
            error("Creation failed: %s", e.message);
        }
    }

    protected override void activate () {
        main_window.present();
    }

    protected override void shutdown () {
        base.shutdown();

        banking.stop();
    }

    public unowned GBankDatabase getDatabase() {
        return database;
    }

    public unowned Banking getBanking() {
        return banking;
    }
}

int main (string[] args) {
    return new GBank ().run (args);
}
