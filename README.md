# ALEA &lt;oXygen/> Framework #

![release](https://github.com/scdh/ox4alea/actions/workflows/release.yml/badge.svg)
![tests](https://github.com/scdh/ox4alea/actions/workflows/test-main.yml/badge.svg)


An &lt;oXygen/> extension developed for the [edition of the works of
Ibn Nubata al Misri by the ALEA research
group](https://www.uni-muenster.de/ALEA/DFGlangfristvorhaben/index.html).

## Installation

Install from

```
https://scdh.github.io/ox4alea/descriptor.xml
```


The framework can be installed with &lt;oXygen/>'s installation and
update mechanism. Therefore, the above URL has to be entered into
the form "Show addons from:" of the dialogue box from "Help" ->
"Install new addons...".

This framework works on top of
[oXbytei](https://github.com/scdh/oxbytei) and
[oXbytao](https://github.com/scdh/oxbytei), which must also be
installed.

```
https://scdh.github.io/oxbytei/descriptor.xml
```

```
https://scdh.github.io/oxbytao/descriptor.xml
```

Alternative installation methods are explained in [oXbytei's
documentation](https://github.com/SCDH/oxbytei#installation) and can
be applied analogously.


## Features and Usage ##

This framework adds only a thin layer of additional functions on top
of oXbytei and oXbytao.

- shortcut actions for encoding
  - verbatim citations from the holy text and other sources
  - references to encyclopedia articles: this simply collects
    bibliographic entries marked with `type="encyclopedia"` from your
    bibliography and presents them for selection
  - etc.
  
- transformations useful for editing multiple recensions of the same text

- this framework comes packed with the [SEED TEI
  Transformations](https://github.com/scdh/seed-tei-transformations)
  for generating the HTML previews

### Project specific CSS ###

In order to get nice rendering in author mode, you should provide CSS
for the used languages through the project specific CSS file (see
[oXbytao](https://github.com/scdh/oxbytao#css)). Here is an example:

```{css}
@namespace xml "http://www.w3.org/XML/1998/namespace";

[xml|lang="ar"] {
    direction: rtl !important;
}

[xml|lang="de"] {
    direction: ltr !important;
}

[xml|lang="en"] {
    direction: ltr !important;
}

[xml|lang="ar-DE"] {
    direction: ltr !important;
}
```

# License #

GPL v3

Some icons where taken from the web:

- [Encyclopedia icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/encyclopedia)
