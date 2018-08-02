---
author: James Overton & Becky Tauber
title: ROBOT Tutorial
---

# Manual Editing

## Status Quo

- development mainly done in Protégé
- requires manual editing and review

## The Solution

- ROBOT lets us automate many of those tasks
- ... and provides better quality assurance!

# ROBOT for Repetitive Tasks

---

<h3>merge</h3>
<h3>reason</h3>
<h3>annotate</h3>
<h3>convert</h3>

---

## Merge

1. merge two separate ontologies
2. merge imports into one ontology

---

### Merge Separate Ontologies

```
robot merge --input edit.owl \
  --input foo.owl \
  --collapse-import-closure false \
  --output results/merged.owl
```

---

### Merge Imports

```
robot merge --input edit.owl \
  --collapse-import-closure true \
  --output results/merged_imports.owl
```

## Reason

1. logical validation
2. automatic classification

---

### Reasoners

- ELK: a very fast reasoner, but not as powerful as HermiT
- HermiT: optimized to classify complex ontologies
- EMR: materializes anonymous expressions
- Structural: a simple reasoner

---

### Logical Validation

```
robot reason --input inconsistent.owl
```

---

### Automatic Classification

```
robot reason --input non-reasoned.owl \
  --output results/reasoned.owl
```

## Annotate

1. add metadata to an ontology for release

---

### Add Metadata

```
robot annotate --input edit.owl \
  --ontology-iri https://github.com/ontodev/robot/edit.owl \
  --version-iri \
    https://github.com/ontodev/robot/releases/2018-08-07/edit.owl \
  --annotation oboInOwl:date "08:07:2018 12:00" \
  --output results/annotated.owl
```

## Convert

1. convert an editor's file to verbose RDF/XML
2. convert a released ontology to OBO

---

### Ontology Formats

- default format is RDF/XML but...
- ontologies are shared in many formats
  - OWL functional
  - OBO
  - Turtle
  - and more...

---

### Convert the Edit File

```
robot convert --input edit.owl \
  --format owl \
  --output results/release.owl
```

---

### Convert to OBO

```
robot convert --input edit.owl \
  --output results/release.obo
```

<small><small>**NOTE**: You do not always need to include the `--format` if the extension of the `--output` matches the desired format.</small></small>

# Automated Workflows

## Chaining Commands

<small>Output ontologies can be used as the input to subsequent commands. Only the first command uses an `--input`, and only the last command uses an `--output`.</small>

```
robot merge --input edit.owl --collapse-import-closure true \
  reason --reasoner ELK --create-new-ontology false \
  annotate --version-iri \
  http://purl.obolibrary.org/obo/robot/2018-08-07/release.owl \
  convert --output results/chained_release.obo
```

## Makefiles

<small>A Makefile contains a set of rules to make target objects.<br>Here, we use it to create the release files.</small>

```
make release
```

# Quality Assurance

---

<h3>diff</h3>
<h3>query (part 1)</h3>
<h3>verify</h3>
<h3>report</h3>

---

## Diff

1. compare the axioms in two version of an ontology

---

### Compare Axioms

```
robot diff --left non-reasoned.owl \
  --right results/reasoned.owl \
  --output results/diff.txt
```

<small><small>**NOTE**: If you do not include an `--output`, the results will be printed to the terminal.</small></small>

## Query

1. run a SPARQL SELECT query
2. run a SPARQL ASK query

---

### Select Query

<small>SELECT queries can be useful for statistics on the ontology, and for sharing data. For example, you could get a list of all the terms containing just the IDs and labels.</small>

```
robot query --input edit.owl \
  --query select.rq results/select.tsv
```

---

### Ask Query

<small>ASK queries can help determine if something exists in the ontology or not. For example, if you want to make sure that "trunk" is in the "vertebrate core" subset.</small>

```
robot query --input edit.owl \
  --query ask.rq results/ask.txt
```

## Verify

1. perform a successful verification
2. perform an unsuccessful verification

---

### Successful Verification

<small>Sometimes, classes can be accidentally orphaned. This verification ensures that all classes, aside from the top-level "anatomical entity", have asserted parents. If they do not, the verification fails.</small>

```
robot verify --input edit.owl \
  --queries verify.rq \
  --output-dir results
```

---

### Unsuccessful Verification

<small>This verify query checks that all classes have an equivalent class statement. In our edit ontology, only some of the classes have equivalent classes, so this will fail.</small>

```
robot verify --input edit.owl \
  --queries verify_fail.rq \
  --output-dir results
```


## Report

1. run a series of SPARQL queries to find common violations

---

### Violations

- annotation, logical, or metadata violations
- three logging levels: ERROR, WARN, and INFO

---

