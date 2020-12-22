<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:t="http://www.tei-c.org/ns/1.0">

    <sch:ns uri="http://www.tei-c.org/ns/1.0" prefix="t"/>

    <sch:pattern>
        <sch:rule context="@met">
            <sch:let name="met" value="."/>
            <sch:let name="metres" value="/t:TEI/t:teiHeader//t:metDecl//t:metSym/@value"/>
            <sch:assert
                test="
                    some $m in $metres
                        satisfies $m eq $met"
                >Unkown verse metre: <sch:value-of select="$met"/></sch:assert>

        </sch:rule>
    </sch:pattern>

</sch:schema>
