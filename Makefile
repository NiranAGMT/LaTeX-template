#SILENT:="-silent"
SILENT:=-interaction=batchmode
SYNCTEX:=1

TEXVERSIONS=$(shell ls /usr/local/texlive/ | fgrep -v texmf-local)

B:=main
F:=-time -shell-escape -synctex=$(SYNCTEX) -output-format=pdf -output-directory=output -file-line-error $(FLAGS)
T:=$(B).pdf
S:=$(B).tex
L:=latexmk $(F)
V:=open -a skim

ZIPFILES:=NOVAthesisFiles bibliography config chapters LICENSE Makefile novathesis.cls README.md .gitignore main.tex latexmkrc
VERSION:=$(shell head -1 NOVAthesisFiles/nt-version.sty | sed -e 's/.*{//' -e 's/\(.*\)./\1/')
DATE:=$(shell tail -1 NOVAthesisFiles/nt-version.sty | sed -e 's/.*{//' -e 's/\(.*\)./\1/' | tr '\n' '@'m| sed -e 's/\(.*\)./\1/')
ZIPTARGET:=$(B)-$(VERSION)@$(DATE).zip
PDF_OUTP = output/main.pdf

copy_pdf: $(PDF_OUTP)
	cp $(PDF_OUTP) .

DIRS:= . output
define CLEAN_FILES
$(shell cd $1 && ls $(B)*.* | fgrep -v .tex | fgrep -v $(B).pdf | sed 's: :\\ :g' | sed 's:(:\\(:g' | sed 's:):\\):g')
endef

LUA="other/esep uminho/ea uminho/ec uminho/ed uminho/ee uminho/eeg uminho/elach uminho/em uminho/ep uminho/ese uminho/ics uminho/ie uminho/i3b"
SCHL=$(shell grep -v "^%" config/1_novathesis.tex | grep "ntsetup{school=" | cut -d "=" -f 2 | cut -d "}" -f 1)
ifeq ($(SCHL),)
	SCHL=nova/fct
endif




default:
	@echo SCHL=$(SCHL)
ifeq ($(findstring $(SCHL),$(LUA)),)
	make lua
else
	make xe
endif


$(T): $(S)
	$(MAKE)

.PHONY: pdf
pdf: $(S) copy_pdf
	$(L) -pdf $(SILENT) $(B)

.PHONY: xe lua
xe lua: $(S) copy_pdf
	$(L) -pdf$@ $(SILENT) $(B)

.PHONY: v view
v view: $(T)
	$(V) $(T)

.PHONY: vv verb verbose
vv verb verbose:
	$(L) -pdf $(B)

.PHONY: $(TEXVERSIONS)
$(TEXVERSIONS):
	hash -r
	PATH="$(wildcard /usr/local/texlive/$@/bin/*-darwin/):$(PATH)" make $(filter-out $@,$(MAKECMDGOALS))

.PHONY: mik
mik:
	hash -r
	# echo $(filter-out mik,$(MAKECMDGOALS))
	PATH="$(HOME)/bin:$(PATH)" make $(filter-out $@,$(MAKECMDGOALS))
	
.PHONY: zip
zip:
	rm -f "$(ZIPTARGET)"
	zip --exclude .github --exclude .git --exclude .vscode -r "$(ZIPTARGET)" $(ZIPFILES)

.PHONY: clean
clean:
	@$(L) -c $(B)
	@$(foreach dir, $(DIRS), rm -f $(addprefix $(dir)/, $(call CLEAN_FILES, $(dir))) "$(dir)/*(1)*";)
	@find . -name .DS_Store -o -name '_minted*' -print0 | xargs -0 rm -rf

gclean:
	git clean -fdx -e Scripts -e Fonts

.PHONY: rc
rc:
	Scripts/latex-clean-temp.sh

.PHONY: rcb
rcb:
	Scripts/latex-clean-temp.sh
	rm -rf `biber -cache`
	biber -cache

.PHONY: publish
publish:
	Scripts/publish.sh

.PHONY: bump1 bump2 bump3
bump1:
	Scripts/newversion.sh 1
	$(MAKE) publish

bump2:
	Scripts/newversion.sh 2
	$(MAKE) publish

bump3:
	Scripts/newversion.sh 3
	$(MAKE) publish

tag:
	@echo Tagging as $(VERSION)
	# @echo $(DATE)
	git co main
	git tag -a "$(VERSION)"
	git push origin --tags
	git co develop
