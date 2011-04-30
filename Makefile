# Makefile for SliTaz tools.
# Check the README for more information.
#
PREFIX?=/usr
DOCDIR?=/usr/share/doc
DESTDIR?=
TOOLS?=scpbox tazbox tazdrop
TINYUTILS?=scpbox
LINGUAS?=fr pt
	
all:

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
			echo -n "Compiling $$p $$l mo file... "; \
			mkdir -p po/mo/$$l; \
			[ -f "po/$$p/$$l.po" ] && msgfmt -o po/mo/$$l/$$p.mo po/$$p/$$l.po; \
			echo "done"; \
		done; \
	done;

clean:
	rm -rf po/mo
	rm -f po/*/*.po~
