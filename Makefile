all:
	valac -g --vapidir=./ --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg gwenhywfar --pkg aqbanking --pkg posix --pkg Gda-5.0 --Xcc=-laqhbci \
		-X -I/usr/include/libgda-5.0 -X -I/usr/include/libgda-5.0/libgda/ -X -lgda-5.0 gbank.vala
