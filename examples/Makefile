# CONFIG
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

# MAIN TASKS

release: test build subsets
test: verify

# VARIABLES

DATE = $(shell date +'%Y-%m-%d')
EDIT = edit.owl
ONT = ont
OBO = http://purl.obolibrary.org/obo/
RELEASE = $(DATE)
REPORT = $(RELEASE)/report
SUB = $(RELEASE)/subsets
SUBS = efo_slim uberon_slim upper_level
TS = $(shell date +'%m:%d:%Y %H:%M')

init:
	mkdir $(DATE) \
	&& mkdir $(SUB) \
	&& mkdir $(REPORT)

# TEST

# This runs a verification query
.PHONY: verify
verify: | init
	robot verify --input $(EDIT)\
	 --queries verify.rq --output-dir $(REPORT)

# MAIN RELEASE

build: $(DATE)/$(ONT).owl $(DATE)/$(ONT).obo | init

# This creates the main release file (ont.owl)
$(DATE)/$(ONT).owl: $(EDIT)
	robot merge --input $< --collapse-import-closure true \
	reason --create-new-ontology false\
	 --annotate-inferred-axioms true --exclude-duplicate-axioms true \
	annotate --version-iri "$(OBO)robot/releases/$(DATE)/$(ONT).owl"\
	 --annotation oboInOwl:date "$(TS)" --output $@

# This creates the OBO release file (ont.obo)
$(DATE)/$(ONT).obo: $(DATE)/$(ONT).owl
	robot convert --input $< --format obo\
	 --output $(basename $@)-temp.obo && \
	grep -v ^owl-axioms $(basename $@)-temp.obo > $@ && \
	rm $(basename $@)-temp.obo

# SUBSETS

# This generates the three subset files
.PHONY: subsets
subsets: $(SUBS) | init
$(SUBS): $(DATE)/$(ONT).owl
	robot filter --input $< \
	 --select "oboInOwl:inSubset=<http://purl.obolibrary.org/obo/uberon/core#$@> annotations"\
	 annotate --version-iri "$(OBO)robot/$(DATE)/subsets/$@.owl"\
	 --ontology-iri "$(OBO)robot/subsets/$@.owl"\
	 --output $(addprefix $(SUB)/, $(addsuffix .owl, $@))
