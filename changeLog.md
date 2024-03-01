# change log #

### 3.3.2

- update SEED TEI Transformations to bug fix version 0.11.1

### 3.3.0

- activate validation scenarios and made `ALEA` the default scenario
  - the `ALEA` scenario points directly to
    `${pdu}/resources/schema/ALEA.rng`
  - Breaks the separation of project and framework. However, having
    validation without any individual config is vital at the moment.
- update to SEED TEI Transformations 0.11.0
- update to ALEA Transformations 0.7.5

### 3.2.0

- improved author action for citations
- bump SEED TEI Transformations to 0.10.0
- added transformation scenarios for Diwan that ask for font size
  - this enable to get prints for team meatings

### 3.0.0

- dependencies on SEED TEI Transformations and ALEA Transformations
- preview replaced with components from SEED TEI Transformations
- added transformation and scenario for registries, i.e., places,
  persons, bibliography, importet from ALEA Transformations


### 2.8.4

- generate apparatus entries for `<space>` nested in `<rdg>`

### 2.8.3

- output `@reason` for gaps and unclear text nested `<rdg>`

### 2.8.1 ###

- preview:
  - i18n: introduced namespace `decimal` for translating decimal
	numbers to i18n language, e.g. translating arabic numbers to
	arabic numbers in arabic script
  - translate surah verse numbers to i18n language
  - libapp2: replace `<caesura>` to space in apparatus lemma.

### 2.8.0 ###

- preview:
  - make libi18n.xsl generic
  - print surah titles instead of surah number
  - fixed arabic translations for "omisit" and "conieci"

### 2.7.3 ###

- preview:
  - apparatus: when lemma is empty, print the preceding or following
    word and repeat it in the reading
  - preview all recensions: made this work on Windows

### 2.7.2 ###

- preview:
  - fix line numbering and nested `<unclear>` etc. in `<rdg>`
  - minimal support for prose
- action for editing `title` and `TEI/@xml:id` simultaneously
- remove restrictions `<caesura>` action, because we hand restriction
  over to ODD

### 2.7.1 ###

- fix bug in shortcut action for inserting references to encyclopedia

### 2.7.0 ###

- use `libapp2.xsl` for the apparatus
  - works for `double-end-point` and `parallel-segmentation`
  - allows multiple apparatus
- rewritten `libnote2.xsl` analogously
- generic implementation of reference processing including the full
  specification of `<prefixDef>` in `libref.xsl`
- made `libwit.xsl` and Preview configurable
  - takes XPath expressions as parameter now
  - where to find witness information
  - where to find the siglum of a witness
  - old parameter that points to a central witness catalogue is gone
- be more precise in which modes to use the templates defined in
  `librend.xsl` and `libbiblio.xsl`
- MRE:
  - added action `mre.prev` for shifting back to the previous
    recension
  - added action `mre.toggle.fading` for turning fading on/off
  - added transformation scenario for updating the HTML preview of all
    recensions
  - added action for running this preview
  - fix work ID for recension preview

### 2.6.1 ##

- inproved Preview
  - internal double end-point attachted apparatus make use of new
    `libbetween.xsl` XSLT library
  - fixed some apparatus entries
  - new generic `libref.xsl` that fully implements the specification
	of `<prefixDef>` and the addition suggested by CL on TEI-L on
	2022-05-29.

## 2.6.0 ##

- Preview
  - make internal double end-point attached apparatus work
  - simpler code base
  - fixes for `<unclear>` and `<gap>` nested in an apparatus
  - let work ID appear in HTML title element
- make transformations less verbose: do not open XML result pane etc.
- MRE
  - transformation for extracting recensions
	- make new work identifier and write it to `/TEI/@xml:id`
	- extraction for `<witDetail>`
	- remove empty `<appInfo>`
  - author mode actions only active when there's an application info
    in the encoding description

## 2.5.5 ##

- fixed optional CSS for hiding readings from other recensions

## 2.5.4 ##

- actions for setting MRE parameters
  - `reset`: empty all parameters
  - `next`: shift `in progress` to the next recension (order
    determined from header) and add old `in progress` to `done`
  - `complement`: set `done` as `in progress`'s complement set of
    recensions

## 2.5.3 ##

- introduced new optional MRE-related CSS style for hiding `<rdg>`
  from recensions other than the one in progress
- made MRE more configurable
  - `oxbytao.mre.recensions.xpath` TEI LSP property which defaults to
    `//sourceDesc//listWit[@xml:id]`
  - related CSS is still not configurable because usage of editor
    variables is broken/unstable in CSS

## 2.5.2 ##

- introduced more functions to MRE
  - reset
  - send to all recensions but the one in progress
  - send to all recensions listed in `done`
  - edit `@source`
