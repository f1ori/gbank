VAPIFILES=gwenhywfar.vapi aqbanking.vapi
VALAFILES=gbank.vala password_dialog.vala banking.vala database.vala create_user_wizard.vala bank_job_window.vala main_window.vala

all: gbank

gbank: $(VALAFILES) $(VAPIFILES)
	valac -g --vapidir=./ --pkg glib-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg gwenhywfar --pkg aqbanking --pkg posix --pkg Gda-5.0 --Xcc=-laqhbci \
		-X -I/usr/include/libgda-5.0 -X -I/usr/include/libgda-5.0/libgda/ -X -lgda-5.0 \
		$(VALAFILES)

clean:
	rm -f gbank *.vala.c
