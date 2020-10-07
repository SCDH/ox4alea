<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:t="http://www.tei-c.org/ns/1.0">
    
    <sch:ns uri="http://www.tei-c.org/ns/1.0" prefix="t"/>
    
    <!-- report witnesses not registered in the teiHeader -->
    <sch:pattern>
        <sch:rule context="@wit">
            <sch:let name="wits" value="."/>
            <sch:let name="registered-wits" value="./ancestor::t:TEI/t:teiHeader//t:witness/@xml:id"/>
            <!-- fold-left() and anonymous function are not defined in schematron, so we cast the booleans to strings... -->
            <sch:report 
                test="contains(string-join(for $w in tokenize($wits, '[\s]+') return string(exists(./ancestor::t:TEI/t:teiHeader//t:witness[concat('#', @xml:id) = $w])), ''), 'false')"
                >witness <sch:value-of select="."/> not registered in TEI header (<sch:value-of select="$registered-wits"/>)</sch:report>
        </sch:rule>
    </sch:pattern>

    
</sch:schema>