- fixed CSS of MRE
  - visibility
  - fading: fade all recensions listed as `fading` as soon there is a
    sibling from the recension in progress

## 2.5.1 ##

- added user action for selecting `@source`

## 2.5.0 ##

- introduce MRE (multiple recension editor)
- store MRE's application information in `<appInfo>`
- fixed preview for of cases where apparatus entries and notes are
  nested in each other

## 2.4.7 ##

- fixed shortcut actions for prefix-style bibliographic references
  using `sel.bibref` from oXbytei
  - shortcut action for inserting a note with a bibliographic reference
  - shortcut action for inserting a note with a reference to the holy
    script
  - the bibliographic entry of the holy script can now be configured
    with the teilsp property `alea.action.bibref.holy.reference`. It's
    default value is `bibl:Quran`
- removed old `edit_bibref` action completely (it is still referenced
  in the old framework file)

## 2.4.6 ##

- removed old `edit_bibref` action from content completion

## 2.4.5 ##

- use `diwan:WORK-ID` custom URI scheme for collation sources instead
  of limited `cs:...` scheme
- generate `@xml:id` when extracting a reading

## 2.4.4 ##

- extract recension
  - ANT based scenario that makes references to notes instead of
    copying them
  - ANT is important because this needs the XML files have to be
    parsed without expanding XInclude

## 2.4.3 ##

- preview
  - made modules from preview.xsl


## 2.4.2 ##

- preview
  - XSLT module for getting references from local URI schemes,
    document-internal identifierts or global URI schemes
  - XSLT module for bibliographic references
  - fixed data type of `@type`
  - fixed metadata output

## 2.4.1 ##

- add xml ID to `<note>` produced with shortcut actions

## 2.4.0 ##

- moved transformation scenarios to project
  - adjust header
  - set verse meter
  - latinize witnesses
  - conversion from flat ODT
- use `${framework}/xsl/postprocess.xsl` as additional
  stylesheet when producing TEI. This is established as a standard
  hook now. We do not want to care about XIncludes etc. in the
  framework any more. You can simply redirect this to your own XSLT
  using an XML catalog.
- Removed `<xsl:output indent="true"/>` from transformations where TEI
  documents are affected, because it may mess up white space in the
  text.
- fixed data type of `@type` in CSS and actions
- fixed data type of `@who` in actions and XSLT
- replaced bibref action with the one from oXbytao
- added deprecation notices to old actions and XSLT

## 2.3.3 ##

- collate verses in TEI by adding `@corresp` to verses when extracting
  a reading
  - the transformation will quit with an error if there is a verse
    without an ID
- improved CSS for multiple recensions

## 2.3.2 ##

- Changed "Insert/Change Segmentation" to "Insert Segmentation",
  because it prevents nested segmentations

## 2.3.1 ##

- preview for double end-point attachment apparatus encodings
  - still not perfect, but ok for demonstration

## 2.3.0 ##

- multiple recension documents
  - CSS for selecting and unselecting parts to display
  - action for inserting markup and selecting `@source`
  - XSLT for extracting a single recension and the according variants
	from a multiple recension document
  - XSLT for HTML preview of a multiple recension documents
- removed redundant CSS styles:
  - "+ edit sigla"
  - "+ tags"

## 2.2.0 ##

- new shortcut action for setting the language of the text selected by
  the user. This inserts a `<seg>` and sets `@xml:lang` on it.

## 2.1.0 ##

- added shortcut action for inserting a reference to an encyclopedia
- font features italic etc. in preview
- do not fail on local URIs in `bibl/@corresp`

## 2.0.0 ##

- shortcut actions for
  - citation from Koran
  - citation with bibliographic reference
  - note on user selection
- open file after transforming with `extract reading`
- use all validation scenorios for automatic validation

- version step to 2.x.x because using oXbytei/oXbytao as base
  frameworks seems to be stable now

## 1.0.64 ##

- Preview: keine Personen-Infos für `<persName>` in `<note>`

## 1.0.63 ##

- Preview: Anker-basierte Annotationen herausgenommen. Es sollen nur
  die Fußnoten-Kommentare angezeigt werden.

## 1.0.62 ##

- Versnummerierung bei zusätzlichen Versen korrigiert:
  - Es soll die Zahl des vorhergehenden Verses verwendet werden
  - Falls das Gedicht mit einem zusätzlichen Vers beginnt, steht dann
    da eine 0.

## 1.0.61 ##

- Preview kann Anker-basiertes Markup für Personen und Orte.

## 1.0.60 ##

- make templates work again

## 1.0.59 ##

- make oXbytei new base framework

## 1.0.58 ##

- activate author mode action for `<witDetail>` everywhere

## 1.0.57 ##

- fixes validation of `witDetail/@wit` inside `app`
