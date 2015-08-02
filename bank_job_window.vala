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
 * Window showing logs
 */
public class BankJobWindow : Gtk.Window {
    private Gtk.ProgressBar progress_bar;
    private Gtk.TextView log;

    public BankJobWindow( Gtk.Window parent ) {
        this.title = "Log";
        this.set_default_size ( 400, 500 );
        this.set_transient_for ( parent );
        this.set_modal( false );

        var main_box = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );

        progress_bar = new Gtk.ProgressBar();
        main_box.pack_start( progress_bar, false, false, 8 );


        log = new Gtk.TextView();
        log.set_editable( false );

        var scrolled_log = new Gtk.ScrolledWindow ( null, null );
        scrolled_log.add( log );
        main_box.pack_start( scrolled_log, true, true, 8 );

        var cancel_button = new Gtk.Button.with_label( "Cancel" );
        cancel_button.clicked.connect( this.close );
        main_box.pack_start( cancel_button, false, false, 8 );

        this.add( main_box );

        main_box.show_all();

        this.delete_event.connect(this.hide_on_delete);
    }

    public void set_fraction(double fraction) {
        this.progress_bar.set_fraction(fraction);
    }

    public void add_log_line(string line) {
        var buffer = this.log.get_buffer();
        Gtk.TextIter iter;
        buffer.get_end_iter(out iter);
        buffer.insert(ref iter, line, line.length);
        buffer.insert(ref iter, "\n", 1);
        this.log.scroll_to_iter(iter, 0, false, 1, 1);
    }

    public void add_status_line (string line) {
        add_log_line( "status: " + line );
    }
}
