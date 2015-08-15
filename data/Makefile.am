SUBDIRS = icons

desktopdir = $(datadir)/applications
desktop_DATA = de.f1ori.gbank.desktop
EXTRA_DIST = de.f1ori.gbank.desktop

UPDATE_DESKTOP = update-desktop-database $(datadir)/applications || :

install-data-hook: 
		$(UPDATE_DESKTOP)
uninstall-hook: 
		$(UPDATE_DESKTOP)
