# Makefile for TazDrop
#
PREFIX?=/usr
SYSCONFDIR?=/etc/slitaz

# Installation

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin \
		$(DESTDIR)$(PREFIX)/share/locale \
		$(DESTDIR)$(PREFIX)/share/applications \
		$(DESTDIR)$(SYSCONFDIR)
	cp -a tazdrop $(DESTDIR)$(PREFIX)/bin
	cp -a *.conf $(DESTDIR)$(SYSCONFDIR)
	cp -a data/*.desktop $(DESTDIR)$(PREFIX)/share/applications
	cp -a po/mo/* $(DESTDIR)$(PREFIX)/share/locale 2>/dev/null || return 0

