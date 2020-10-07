<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:t="http://www.tei-c.org/ns/1.0">
    
    <sch:ns uri="http://www.tei-c.org/ns/1.0" prefix="t"/>
    
    <sch:pattern>
        <sch:rule context="*[@wit]">
            <sch:let name="sep" value="'\s+'"/>
            <sch:let name="wits" value="tokenize(normalize-space(@wit), $sep)"/>
            <sch:let name="registered-wits" value="./ancestor::t:TEI/t:teiHeader//t:witness/@xml:id"/>

            <!-- report witnesses not registered in the teiHeader -->
            <!-- fold-left() and anonymous function are not defined in schematron, so we cast the booleans to strings... -->
            <sch:report 
                test="contains(string-join(for $w in $wits return string(exists(./ancestor::t:TEI/t:teiHeader//t:witness[concat('#', @xml:id) = $w])), ''), 'false')"
                >witness <sch:value-of select="@wit"/> (at least one of them) not registered in TEI header (<sch:value-of select="$registered-wits"/>)</sch:report>

            <!-- report parallel uses of the same witness -->
            <!-- intersect does not work on sequences of atomic values.
                 We append a space to make the IDs prefix-free language.
                 To also test this on following-sibling would double errors. -->
            <sch:report
                test="some $w in $wits satisfies not(empty(preceding-sibling::t:*[contains(concat(@wit, ' '), concat($w, ' '))]))"
                >witness <sch:value-of select="@wit"/> (at least one of them) used in parallel</sch:report>

        </sch:rule>
    </sch:pattern>

</sch:schema>