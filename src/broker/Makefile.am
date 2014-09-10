AM_CFLAGS = @GCCWARN@

libfluxdir = $(libdir)/flux
fluxmoddir = $(libfluxdir)/modules
fluxbindir = $(libexecdir)/flux

plugin_path = $(top_builddir)/src/modules/api/.libs:$(top_builddir)/src/modules/kvs/.libs:$(top_builddir)/src/modules/modctl/.libs:$(fluxmoddir)

exec_path = $(top_builddir)/src/cmd:$(fluxbindir)

AM_CPPFLAGS = \
	$(JSON_CFLAGS) \
	-DPLUGIN_PATH=\"$(plugin_path)\" -DEXEC_PATH=\"$(exec_path)\" \
	-I$(top_srcdir)/src/common/libutil \
	-I$(top_srcdir)/src/common/libflux

bin_PROGRAMS = cmbd

cmbd_SOURCES = \
	cmbd.c \
	plugin.c \
	plugin.h \
	boot_pmi.c \
	boot_pmi.h

cmbd_LDADD = \
	$(top_builddir)/src/common/libflux/libflux.la \
	$(top_builddir)/src/common/libutil/libutil.la \
	$(LIBMUNGE) $(JSON_LIBS) $(LIBZMQ) $(LIBCZMQ) $(LIBPTHREAD)