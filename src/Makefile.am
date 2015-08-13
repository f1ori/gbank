AM_CFLAGS = $(GBANK_CFLAGS)

bin_PROGRAMS = gbank

gbank_SOURCES = resources.c \
		banking_ui.vala \
		bank_job_window.vala \
		database.vala \
		gbank.vala \
		notifications.vala \
		new_transfer_dialog.vala \
		statement_dialog.vala \
		banking.vala \
		create_user_wizard.vala \
		flicker_tan_dialog.vala \
		main_window.vala \
		password_dialog.vala \
		user_dialog.vala

gbank_VALAFLAGS= @GBANK_VALA_FLAGS@
gbank_LDADD= @GBANK_LIBS@


GRESDEPS = $(top_srcdir)/$1 $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir) $(top_srcdir)/$1)
resource_deps = $(call GRESDEPS,resources.xml)
resources.c: $(resource_deps)
	$(GLIB_COMPILE_RESOURCES) $(top_srcdir)/resources.xml --target=resources.c --generate-source --sourcedir=$(top_srcdir)

