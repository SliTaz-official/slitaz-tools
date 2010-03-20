# Makefile for SliTaz tools.
# Check the README for more information.
#
PREFIX?=/usr
DOCDIR?=/usr/share/doc
DESTDIR?=
TINYUTILS?=subox scpbox
LINGUAS?=fr pt

all:

# i18n.

pot:
	@for p in $(TINYUTILS); do \
		echo -n "Generating $$p pot file... "; \
		xgettext -o po/$$p/$$p.pot -L Shell --package-name=$$p tinyutils/$$p; \
		echo "done"; \
	done;

msgmerge:
	@for p in $(TINYUTILS); do \
		for l in $(LINGUAS); do \
			echo -n "Updating $$p $$l po file."; \
			msgmerge -U po/$$p/$$l.po po/$$p/$$p.pot ; \
		done; \
	done;

msgfmt:
	@for p in $(TINYUTILS); do \
		for l in $(LINGUAS); do \
			echo -n "Compiling $$p $$l mo file... "; \
			mkdir -p po/mo/$$l; \
			msgfmt -o po/mo/$$l/$$p.mo po/$$p/$$l.po ; \
			echo "done"; \
		done; \
	done;

clean:
	rm -rf po/mo
