# Makefile for SliTaz tools.
# Check the README for more information.
#
PREFIX?=/usr
DOCDIR?=/usr/share/doc
DESTDIR?=

PROJECTS=slitaz-tools slitaz-boxes tazbox tazinst tazdrop
LINGUAS=es_AR fr pt_BR

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
		./tinyutils/tazlocale ./tinyutils/tazkeymap ./tinyutils/setmixer \
		./tinyutils/tazx ./tinyutils/decode
	@echo "done"

boxes-pot:
	@echo -n "Generating SliTaz Boxes pot file... "
	@xgettext -o po/slitaz-boxes/slitaz-boxes.pot -L Shell \
		--package-name="SliTaz Boxes" \
		./boxes/wifi-box ./boxes/burn-box
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

tazinst-pot:
	@echo -n "Generating tazinst pot file... "
	@xgettext -o po/tazinst/tazinst.pot -L Shell \
		--package-name="Tazinst" ./installer/tazinst
	@echo "done"

pot: tools-pot boxes-pot tazbox-pot tazdrop-pot tazinst-pot

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
	install -m 0755 -d $(DESTDIR)/sbin
	install -m 0755 -d $(DESTDIR)/etc
	install -m 0755 -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 -d $(DESTDIR)$(PREFIX)/sbin
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share
	cp -a etc $(DESTDIR)/

	# Licenses
	cp -a licenses $(DESTDIR)$(PREFIX)/share

	# /sbin tools.
	for i in tazlocale tazkeymap tazhw hwsetup; do \
		install -m 0755 tinyutils/$$i $(DESTDIR)/sbin; \
	done;

	# Declare all config files.
	for file in etc/locale.conf etc/keymap.conf etc/TZ; \
	do \
		touch $(DESTDIR)/$$file; \
	done;

	# /usr/bin tools.
	for app in tazx startx history editor browser terminal file-manager; \
	do \
		install -m 0755 tinyutils/$$app $(DESTDIR)$(PREFIX)/bin; \
	done;

	# /usr/sbin sound tools.
	install -m 0755 tinyutils/soundconf $(DESTDIR)$(PREFIX)/sbin
	install -m 0755 tinyutils/setmixer $(DESTDIR)$(PREFIX)/sbin

	# tazinst
	install -m 0755 installer/tazinst $(DESTDIR)$(PREFIX)/sbin
	for l in $(LINGUAS); do \
		for i in `ls po/mo/$$l/tazinst.mo` ; do \
			install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
			install -m 0644 po/mo/$$l/tazinst.mo \
				$(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
		done \
	done

	# slitaz-tools i18n
	for l in $(LINGUAS); \
	do \
		install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
		install -m 0644 po/mo/$$l/slitaz-tools.mo \
			$(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
	done;

	# Permissions
	chmod +x $(DESTDIR)/etc/init.d/*

install-boxes:
	#install -m 0755 -d $(DESTDIR)/etc/wireless
	install -m 0755 -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 -d $(DESTDIR)$(PREFIX)/lib/slitaz
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/applications
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/pixmaps
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/doc/slitaz
	install -m 0755 boxes/* $(DESTDIR)$(PREFIX)/bin
	install -m 0755 tazbox/tazbox $(DESTDIR)$(PREFIX)/bin

	# Libs
	#install -m 0755 lib/*.* $(DESTDIR)$(PREFIX)/lib/slitaz

	# Desktop files and icons.
	install -m 0644 applications/* $(DESTDIR)$(PREFIX)/share/applications
	install -m 0644 pixmaps/* $(DESTDIR)$(PREFIX)/share/pixmaps

	# Documentation (style is already in slitaz-doc)
	cp -a doc/*.html $(DESTDIR)$(PREFIX)/share/doc/slitaz

	# i18n.
	for l in $(LINGUAS); \
	do \
		install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
		install -m 0644 po/mo/$$l/*box* \
			$(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
	done;

	# Gksu fake for pcmanfm.
	cd $(DESTDIR)$(PREFIX)/bin && ln -s subox gksu

clean:
	rm -rf po/mo
	rm -f po/*/*.po~