### Generate a Report

```
robot report --input edit.owl --output results/report.tsv
```

## Continuous Integration

- Travis CI automatically builds and tests changes pushed to GitHub
- Often uses `make test` from the Makefile
- If any part of the test fails, the build will fail

# Modular Development

---

<h3>extract</h3>
<h3>template</h3>

---

## Extract

1. create an import module with SLME
2. create an import module with MIREOT

---

### Import Modules

- many bioontologies use terms from external sources
- these sources contain more terms than needed
- extract ensures the necessary terms and their dependencies are included in module

---

### Extract with SLME

<small>
STAR: fixpoint-nested<br>
BOT: bottom module<br>
TOP: top module
</small>

```
robot extract \
  --input-iri http://purl.obolibrary.org/obo/obi.owl \
  --term OBI:0000443 \
  --method BOT \
  --output results/obi_bot.owl
```

<small><small>**NOTE**: You can also include a list of terms to extract in a text file with `--term-file`.</small></small>

---

### Extract with MIREOT

<small>
Creates a simple hierarchy of terms.<br>
Requires lower term(s) and optional upper term(s).
</small>

```
robot extract \
  --input-iri http://purl.obolibrary.org/obo/obi.owl \
  --method MIREOT \
  --lower-terms obi_terms.txt \
  --output results/obi_mireot.owl
```

<small><small>**NOTE**: Without specifiying any `--upper-terms`, the MIREOT method will include all ancestors up to `owl:Thing`.<br>
**NOTE 2**: To just specify *one* term to extract, use `--lower-term`</small></small>

## Template

1. create a module
2. add a class to an ontology

---

### Create a Module

<small>This will create a standalone module that can be included in the edit file with an import statement. To update the module, editors only need to update the spreadsheet and run this command to remake the module.</small>

```
robot template --input edit.owl \
  --template module.tsv \
  --output results/module.owl
```

<small><small>**NOTE**: `template` gets all the entity labels from `edit.owl` so we are able to use the labels in the spreadsheet, instead of always specifying the ID. If we didn't include the `--input`, the labels would not resolve.</small></small>

---

### Add a Class to an Ontology

<small>For one-time class creation (especially if many classes need to be created), a temporary template can be created and the results immediately merged into the edit ontology.</small>

```
robot template --input edit.owl \
  --merge-before \
  --collapse-import-closure false \
  --template new_class.tsv \
  --output results/new_class.owl
```

<small><small>**NOTE**: because the edit ontology already contains import statements, we don't want these to be merged in so we need to include `--collapse-import-closure false`.</small></small>

# Modular Releases

---

<h3>query (part 2)</h3>
<h3>remove</h3>
<h3>filter</h3>

---

## Querying with SPARQL CONSTRUCT

- CONSTRUCT produces RDF data in Turtle format
- allows creation of new sets of triples

---

### Update Annotations with CONSTRUCT

```
robot query --input edit.owl \
  --query construct.rq construct.ttl 
```

<small><br>The `construct.ttl` file isn't much use on its own; we need to merge it:</small>

```
robot merge --input edit.owl \
  --input construct.ttl \
  --output results/update.owl
```

## Remove

1. remove a class and its descendants
2. create a 'simple' version of an ontology

---

### Configuration

- remove a term (or terms) from an ontology and any related terms
- highly configurable `--select` option to remove related terms
- specify types of axioms to remove with `--axioms`

---

### Remove a Class + Descendants

```
robot remove --input edit.owl \
  --entity UBERON:0000475 \
  --select "self descendants" \
  --output results/removed.owl
```

---

### Create a 'Simple' Version

```
robot remove --input edit.owl \
  --axioms equivalent \
  remove --select parents --select anonymous \
  --output results/simple.owl
```

## Filter

1. extract a branch of an ontology
2. create a subset based on annotations

---

### Extract a Branch

```
robot filter --input edit.owl \
  --entity UBERON:0000475 \
  --select self --select descendants --select annotations \
  --output results/branch.owl
```

---

### Create a Subset

```
robot filter --select \
  "oboInOwl:inSubset= \
   <http://purl.obolibrary.org/obo/uberon/core#uberon_slim>" \
  --output results/uberon_slim.owl
```

<small><small>**NOTE**: selecting for annotations is highly configurable:<br>
`CURIE=CURIE`<br>
`CURIE="literal"^^datatype`<br>
`CURIE=<IRI>`<br>
`CURIE=~"regex pattern"`</small></small>

# Other Commands

---

<h3>materialize</h3>
<h3>&nbsp;mirror&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;reduce</h3>
<h3>&nbsp;&nbsp;relax&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;repair</h3>
<h3>unmerge&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;validate</h3>

# Questions?

