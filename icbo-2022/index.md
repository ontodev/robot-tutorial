---
author: Becky Jackson
title: ROBOT Tutorial
---

# Overview

---

- What is ROBOT?
- Basic tasks
- Ontology development
- Ontology releases



# What is ROBOT?

---

*A command-line tool and Java library for automating ontology development tasks.*

---

**ROBOT has 27 different commands!**

We will only look at some of the most commonly-used commands in this tutorial.

---

Docs for all commands are available at [http://robot.obolibrary.org](http://robot.obolibrary.org)

---

## 20 ROBOT Releases

- v1.0.0 released Feb 8, 2018 ...
- v1.9.0 released Jun 16, 2022

---

## Cite ROBOT

R.C. Jackson, J.P. Balhoff, E. Douglass, N.L. Harris, C.J. Mungall, and J.A. Overton.

**[ROBOT: A tool for automating ontology workflows](https://rdcu.be/bMnHT)**.

BMC Bioinformatics, vol. 20, July 2019.

---

## Basic Usage

```
robot help [command]
```

```
robot [command] --input [file] ... --output [file]
```


# Basic Tasks

---

## How do you see what is stated in your ontology?

---

`export`

* [http://robot.obolibrary.org/export](http://robot.obolibrary.org/export)
* `--input`: input ontology
* `--header`: fields to include in the export
* `--export`: output export file

---

### Export Header

* Separate fields with pipe (`|`)
* Special values
	* `IRI` / `ID`
	* `LABEL` / `SYNONYMS`
	* `SubClass Of` / `SubClasses`
	* `Type`
* Properties
	* `IAO:0000115` / `definition`

---

### Get a table of parents

```
robot export --input edit.owl \
  --header "ID|LABEL|SubClass Of" \
  --export results/export.csv
```

<small>The `ID` column will always contain CURIEs and the `LABEL` column will always contain labels, but other values are rendered by their label when possible.</small>

---

### Get a table of parents using IDs

```
robot export --input edit.owl \
  --header "ID|SubClass Of" \
  --entity-format ID \
  --export results/export-parents.csv
```

<small>You can set the rendering for all entity references with `--entity-format`:<br>`ID`, `IRI`, `LABEL`, `NAME`</small>

---

### Get a table of IDs, labels, and definitions

```
robot export \
  --input edit.owl \
  --header "ID|LABEL|definition" \
  --export results/export-definitions.csv
```

<small>Annotations will always contain the literal values.<br>You can reference an annotation property by ID or label.</small>

---

### Get a table of properties

```
robot export --input edit.owl \
  --header "ID|LABEL|Type" \
  --entity-select "properties" \
  --export results/export-properties.csv
```

<small>You can select `classes`, `individuals`, and/or `properties` with `--entity-select`:<br>
`--entity-select "classes properties"`</small>

---

`query` (part 1)

* [http://robot.obolibrary.org/query](http://robot.obolibrary.org/query)
* `--input`: input ontology
* `--query`: query & output pair

---

### Run a SELECT query

```
robot query --input edit.owl \
  --query select.rq results/select.tsv
```

---

### Run an ASK query

```
robot query --input edit.owl \
  --query ask.rq results/ask.txt
```

<small>ASK always returns true/false</small>

---

## How do you see what is inferred by your ontology?

---

`reason`

* [http://robot.obolibrary.org/reason](http://robot.obolibrary.org/reason)
* `--input`: input ontology
* `--reasoner`: *optional* specify the reasoner to use (ELK)
* `--output`: output ontology with inferred statements

---

### Perform logical validation

```
robot reason --input unsatisfiable.owl
```

<small>Check that there are no *unsatisfiable* entities and that the ontology is *consistent*</small>

---

### Assert inferred statements

```
robot reason --input non-reasoned.owl \
  --output results/reasoned.owl
```

---

### Interlude: Perform a diff

```
robot diff \
  --left non-reasoned.owl \
  --right results/reasoned.owl \
  --output results/diff.diff
```

<small>Formats: `plain`, `pretty`, `html`, `markdown`</small>

---

**What reasoner should I use?**

* ELK: A fast reasoner for the OWL2 EL subset
* HermiT: A full OWL2 DL reasoner for complex ontologies

---

### A few other options

---

**Annotate inferred axioms**

<small>`--annotate-inferred-axioms true`</small>

---

**Create a new ontology with inferred statements only**

<small>`--create-new-ontology true`<br>
`--create-new-ontology-with-annotations true`</small>

---

**Remove redundant subclass axioms**

<small>`--remove-redundant-subclass-axioms true`</small>



# Ontology Development

---

## How do you create ontology content?

---

`template`

* [https://robot.obolibrary.org/template](https://robot.obolibrary.org/template)
* `--input`: *optional* ontology containing terms/properties to use or to merge into
* `--template`: template source file
* `--output`: output ontology

---

**What does a ROBOT template look like?**

| ID     | Label   | Type      | Annotation   | Parent    |
| ------ | ------- | --------- | ------------ | --------- |
| ID     | LABEL   | TYPE      | A property   | SC %      |
| ex:123 | Example | owl:Class | An example   | owl:Thing |

---

**Special template strings**

* `ID`: term CURIE
* `LABEL`: term label, asserted as `rdfs:label`
* `TYPE`: term entity type (you can use classes here for instances)

---

**Annotations**

* A + property label or ID
	* `A definition`
	* `A IAO:0000115`

---

**Axiom Annotations**

Axiom annotations are applied to the column to the left with `>`

| Annotation   | Axiom Annotation            |
| ------------ | --------------------------- |
| A definition | >A database_cross_reference |
| My def ...   | url:http://example.com      |

---

**Logic**

* `SC %`: direct superclass
* `EC %`: equivalent class

---

**Wildcards**

* `%` can be used as a wildcard to fill in logical expressions:
	* `SC 'has part' some %`
* You can use existing classes in the expression:
	* `SC 'has part' some ('part 1' and %)`

---

**Class Types**

* `CLASS_TYPE`: specify `subclass` or `equivalent` expression type
* `C %`: interchangeable expression type

| ID   | Class Type | Has Part |
| ---- | ---------- | -------- |
| ID   | CLASS_TYPE | C 'has part' some % |
| ex:0 |            |          |
| ex:1 | equivalent | ex:0     |
| ex:2 | subclass   | ex:0     |

---

You can reference a class or property by label *if*:

* It is defined in your template *and* your template has a `LABEL` column OR
* It is defined in your `--input` ontology

---

**Including multiple values**

Use the `SPLIT` keyword to allow multiple values in a single cell, separated by the provided character

| ID   | Parent         |
| ---- | -------------- |
| ID   | SC % SPLIT=,   |
| ex:4 | ex:0,ex:1,ex:2 |

---

### Create a new module

```
robot template --input edit.owl \
  --template module.tsv \
  --ontology-iri http://purl.obolibrary.org/obo/robot/mod.owl \
  --output results/mod.owl
```

<small>The `--ontology-iri` arg will assign this ontology IRI to our new module.<br>This can be used in the import statement in the core ontology.</small>

---

### Add a new class to an ontology

```
robot template --input edit.owl \
  --merge-before \
  --template new_class.tsv \
  --output results/new_class.owl
```

<small>If your ontology includes imports, use `--collapse-import-closure false` with any merge option to maintain the closure.</small>

---

`query`

*part 2*

---

### CONSTRUCT a module with labels and a new annotation

```
robot query --input edit.owl \
  --query construct.rq results/construct.ttl
```

<small>You can specify the output format of the constructed module with `--format` (e.g., `ttl`)</small>

---

### Update exsting annotations with INSERT/DELETE

```
robot query --input edit.owl \
  --update update.ru \
  --output results/updated.owl
```

---

## How do you reuse other ontologies?

---

`extract`

* [https://robot.obolibrary.org/extract](https://robot.obolibrary.org/extract)
* `--input`: input ontology
* `--method`: what kind of extract to perform
* `--output`: output extracted module

---

### Extract with SLME

```
robot extract \
  --input-iri http://purl.obolibrary.org/obo/obi.owl \
  --term OBI:0000443 \
  --method BOT \
  --output results/obi_bot.owl
```

<small>SLME modules include the input "seed" (term) and all terms required for to preserve logic between entities in the module<br>
SLME methods: `BOT` (seed + superclasses), `TOP` (seed + subclasses), `STAR` (seed + inter-relationships)</small>

---

### Extract with MIREOT

```
robot extract \
  --input-iri http://purl.obolibrary.org/obo/obi.owl \
  --method MIREOT \
  --lower-terms obi_terms.txt \
  --output results/obi_mireot.owl
```

<small>MIROET modules only preserve the subclass hierarchy, but do not include additional logical relationships.</small>



# Ontology Releases

---

## How do you create a "release" version of your ontology?

---

`merge`

* [https://robot.obolibrary.org/merge](https://robot.obolibrary.org/merge)
* `--input`: input ontologies (as many as you want)
* `--output`: output merged ontology

---

### Merge separate modules of an ontology

```
robot merge --input edit.owl \
  --input foo.owl \
  --output results/merged.owl
```

---

### Merge import statements

```
robot merge --input with-import.owl \
  --output results/merged_imports.owl
```

<small>If your ontology has import statements, ROBOT will automatically merge them.<br>
Use `--collapse-import-closure false` to maintain them when merging separate files</small>

---

`annotate`

* [https://robot.obolibrary.org/annotate](https://robot.obolibrary.org/annotate)
* `--input`: input ontology
* `--version-iri`: add a version IRI to the ontology
* `--annotation [property] [value]`: add an annotation to the ontology
* `--output`: output ontology

---

### Add ontology metadata

```
robot annotate --input edit.owl \
  --version-iri \
    https://github.com/ontodev/robot/releases/2019-07-31/edit.owl \
  --annotation oboInOwl:date "07:31:2019 12:00" \
  --output results/annotated.owl
```

---

**Chaining Commands**

```
robot merge --input edit.owl --collapse-import-closure true \
  reason --reasoner ELK \
  annotate --version-iri http://purl.obolibrary.org/obo/robot/2018-08-07/release.owl \
  --output release.owl
```

---

`reason` - `relax` - `reduce`

* Creates a complete and non-redundant view of the subclass graph for ease of browsing
* [https://robot.obolibrary.org/relax](https://robot.obolibrary.org/relax)
	* relaxes equivalence axioms to subclass axioms
* [https://robot.obolibrary.org/reduce](https://robot.obolibrary.org/reduce)
	*  removes redundant subclass axioms

---

## How do you ensure your ontology aligns with OBO standards?

---

`report`

* [https://robot.obolibrary.org/report](https://robot.obolibrary.org/relax)
* `--input`: input ontology
* `--format`: *optional* report format (tsv, csv, html, yaml, json, xlsx)
* `--output`: output report table

---

**What gets checked?**

* **Ontology metadata**: description, license, title
* **Annotations**: formatting, duplicates and multiples, missing required
* **Logic**: equivalent pairs, missing superclasses

---

### Run a standard report on your ontology

```
robot report --input edit.owl \
  --output results/report.tsv
```

---

### Run a standard report without failing

```
robot report --input edit.owl \
  --fail-on none \
  --output results/report.tsv
```

<small>You can choose what violation level to fail on: ERROR, WARN, INFO, or none</small>

---

## What other checks can you run on your ontology?

---

`verify`

[https://robot.obolibrary.org/verify](https://robot.obolibrary.org/verify)

<small>Create your own rules using SPARQL queries and verify your ontology conforms to them</small>

---

`validate-profile`

[https://robot.obolibrary.org/validate-profile](https://robot.obolibrary.org/validate-profile)

<small>Validate your ontology against an OWL 2 profile: EL, RL, QL, DL, Full</small>

---

`measure`

[https://robot.obolibrary.org/measure](https://robot.obolibrary.org/measure)

<small>Compute metrics about your ontology (number of classes, number of axioms, OWL2 profile, etc.)</small>



# What's next?

---

Explore the docs to learn more!

[https://robot.obolibrary.org](https://robot.obolibrary.org)

---

Join the community!

* GitHub: [https://github.com/ontodev/robot](https://github.com/ontodev/robot)
* Slack: [https://obo-communitygroup.slack.com/](https://obo-communitygroup.slack.com/)
