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
 * in-app notifications
 */


public abstract class AppNotification : Object {
    internal Gtk.Revealer widget;

    public AppNotification() {
        base();
        widget = new Gtk.Revealer();
        widget.reveal_child = true;
        widget.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

        // TODO: should be child-revealed so close gets animated,
        // but it doesn't get triggered (gtk+ bug?)
        widget.notify["reveal-child"].connect(on_child_revealed);
    }

    public void close() {
        this.widget.reveal_child = false;
    }

    void on_child_revealed() {
        if (!this.widget.reveal_child) {
            this.widget.destroy();
        }
    }
}

public class SpinnerNotification : AppNotification {
    private Gtk.Label label;

    public SpinnerNotification(string text) {
        base();
        var grid = new Gtk.Grid();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        grid.column_spacing = 12;

        var spinner = new Gtk.Spinner();
        spinner.active = true;
        grid.add(spinner);

        label = new Gtk.Label(text);
        grid.add(label);

        this.widget.add(grid);
        this.widget.show_all();
    }

    public void set_label(string text) {
        label.label = text;
    }
}

public class NotificationQueue : Object {
    public Gtk.Frame widget;
    Gtk.Grid grid;

    public NotificationQueue() {
        this.widget = new Gtk.Frame(null);
        this.widget.valign = Gtk.Align.START;
        this.widget.halign = Gtk.Align.CENTER;
        this.widget.no_show_all = true;
        this.widget.get_style_context().add_class("app-notification");

        this.grid = new Gtk.Grid();
        this.grid.orientation = Gtk.Orientation.VERTICAL;
        this.grid.row_spacing = 6;
        this.grid.visible = true;

        this.widget.add(this.grid);

    }

    public void add_notification(AppNotification notification) {
        this.grid.add(notification.widget);

        notification.widget.destroy.connect(on_child_destroy);

        this.widget.show();
    }

    void on_child_destroy() {
        if (this.grid.get_children().length() == 0) {
           this.widget.hide();
       }
    }
}