# change log #

## dev ##

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
