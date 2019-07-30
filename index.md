---
author: James Overton & Becky Tauber
title: ROBOT Tutorial
---

# Overview

--- 

- Manual editing
- Repetitive tasks
- Automated workflows
- Quality assurance
- Modular development
- Modular releases
- Other commands

# Manual Editing

## Status Quo

- development mainly done in Protégé
- requires manual editing and review

## The Solution

- ROBOT lets us automate many of those tasks
- ... and provides better quality assurance!

## ROBOT Releases

- v1.0.0 released Feb 8, 2018 ...
- v1.4.0 released Mar 15, 2019
- v1.4.1 released Jun 27, 2019

## Cite ROBOT

R.C. Jackson, J.P. Balhoff, E. Douglass, N.L. Harris, C.J. Mungall, and J.A. Overton. **[ROBOT: A tool for automating ontology workflows](https://rdcu.be/bMnHT)**. BMC Bioinformatics, vol. 20, July 2019.

## Let's get started!

- download the **[tutorial repository](https://github.com/rctauber/robot-tutorial)**
- get the latest ROBOT via Docker:
  - `sh run.sh robot --version`
- or install it following **[the documentation](http://robot.obolibrary.org/)**
- navigate to examples: `cd examples`
  - if using Docker, start each command with `sh ../run.sh`

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
  --output results/merged.owl
```

---

### Merge Imports

<small>ROBOT will automatically merge imports. To *not* merge imports, include `--collapse-import-closure false`. This option is not supported in v1.0.0.</small>

```
robot merge --input with-import.owl \
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

<small>Validates that the ontology contains no unsatisfiable entities and that it is not inconsistent.</small>

```
robot reason --input unsatisfiable.owl
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
  --version-iri \
    https://github.com/ontodev/robot/releases/2019-07-31/edit.owl \
  --annotation oboInOwl:date "07:31:2019 12:00" \
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

<small><small>**NOTE**: OWL functional syntax is defined by the suffix `.ofn` - if you want to convert to that format, use `--format ofn` or an output ending in `.ofn`. The `.owl` suffix can be used to represent any OWL ontology. Using `--format owl` or excluding the `--format` option and specifying an output with `.owl` will convert to RDF/XML.</small></small>

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
  reason --reasoner ELK \
  annotate --version-iri http://purl.obolibrary.org/obo/robot/2018-08-07/release.owl \
  convert --output results/chained_release.ttl
```

## Makefiles

<small>A Makefile contains a set of rules to make target objects.<br>Here, we use it to create the release files.</small>

```
make release
```

<small><small>**NOTE**: This Makefile will fail on v1.0.0 and v1.1.0 - alternatively, run `make build`.</small></small>

# Quality Assurance

---

<h3>diff</h3>
<h3>query (part 1)</h3>
<h3>verify</h3>
<h3>report</h3>

---

## Diff

1. compare the axioms in two version of an ontology
2. generate a summary page of changes

<small>`diff` supports different formats:

- `plain`: default, shows removed and added axioms
- `pretty`: plain, plus entity labels for IRIs
- `html`: HTML summary page (easy for humans!)
- `markdown`: markdown summary (great for GitHub!)

</small>

---

### Compare Axioms (Default)

```
robot diff --left non-reasoned.owl \
  --right results/reasoned.owl \
  --output results/diff.txt
```

<small><small>**NOTE**: If you do not include an `--output`, the results will be printed to the terminal.</small></small>

---

### Human-Readable Diff

```
robot diff --left non-reasoned.owl \
  --right results/reasoned.owl \
  --format html \
  --output results/diff.html
```

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

<small><small>**NOTE**: You can also include a list of terms to extract in a text file with `--term-file`.<br>
**NOTE 2**: To use a local file, use `--input <file>` instead of `--input-iri`.</small></small>

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
  --ontology-iri http://purl.obolibrary.org/obo/robot/module.owl \
  --output results/module.owl
```

<small><small>**NOTE**: `template` gets all the entity labels from `edit.owl` so we are able to use the labels in the spreadsheet, instead of always specifying the ID. If we didn't include the `--input`, the labels would not resolve.</small></small>

---

### Add a Class to an Ontology

<small>For one-time class creation (especially if many classes need to be created), a temporary template can be created and the results immediately merged into the edit ontology.</small>

```
robot template --input edit.owl --merge-before \
  --template new_class.tsv \
  --output results/new_class.owl
```

<small><small>**NOTE**: if your ontology includes imports, use `--collapse-import-closure false` with any merge option to maintain the closure.</small></small>

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
  --query construct.rq results/construct.ttl \
  merge --input results/construct.ttl \
  --output results/construct.owl
```

<small>The `construct.ttl` file isn't much use on its own; we need to merge it. For `query`, the output ontology is the *unchanged* input ontology, so we can chain this with the `merge` command to merge `construct.ttl`.</small>

---

## Querying with SPARQL UPDATE

- UPDATE changes the RDF data and outputs an updated ontology
- allows deletion and insertion of triples
- no need to merge after running the UPDATE

---

### Update Annotations with UPDATE

```
robot query --input edit.owl \
  --update update.ru \
  --output results/updated.owl
```

<small>Here, we replace 'definition' (`IAO:0000115`) with 'external_definition' (`UBPROP:0000001`) for all UBERON terms.</small>

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
  --term UBERON:0000475 \
  --select "self descendants" \
  --output results/removed.owl
```

---

### Create a 'Simple' Version

```
robot remove --input edit.owl \
  --axioms equivalent \
  remove --select parents --select anonymous --select imports \
  --output results/simple.owl
```

<small><small>**NOTE**: `--select` accepts a string of options, or can be passed multiple times. For a string of options (previous example) the selected set is the union of all options (both the input term and all descendants of the term). For passing in multiple select options (as above), the options are processed in order (first the parents are selected, and then only the anonymous parents are selected).</small></small>

## Filter

Released with v1.2.0-alpha - previously, `filter` only filtered for object properties.

1. extract a branch of an ontology
2. create a subset based on annotations

---

### Extract a Branch

```
robot filter --input edit.owl \
  --term UBERON:0000475 \
  --select "self descendants annotations" \
  --output results/branch.owl
```

<small><small>**NOTE**: in order to include annotations on the filtered entities, `--select annotations` must be included. Otherwise, you muist include *all* annotation properties in the set of input terms.</small></small>

---

### Create a Subset

```
robot filter --input edit.owl \
  --select \
  "oboInOwl:inSubset=<http://purl.obolibrary.org/obo/uberon/core#uberon_slim>" \
  --select annotations \
  --output-iri http://purl.obolibrary.org/robot/uberon_slim.owl
  --output results/uberon_slim.owl
```

<small><small>**NOTE**: selecting for annotations is highly configurable:<br>
`CURIE=CURIE`<br>
`CURIE="literal"^^datatype`<br>
`CURIE=<IRI>`<br>
`CURIE=~"regex pattern"`</small></small>

# Other Commands

---

<h3>explain&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;materialize</h3>
<h3>&nbsp;mirror&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;reduce</h3>
<h3>&nbsp;&nbsp;relax&nbsp;&nbsp;&nbsp;&nbsp;rename&nbsp;&nbsp;&nbsp;&nbsp;repair</h3>
<h3>unmerge&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;validate</h3>

# Questions?

