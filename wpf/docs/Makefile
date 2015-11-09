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
	@pandoc $(PANDOC_FLAGS) --standalone --template=$(PANDOC_TEMPLATE) --from=markdown --latex-engine=xelatex --to=latex $< -o $@

%.html: %.md
	$(info [DOC] $< -> $@)
	@pandoc $(PANDOC_FLAGS) --standalone --from=markdown --latex-engine=xelatex --to=html $< -o $@

%.dia.png: %.dia
	$(info [IMG] $< -> $@)
	@dia -e $@ $< -l

.PHONY: clean
clean:
	$(RM) $(GENERATED_IMAGES) manual.pdf
