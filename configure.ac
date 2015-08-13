AC_INIT([gbank],[0.1],[florian@richter-es.de])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([foreign no-dist-gzip dist-bzip2])

LT_INIT
AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.26])
AC_PROG_INSTALL


# --enable-debug
AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug], [Enable debugging]),, enable_debug=no)
AM_CONDITIONAL([ENABLE_DEBUG], [ test "$enable_debug" = "yes"])


# Vala Packages {{{
pkg_modules="gtk+-3.0 >= 3.16
             glib-2.0 >= 2.44
             gee-1.0
             gmodule-2.0
             ghbci-0.1
             libgda-5.0"

PKG_CHECK_MODULES(GBANK, [$pkg_modules])

GBANK_VALA_FLAGS=" \
  --pkg gtk+-3.0 \
  --pkg glib-2.0\
  --pkg gee-1.0 \
  --pkg gmodule-2.0 \
  --pkg GHbci-0.1 \
  --pkg posix \
  --pkg gio-2.0 \
  --pkg Gda-5.0 \
  --target-glib=2.38 \
  --gresources=\$(top_srcdir)/resources.xml \
  --girdir=\$(top_srcdir)/gir/ \
  #-X -I/usr/include/libgda-5.0 \
  #-X -I/usr/include/libgda-5.0/libgda/ \
  #-X -lgda-5.0 \
  --thread \
  --enable-checking \
  --enable-experimental"


# }}}

if test "$enable_debug" = "yes"; then
  GBANK_VALA_FLAGS="$GBANK_VALA_FLAGS -D DEBUG -g"
fi

AC_SUBST(GBANK_CFLAGS)
AC_SUBST(GBANK_LIBS)
AC_SUBST(GBANK_VALA_FLAGS)

AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

AC_CONFIG_FILES([Makefile
                 data/Makefile
                 data/icons/Makefile
                 ui/Makefile
                 src/Makefile])

AC_OUTPUT

