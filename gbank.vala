
class GBank : Gtk.Application {
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
    }

    protected override void activate () {
        new MainWindow (this);
    }
}

int main (string[] args) {
    return new GBank ().run (args);
}