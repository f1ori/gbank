VALAFILES=gbank.vala password_dialog.vala banking.vala database.vala create_user_wizard.vala bank_job_window.vala main_window.vala

all: gbank

gbank: $(VALAFILES)
	valac -g --girdir=../hbci4java-glib/ghbci/ -X -I../hbci4java-glib/ghbci/ -X -L../hbci4java-glib/ghbci/.libs/ -X -lghbci-0.1 \
		--pkg glib-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg GHbci-0.1 --pkg posix \
		--pkg Gda-5.0 -X -I/usr/include/libgda-5.0 -X -I/usr/include/libgda-5.0/libgda/ -X -lgda-5.0 \
		$(VALAFILES)

run:
	LD_LIBRARY_PATH=../hbci4java-glib/ghbci/.libs/ ./gbank

clean:
	rm -f gbank *.vala.c
