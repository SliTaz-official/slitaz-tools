# Makefile for SliTaz tools.
# Check the README for more information.
#
PREFIX?=/usr
DOCDIR?=/usr/share/doc
DESTDIR?=
TOOLS?=scpbox tazbox tazdrop
TINYUTILS?=scpbox
LINGUAS?=fr pt_BR

all: msgfmt

# i18n.

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

tinyutils-pot: 
	@for p in $(TINYUTILS); do \
		echo -n "Generating $$p pot file... "; \
		xgettext -o po/$$p/$$p.pot -L Shell \
			--package-name=$$p tinyutils/$$p; \
		echo "done"; \
	done;

pot: tazbox-pot tazdrop-pot tinyutils-pot

msgmerge:
	@for p in $(TOOLS); do \
		for l in $(LINGUAS); do \
			echo -en "\rUpdating $$p $$l po file."; \
			[ -f "po/$$p/$$l.po" ] && \
				msgmerge -U po/$$p/$$l.po po/$$p/$$p.pot; \
		done; \
	done;

msgfmt:
	@for p in $(TOOLS); do \
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
	for file in etc/motd etc/locale.conf etc/keymap.conf etc/TZ \
		etc/X11/screen.conf; \
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
