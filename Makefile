# Makefile for SliTaz tools.
# Check the README for more information.
#
PREFIX?=/usr
DOCDIR?=/usr/share/doc
DESTDIR?=

PROJECTS=slitaz-tools slitaz-boxes tazbox tazdrop
LINGUAS=el es fr pl pt_BR ru sv

all: msgfmt

help:
	@echo ""
	@echo "make: pot msgmerge msgfmt install install-boxes clean"
	@echo ""

# i18n.

tools-pot:
	@echo -n "Generating SliTaz Tools pot file... "
	@xgettext -o po/slitaz-tools/slitaz-tools.pot -L Shell -k_ -k_n \
		--package-name="SliTaz Tools" \
		./tinyutils/tazlocale ./tinyutils/tazkeymap ./tinyutils/setmixer \
		./tinyutils/tazx ./tinyutils/decode ./tinyutils/terminal \
		./tinyutils/hwsetup ./tinyutils/frugal
	@echo "done"

boxes-pot:
	@echo -n "Generating SliTaz Boxes pot file... "
	@xgettext -o po/slitaz-boxes/slitaz-boxes.pot -L Shell -k_ -k_n \
		--package-name="SliTaz Boxes" \
		./boxes/wifi-box ./boxes/burn-box ./boxes/scp-box
	@echo "done"

tazbox-pot:
	@echo -n "Generating tazbox pot file... "
	@xgettext -o po/tazbox/tazbox.pot -L Shell -k -k_ -k_n \
		--package-name="TazBox" ./tazbox/tazbox
	@echo "done"

tazdrop-pot:
	@echo -n "Generating tazdrop pot file... "
	@xgettext -o po/tazdrop/tazdrop.pot -L Shell -k_ -k_n \
		--package-name="TazDrop" ./tazdrop/tazdrop
	@echo "done"

pot: tools-pot boxes-pot tazbox-pot tazdrop-pot

msgmerge:
	@for p in $(PROJECTS); do \
		for l in $(LINGUAS); do \
			if [ -f "po/$$p/$$l.po" ]; then \
				echo "Updating $$p $$l po file."; \
				msgmerge -U po/$$p/$$l.po po/$$p/$$p.pot; \
			fi; \
		done; \
	done;

msgfmt:
	@for p in $(PROJECTS); do \
		for l in $(LINGUAS); do \
			if [ -f "po/$$p/$$l.po" ]; then \
				echo -e "Compiling $$p $$l mo file...\n"; \
				mkdir -p po/mo/$$l; \
				msgfmt -o po/mo/$$l/$$p.mo po/$$p/$$l.po; \
			fi; \
		done; \
	done;

# Installation

install: msgfmt
	install -m 0755 -d $(DESTDIR)/sbin
	install -m 0755 -d $(DESTDIR)/etc
	install -m 0755 -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 -d $(DESTDIR)$(PREFIX)/sbin
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share
	cp -a etc $(DESTDIR)/

	# Licenses
	cp -a licenses $(DESTDIR)$(PREFIX)/share

	# /sbin tools.
	for i in slitaz-config tazlocale tazkeymap tazhw hwsetup; do \
		install -m 0755 tinyutils/$$i $(DESTDIR)/sbin; \
	done;

	# Declare all config files.
	for file in etc/locale.conf etc/keymap.conf etc/TZ; \
	do \
		touch $(DESTDIR)/$$file; \
	done;

	# /usr/bin tools.
	for app in tazx startx history editor browser terminal file-manager \
		decode frugal startd stopd; \
	do \
		install -m 0755 tinyutils/$$app $(DESTDIR)$(PREFIX)/bin; \
	done;

	# /usr/sbin sound tools.
	install -m 0755 tinyutils/soundconf $(DESTDIR)$(PREFIX)/sbin
	install -m 0755 tinyutils/setmixer $(DESTDIR)$(PREFIX)/sbin

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
	install -m 0755 -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/applications
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/pixmaps
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/zoneinfo

	install -m 0755 boxes/* $(DESTDIR)$(PREFIX)/bin
	install -m 0755 tazbox/tazbox $(DESTDIR)$(PREFIX)/bin
	install -m 0755 tinyutils/subox $(DESTDIR)$(PREFIX)/bin
	install -m 0644 tazbox/iso3166-1.tab $(DESTDIR)$(PREFIX)/share/zoneinfo

	# Desktop files and icons.
	install -m 0644 applications/* $(DESTDIR)$(PREFIX)/share/applications
	install -m 0644 pixmaps/* $(DESTDIR)$(PREFIX)/share/pixmaps

	# i18n.
	for l in $(LINGUAS); \
	do \
		install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
		install -m 0644 po/mo/$$l/*box* \
			$(DESTDIR)$(PREFIX)/share/locale/$$l/LC_MESSAGES; \
	done;

	# Gksu fake for pcmanfm.
	cd $(DESTDIR)$(PREFIX)/bin && ln -fs subox gksu

clean:
	rm -rf po/mo
	rm -f po/*/*.po~
