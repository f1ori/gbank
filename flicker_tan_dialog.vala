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
 * tan dialog with flicker code
 */
[GtkTemplate (ui = "/de/f1ori/gbank/ui/flicker-tan-dialog.ui")]
public class FlickerTanDialog : Gtk.Dialog {
    [GtkChild]
    private Gtk.Label hint_label;
    [GtkChild]
    private Gtk.Entry tan_entry;
    [GtkChild]
    private Gtk.DrawingArea flicker_drawingarea;

    private uint8[] code;
    private int current_index = 0;
    private bool clock = true;
    private bool[] bars = new bool[5];
    private uint frequency = 20;
    private bool frequency_changed = false;
    private double zoom_factor = 1.0;

    public FlickerTanDialog(Gtk.Window parent, string hint, string flicker_code) {
        this.set_transient_for (parent);
        this.hint_label.label = hint;

        // add sync identifier
        var hex_code = "0FFF" + flicker_code;

        string hex = "0123456789ABCDEF";

        code = new uint8[hex_code.length];
        for (int i = 0; i < hex_code.length; i += 2) {
            code[i] = (uint8) hex.index_of_char(hex_code[i + 1]);
            code[i + 1] = (uint8) hex.index_of_char(hex_code[i]);
        }

        set_bars();

        Timeout.add(1000/frequency, next_tick);

        show_all();
    }

    private void set_bars() {
        bars[0] = clock;
        bars[1] = (bool) code[current_index] & 1;
        bars[2] = (bool) code[current_index] & 2;
        bars[3] = (bool) code[current_index] & 4;
        bars[4] = (bool) code[current_index] & 8;
    }

    private bool next_tick() {
        // remove timer if dialog is destroyed
        if (! (this.flicker_drawingarea is Gtk.DrawingArea)) {
            return Source.REMOVE;
        }

        // advance clock
        clock = !clock;
        if (clock == true) {
            current_index = (current_index + 1) % code.length;
        }

        // fill bars array
        set_bars();

        // schedule redraw
        flicker_drawingarea.queue_draw();

        // schedule next tick, adapt frequency if necessary
        if (frequency_changed) {
            frequency_changed = false;
            Timeout.add(1000 / frequency, next_tick);
            return Source.REMOVE;
        } else {
            return Source.CONTINUE;
        }
    }

    [GtkCallback]
    public bool on_flicker_drawingarea_draw(Cairo.Context context) {
        int height = flicker_drawingarea.get_allocated_height ();
        int width = flicker_drawingarea.get_allocated_width ();
        int bar_width = width / 5;

        // draw bars
        for(int i = 0; i < 5; ++i) {
            context.set_source_rgb(bars[i] ? 1 : 0, bars[i] ? 1 : 0, bars[i] ? 1 : 0);
            context.rectangle(i * bar_width, 0, bar_width, height);
            context.fill();
        }

        return true;
    }

    [GtkCallback]
    public void on_ok_button_clicked() {
        response(Gtk.ResponseType.OK);
    }

    [GtkCallback]
    public void on_cancel_button_clicked() {
        response(Gtk.ResponseType.CANCEL);
    }

    public string get_tan() {
        return this.tan_entry.get_text();
    }

    private void update_flicker_code_size() {
        flicker_drawingarea.set_size_request(
            (int) (250 * zoom_factor),
            (int) (100 * zoom_factor));
    }

    [GtkCallback]
    public void on_bigger_button_clicked() {
        zoom_factor = (zoom_factor + 0.1).clamp(0.5, 3);
        update_flicker_code_size();
    }

    [GtkCallback]
    public void on_smaller_button_clicked() {
        zoom_factor = (zoom_factor - 0.1).clamp(0.5, 3);
        update_flicker_code_size();
    }

    [GtkCallback]
    public void on_faster_button_clicked() {
        frequency = (frequency + 1).clamp(2, 40);
        frequency_changed = true;
    }

    [GtkCallback]
    public void on_slower_button_clicked() {
        frequency = (frequency - 1).clamp(2, 40);
        frequency_changed = true;
    }
}
