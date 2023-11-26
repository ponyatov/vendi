# var
MODULE  = $(notdir $(CURDIR))
OS      = $(shell uname -s)

# version
JQUERY_VER    = 3.7.1
JQUERY_UI_VER = 1.13.2
DARK_HIVE_VER = 1.13.2

# dir
CWD = $(CURDIR)
BIN = $(CWD)/bin
DOC = $(CWD)/doc
SRC = $(CWD)/src
TMP = $(CWD)/tmp
GZ  = $(HOME)/gz

# tool
CURL = curl -L -o
DC   = dmd
BLD  = dub build --compiler=$(DC)
RUN  = dub run   --compiler=$(DC)

# src
D += $(wildcard src/*.d)
J += $(wildcard dub*.json)
T += $(wildcard views/*)

# all
.PHONY: all run
all: bin/$(MODULE)
bin/$(MODULE): $(D) $(J) $(T)
	$(BLD)
run: $(D) $(J) $(T)
	$(RUN)

# format
format: tmp/format_d
tmp/format_d: $(D)
	$(RUN) dfmt -- -i $? && touch $@

# doc
doc: doc/yazyk_programmirovaniya_d.pdf doc/Programming_in_D.pdf \
     doc/BuildWebAppsinVibe.pdf doc/BuildTimekeepWithVibe.pdf

doc/yazyk_programmirovaniya_d.pdf:
	$(CURL) $@ https://www.k0d.cc/storage/books/D/yazyk_programmirovaniya_d.pdf
doc/Programming_in_D.pdf:
	$(CURL) $@ http://ddili.org/ders/d.en/Programming_in_D.pdf
doc/BuildWebAppsinVibe.pdf:
	$(CURL) $@ https://raw.githubusercontent.com/reyvaleza/vibed/main/BuildWebAppsinVibe.pdf
doc/BuildTimekeepWithVibe.pdf:
	$(CURL) $@ https://raw.githubusercontent.com/reyvaleza/vibed/main/BuildTimekeepWithVibe.pdf

# install
.PHONY: install update gz
install: gz
	$(MAKE) update
update:
	sudo apt update
	sudo apt install -uy `cat apt.$(OS)`

gz: static/cdn/jquery.js static/cdn/jquery-ui.js static/cdn/dark-hive.css

static/cdn/jquery.js:
	$(CURL) $@ https://code.jquery.com/jquery-$(JQUERY_VER).min.js
static/cdn/jquery-ui.js:
	$(CURL) $@ https://code.jquery.com/ui/$(JQUERY_UI_VER)/jquery-ui.min.js
static/cdn/dark-hive.css:
	$(CURL) $@ https://code.jquery.com/ui/$(DARK_HIVE_VER)/themes/dark-hive/jquery-ui.css

# merge
MERGE += Makefile README.md LICENSE $(D) $(J)
MERGE += .clang-format .editorconfig .gitattributes .gitignore
MERGE += apt.Linux
MERGE += bin doc src tmp public views

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
#	$(MAKE) doxy ; git add -f docs

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip:
	git archive --format zip --output $(ZIP) HEAD
