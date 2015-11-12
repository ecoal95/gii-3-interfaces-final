DIAGRAMS := $(wildcard img/*.dia)
GENERATED_IMAGES := $(DIAGRAMS:.dia=.dia.png)
PANDOC_TEMPLATE ?= template.latex

TARGETS := programmers-manual.pdf users-manual.pdf

.PHONY:
docs: $(GENERATED_IMAGES) $(TARGETS)
	@echo > /dev/null

programmers-manual.pdf: bibliography.bib


ifeq ($(PANDOC_FLAGS),)
PANDOC_FLAGS := -s --toc
endif

ifeq ($(DEBUG),)
MAYBE_QUIET := >/dev/null 2>&1
endif

%.pdf: %.md
	$(info [DOC] $< -> $@)
	@pandoc $(PANDOC_FLAGS) --biblatex --template=$(PANDOC_TEMPLATE) --from=markdown --latex-engine=xelatex --to=latex $< -o $@.tex
	@xelatex $@.tex $(MAYBE_QUIET)
	@biber $@ $(MAYBE_QUIET)
	@xelatex $@.tex $(MAYBE_QUIET)
	@xelatex $@.tex $(MAYBE_QUIET)
	@mv $@.pdf $@
	@$(RM) $@.* $@-*

%.html: %.md
	$(info [DOC] $< -> $@)
	@pandoc $(PANDOC_FLAGS) --standalone --from=markdown --latex-engine=xelatex --to=html $< -o $@

%.dia.png: %.dia
	$(info [IMG] $< -> $@)
	@dia -e $@ $< -l

.PHONY: clean
clean:
	$(RM) $(GENERATED_IMAGES) $(TARGETS) *.pdf *.dia.png *.aux *.tex *.log *.out *.toc

