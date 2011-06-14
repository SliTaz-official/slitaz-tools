# Makefile for SliTaz tools.
# Check the README for more information.
#
PREFIX?=/usr
DOCDIR?=/usr/share/doc
DESTDIR?=

PROJECTS=slitaz-tools slitaz-boxes tazbox tazdrop 
LINGUAS=fr pt_BR

all: msgfmt

help:
	@echo ""
	@echo "make: pot msgmerge msgfmt install install-boxes clean"
	@echo ""

# i18n.

tools-pot:
	@echo -n "Generating SliTaz Tools pot file... "
	@xgettext -o po/slitaz-tools/slitaz-tools.pot -L Shell \
		--package-name="SliTaz Tools" \
		./tinyutils/tazlocale
	@echo "done"

boxes-pot:
	@echo -n "Generating SliTaz Boxes pot file... "
	@xgettext -o po/slitaz-boxes/slitaz-boxes.pot -L Shell \
		--package-name="SliTaz Boxes" \
		./tinyutils/scpbox
	@echo "done"
	
tazbox-pot:
	@echo -n "Generating tazbox pot file... "
	@xgettext -o po/tazbox/tazbox.pot -L Shell \
		--package-name="TazBox" ./tazbox/tazbox
	@echo "done"

tazdrop-pot:
	@echo -n "Generating tazdrop pot file... "
	@xgettext -o po/tazdrop/tazdrop.pot -L Shell \
		--package-name="TazDrop" ./tazdrop/tazdrop
	@echo "done"

pot: tools-pot boxes-pot tazbox-pot tazdrop-pot

msgmerge:
	@for p in $(PROJECTS); do \
		for l in $(LINGUAS); do \
			echo -en "\rUpdating $$p $$l po file."; \
			[ -f "po/$$p/$$l.po" ] && \
				msgmerge -U po/$$p/$$l.po po/$$p/$$p.pot; \
		done; \
	done;

msgfmt:
	@for p in $(PROJECTS); do \
		for l in $(LINGUAS); do \
			[ -f "po/$$p/$$l.po" ] && \
				echo -n "Compiling $$p $$l mo file... " && \
				mkdir -p po/mo/$$l && \
				msgfmt -o po/mo/$$l/$$p.mo po/$$p/$$l.po && \
				echo "done"; \
		done; \
	done;

# Installation

install:
	install -m 0777 -d $(DESTDIR)/sbin
	install -m 0777 -d $(DESTDIR)/etc/X11
	install -m 0777 -d $(DESTDIR)$(PREFIX)/bin
	install -m 0777 -d $(DESTDIR)$(PREFIX)/sbin
	install -m 0777 -d $(DESTDIR)$(PREFIX)/share
	cp -a rootfs/etc $(DESTDIR)
	chmod +x $(DESTDIR)/etc/init.d/*
	cp -a rootfs/usr/share/licenses $(DESTDIR)$(PREFIX)/share
	# /sbin tools.
	for i in tazlocale tazkeymap tazhw hwsetup; do \
		install -m 0755 tinyutils/$$i $(DESTDIR)/sbin; \
	done;
	# Declare all config files.
	for file in etc/locale.conf etc/keymap.conf etc/TZ etc/X11/screen.conf; \
	do \
		touch $(DESTDIR)/$$file; \
	done;
	# /usr/bin tools.
	for app in tazx startx history tazdialog editor browser terminal file-manager; \
	do \
		install -m 0755 tinyutils/$$app $(DESTDIR)$(PREFIX)/bin; \
	done;
	# /usr/sbin sound tools.
	install -m 0755 tinyutils/soundconf $(DESTDIR)$(PREFIX)/sbin
	install -m 0755 tinyutils/setmixer $(DESTDIR)$(PREFIX)/sbin
	# Installer's
	install -m 0777 -d $(DESTDIR)$(PREFIX)/share/slitaz/messages/en
	install -m 0755 installer/slitaz-installer $(DESTDIR)$(PREFIX)/bin
	install -m 0755 installer/tazinst $(DESTDIR)$(PREFIX)/bin
	install -m 0644 messages/en/installer.msg \
		$(DESTDIR)$(PREFIX)/share/slitaz/messages/en

install-boxes:
	install -m 0777 -d $(DESTDIR)/etc/wireless
	install -m 0777 -d $(DESTDIR)$(PREFIX)/bin
	install -m 0777 -d $(DESTDIR)$(PREFIX)/lib/slitaz
	install -m 0777 -d $(DESTDIR)$(PREFIX)/share/locale
	install -m 0777 -d $(DESTDIR)$(PREFIX)/share/applications
	install -m 0777 -d $(DESTDIR)$(PREFIX)/share/pixmaps
	install -m 0777 -d $(DESTDIR)$(PREFIX)/share/doc
	install -m 0755 tinyutils/*box $(DESTDIR)$(PREFIX)/bin
	install -m 0755 tazbox/tazbox $(DESTDIR)$(PREFIX)/bin
	# Libs
	install -m 0755 lib/[a-z]* $(DESTDIR)$(PREFIX)/lib/slitaz
	# Desktop files, icons and doc.
	install -m 0644 rootfs/usr/share/applications/* \
		$(DESTDIR)$(PREFIX)/share/applications
	install -m 0644 rootfs/usr/share/pixmaps/* \
		$(DESTDIR)$(PREFIX)/share/pixmaps
	cp -a doc $(DESTDIR)$(PREFIX)/share/doc/slitaz-tools
	# i18n
	for l in $(LINGUAS); \
	do \
		install -m 0777 -d $(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
		install -m 0644 po/mo/$$l/* \
			$(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
	done;
	# Default English messages (will move to po)
	install -m 0777 -d $(DESTDIR)$(PREFIX)/share/slitaz/messages/en
	install -m 0644 messages/en/desktopbox.msg \
		$(DESTDIR)$(PREFIX)/share/slitaz/messages/en
	# Gksu fake for pcmanfm.
	cd $(DESTDIR)$(PREFIX)/bin && ln -s subox gksu
	
clean:
	rm -rf po/mo
	rm -f po/*/*.po~
