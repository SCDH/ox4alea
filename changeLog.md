# change log #

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
