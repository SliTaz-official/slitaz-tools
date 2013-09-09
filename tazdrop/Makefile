# Makefile for TazDrop
#
PREFIX?=/usr
SYSCONFDIR?=/etc/slitaz
LINGUAS?=es_AR fr pl pt_BR ru

# Installation

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin \
		$(DESTDIR)$(PREFIX)/share/doc/tazdrop \
		$(DESTDIR)$(PREFIX)/share/locale \
		$(DESTDIR)$(PREFIX)/share/applications \
		$(DESTDIR)$(SYSCONFDIR)
	install -m 0777 tazdrop $(DESTDIR)$(PREFIX)/bin
	install -m 0644 *.conf $(DESTDIR)$(SYSCONFDIR)
	install -m 0644 data/*.desktop $(DESTDIR)$(PREFIX)/share/applications
	install -m 0644 README $(DESTDIR)$(PREFIX)/share/doc/tazdrop
	for l in $(LINGUAS); \
	do \
		[ -s ../po/mo/$$l/tazdrop.mo ] || continue; \
		install -m 0777 -d $(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
		install -m 0644 ../po/mo/$$l/tazdrop.mo \
			$(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
	done;
