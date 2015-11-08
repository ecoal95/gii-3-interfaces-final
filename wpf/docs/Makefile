DIAGRAMS := $(wildcard img/*.dia)
GENERATED_IMAGES := $(DIAGRAMS:.dia=.dia.png)
PANDOC_TEMPLATE ?= template.latex


.PHONY:
docs: $(GENERATED_IMAGES) manual.pdf
	@echo > /dev/null

ifeq ($(PANDOC_FLAGS),)
PANDOC_FLAGS := --toc --filter pandoc-crossref
endif

%.pdf: %.md
	$(info [DOC] $< -> $@)
	@pandoc $(PANDOC_FLAGS) --template=$(PANDOC_TEMPLATE) --from=markdown --latex-engine=xelatex --to=latex $< -o $@

%.dia.png: %.dia
	$(info [IMG] $< -> $@)
	@dia -e $@ $< -l
