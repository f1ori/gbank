VALAFILES=gbank.vala \
	  password_dialog.vala \
	  banking_ui.vala \
	  banking.vala \
	  database.vala \
	  create_user_wizard.vala \
	  statement_dialog.vala \
	  new_transfer_dialog.vala \
	  user_dialog.vala \
	  bank_job_window.vala \
	  main_window.vala

all: gbank

resources.c: resources.xml ui/*.ui
	glib-compile-resources resources.xml --target=resources.c --generate-source

gbank: $(VALAFILES) resources.c
	valac -g --girdir=../hbci4java-glib/ghbci/ --girdir=. -X -I../hbci4java-glib/ghbci/ -X -L../hbci4java-glib/ghbci/.libs/ -X -lghbci-0.1 \
		--target-glib=2.38 --pkg glib-2.0 --pkg gee-1.0 --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg GHbci-0.1 --pkg posix --pkg gio-2.0 \
		--pkg Gda-5.0 -X -I/usr/include/libgda-5.0 -X -I/usr/include/libgda-5.0/libgda/ -X -lgda-5.0 \
		--gresources=resources.xml \
		$(VALAFILES) resources.c

run: gbank
	LD_LIBRARY_PATH=../hbci4java-glib/ghbci/.libs/:${LD_LIBRARY_PATH} ./gbank

clean:
	rm -f gbank *.vala.c resources.c

clean-db:
	rm -f gbank.db.db passport-file.properties
