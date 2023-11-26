# var
MODULE  = $(notdir $(CURDIR))
OS      = $(shell uname -s)

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

# all
.PHONY: all run
all: bin/$(MODULE)
bin/$(MODULE): $(D) $(J)
	$(BLD)
run: $(D) $(J)
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
gz:


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
