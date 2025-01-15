<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs math xd mei"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 25, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p><xd:b>Author:</xd:b> Benjamin W. Bohl</xd:p>
            <xd:p>This XSLT translates an MEI v4 file to an MEI v5 file.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"/>
    <xsl:strip-space elements="*"/>
    
    <!-- ======================================================================= -->
    <!-- PARAMETERS                                                              -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Provides the location of the RNG schema.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="rng_model_path" as="xs:anyURI?"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Provides the location of the Schematron schema.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="sch_model_path" as="xs:anyURI?"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Controls the feedback provided by the stylesheet. The default value of 'true()'
                produces a log message for every change. When set to 'false()' no messages are produced.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="verbose" select="true()" as="xs:boolean"/>
    
    <!-- ======================================================================= -->
    <!-- GLOBAL VARIABLES                                                        -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>program id</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="progId" as="xs:string">
        <xsl:text>mei40To50</xsl:text>
    </xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>program version</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="progVersion" as="xs:string">
        <xsl:text>1.1</xsl:text>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>program name</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="progName" as="xs:string">
        <xsl:value-of select="$progId || '.xsl'"/>
    </xsl:variable>

    
    <xd:doc>
        <xd:desc>
            <xd:p>program git url</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="progGitUrl" as="xs:string">
        <xsl:value-of select="'https://github.com/music-encoding/encoding-tools/blob/main/' || $progId || '/' || $progName"/>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>MEI version</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="meiversion" as="xs:string">
        <xsl:value-of select="'5.0'"/>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>fallback model path</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="fallback_model_path" as="xs:anyURI">
        <xsl:text>https://music-encoding.org/schema/5.0/mei-all.rng</xsl:text>
    </xsl:variable>
 
    <xd:doc>
        <xd:desc>
            <xd:p>document URI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="docURI">
        <xsl:value-of select="document-uri(/)"/>
    </xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>new line</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="nl" as="item()">
        <xsl:text>&#xa;</xsl:text>
    </xsl:variable>
    
    <!-- ======================================================================= -->
    <!-- MAIN OUTPUT TEMPLATE                                                    -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Start template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="existing_rng_model_instruction" select="/processing-instruction('xml-model')[contains(.,'http://relaxng.org/ns/structure/1.0')]"/>
        <xsl:variable name="existing_rng_model_path">
            <xsl:value-of select="tokenize(tokenize($existing_rng_model_instruction, ' ')[starts-with(., 'href')], '&quot;')[2]"/>
        </xsl:variable>
        <xsl:message>existing rng model path: <xsl:value-of select="$existing_rng_model_path"/></xsl:message>
        <xsl:variable name="existing_sch_model_instruction" select="/processing-instruction('xml-model')[contains(.,'http://purl.oclc.org/dsdl/schematron')]"/>
        <xsl:variable name="existing_sch_model_path">
            <xsl:value-of select="tokenize(tokenize($existing_sch_model_instruction, ' ')[starts-with(., 'href')], '&quot;')[2]"/>
        </xsl:variable>
        <xsl:message>existing schematron model path: <xsl:value-of select="$existing_sch_model_path"/></xsl:message>
        <xsl:choose>
            <xsl:when test="$rng_model_path != ''">
                <xsl:processing-instruction name="xml-model">
                    <xsl:value-of select="concat(' href=&quot;', $rng_model_path, '&quot;')"/>
                    <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$nl"/>
            </xsl:when>
            <xsl:when test="matches($existing_rng_model_path, 'https?://music-encoding.org/schema/')">
                <xsl:variable name="schema_filename" select="tokenize($existing_rng_model_path, '/')[last()]"/>
                <xsl:variable name="fallback_model_location" select="substring-before($fallback_model_path, tokenize($fallback_model_path, '/')[last()])"/>
                <xsl:processing-instruction name="xml-model">
                    <xsl:value-of select="concat(' href=&quot;', $fallback_model_location, $schema_filename, '&quot;')"/>
                    <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$nl"/>
            </xsl:when>
            <xsl:when test="$existing_rng_model_path != ''">
                <xsl:copy-of select="$existing_rng_model_instruction"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:processing-instruction name="xml-model">
                    <xsl:value-of select="concat(' href=&quot;', $fallback_model_path, '&quot;')"/>
                    <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$nl"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$sch_model_path != ''">
                <xsl:processing-instruction name="xml-model">
                    <xsl:value-of select="concat(' href=&quot;', $sch_model_path, '&quot;')"/>
                    <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$nl"/>
            </xsl:when>
            <xsl:when test="matches($existing_sch_model_path, 'https?://music-encoding.org/schema/')">
                <xsl:variable name="schema_filename" select="tokenize($existing_sch_model_path, '/')[last()]"/>
                <xsl:variable name="fallback_model_location" select="substring-before($fallback_model_path, tokenize($fallback_model_path, '/')[last()])"/>
                <xsl:processing-instruction name="xml-model">
                    <xsl:value-of select="concat(' href=&quot;', $fallback_model_location, $schema_filename, '&quot;')"/>
                    <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$nl"/>
            </xsl:when>
            <xsl:when test="$existing_sch_model_path != ''">
                <xsl:copy-of select="$existing_sch_model_instruction"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:processing-instruction name="xml-model">
                    <xsl:value-of select="concat(' href=&quot;', $fallback_model_path, '&quot;')"/>
                    <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
                </xsl:processing-instruction>
                <xsl:value-of select="$nl"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="mei:*[starts-with(@meiversion, $meiversion)]">
                <xsl:variable name="warning" select="'The source document is already an MEI v'|| $meiversion ||' file!'"/>
                <xsl:message terminate="yes" select="$warning"/>
            </xsl:when>
            <xsl:when test="mei:*">
                <xsl:apply-templates select="mei:* | comment()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="warning">The source document is not an MEI file!</xsl:variable>
                <xsl:message terminate="yes" select="$warning"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ======================================================================= -->
    <!-- MATCH TEMPLATES FOR CHANGES BETWEEN MEI v4 and MEI v5                   -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>Insert @meiversion on root element if not present.</xd:desc>
    </xd:doc>
    <xsl:template match="/mei:*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(@meiversion)">
                <xsl:attribute name="meiversion" select="$meiversion"/>
                <xsl:if test="$verbose">
                    <xsl:message select="'Inserting @meiversion on ' || local-name() || ' with value: ' || $meiversion"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Replace deprecated fingerprint in favor of identifier/@type="fingerprint", which is allowed everywhere where fingerprint was allowed.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:fingerprint">
        <xsl:if test="$verbose">
            <xsl:message select="'fingerprint ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || ' changed to identifier.'"/>
        </xsl:if>
        <identifier xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:variable name="types" select="(tokenize(normalize-space(@type), ' '), 'fingerprint')" as="xs:string*"/>
            <xsl:attribute name="type" select="string-join($types, ' ')"/>
            <xsl:apply-templates select="@* except @type"/>
            <xsl:apply-templates select="node()"/>
        </identifier>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace pgHead2 for subsequent pages with pgHead/@func="all", assuming another pgHead will use @func="first".</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:pgHead2">
        <xsl:if test="$verbose">
            <xsl:message select="'pgHead2 ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || ' changed to pgHead.'"/>
        </xsl:if>
        <pgHead xmlns="http://www.music-encoding.org/ns/mei" func="all">
            <xsl:apply-templates select="node() | @*"/>
        </pgHead>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace pgHead with pgHead/@func="first", assuming another pgHead2 was there and is now encoded as pgHead with @func="all".</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:pgHead[//mei:pgHead2]">
        <xsl:if test="$verbose">
            <xsl:message select="'pgHead ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || ' enriched with func=first'"/>
        </xsl:if>
        <xsl:copy>
            <xsl:attribute name="func" select="'first'"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace pgFoot2 for subsequent pages with pgFoot/@func="all", assuming another pgFoot will use @func="first".</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:pgFoot2">
        <xsl:if test="$verbose">
            <xsl:message select="'pgFoot2 ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || ' changed to pgFoot.'"/>
        </xsl:if>
        <pgFoot xmlns="http://www.music-encoding.org/ns/mei" func="all">
            <xsl:apply-templates select="node() | @*"/>
        </pgFoot>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace pgFoot with pgFoot/@func="first", assuming another pgFoot2 was there and is now encoded as pgFoot with @func="all".</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:pgFoot[//mei:pgFoot2]">
        <xsl:if test="$verbose">
            <xsl:message select="'pgFoot ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || ' enriched with func=first'"/>
        </xsl:if>
        <xsl:copy>
            <xsl:attribute name="func" select="'first'"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @visible on mRest.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mRest/@visible">
        <xsl:if test="$verbose">
            <xsl:message select="'Dropping @visible on mRest ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @instr on mRest.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mRest/@instr">
        <xsl:if test="$verbose">
            <xsl:message select="'Dropping @instr on mRest ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @instr on mSpace.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:mSpace/@instr">
        <xsl:if test="$verbose">
            <xsl:message select="'Dropping @instr on mSpace ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @instr on multiRest.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:multiRest/@instr">
        <xsl:if test="$verbose">
            <xsl:message select="'Dropping @instr on multiRest ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Remove @instr on rest.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:rest/@instr">
        <xsl:if test="$verbose">
            <xsl:message select="'Dropping @instr on rest ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace @key.sig with @keysig.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@key.sig">
        <xsl:attribute name="keysig" select="."/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace @keysig.show with @keysig.visible.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@keysig.show">
        <xsl:attribute name="keysig.visible" select="."/>
        <xsl:if test="$verbose">
            <xsl:message select="'Changing @keysig.show to @keysig.visible on ' || local-name(parent::mei:*) || ' ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace @keysig.showchange with @keysig.cancelaccid.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@keysig.showchange">
        <xsl:variable name="value.old" select="."/>
        <xsl:variable name="value.new">
            <xsl:choose>
                <xsl:when test="$value.old = 'false'">none</xsl:when>
                <xsl:otherwise>before</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="keysig.cancelaccid" select="$value.new"/>
        <xsl:if test="$verbose">
            <xsl:message>
                <xsl:value-of select="'Changing @keysig.showchange to @keysig.cancelaccid on ' || local-name(parent::mei:*) || ' ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || '. '"/>
                <xsl:text>Please note: converting value from </xsl:text>
                <xsl:value-of select="$value.old"/><xsl:text> to </xsl:text><xsl:value-of select="$value.new"/><xsl:text>. </xsl:text>
                <xsl:if test="$value.old = 'true'">There are several alternatives for encoding the style of MEI 4 @keysig.showchange='true' in MEI 5.0 (before, after, before-bar), defaulting to 'before'.</xsl:if>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace @sig.showchange with @cancelaccid.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@sig.showchange">
        <xsl:variable name="value.old" select="."/>
        <xsl:variable name="value.new">
            <xsl:choose>
                <xsl:when test="$value.old = 'false'">none</xsl:when>
                <xsl:otherwise>before</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="cancelaccid" select="$value.new"/>
        <xsl:if test="$verbose">
            <xsl:message>
                <xsl:value-of select="'Changing @sig.showchange to @cancelaccid on ' || local-name(parent::mei:*) || ' ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || '. '"/>
                <xsl:text>Please note: converting value from </xsl:text>
                <xsl:value-of select="$value.old"/><xsl:text> to </xsl:text><xsl:value-of select="$value.new"/><xsl:text>. </xsl:text>
                <xsl:if test="$value.old = 'true'">There are several alternatives for encoding the style of MEI 4 @sig.showchange='true' in MEI 5.0 (before, after, before-bar), defaulting to 'before'.</xsl:if>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Resolve changes in @meter.form, moving @meter.form="invis" to @meter.visible="false".</xd:desc>
    </xd:doc>
    <xsl:template match="@meter.form">
        <xsl:choose>
            <xsl:when test=". = 'invis'">
                <xsl:attribute name="meter.visible">false</xsl:attribute>
                <xsl:if test="$verbose">
                    <xsl:message>Changing @meter with value "invis" to @meter.visible with value "false"</xsl:message>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Resolve changes in meterSig/@form, moving @form="invis" to @visible="false".</xd:desc>
    </xd:doc>
    <xsl:template match="mei:meterSig/@form">
        <xsl:choose>
            <xsl:when test=". = 'invis'">
                <xsl:attribute name="visible">false</xsl:attribute>
                <xsl:if test="$verbose">
                    <xsl:message select="'Changing @form with value `invis` to @visible with value `false` on meterSig ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Replace @line.form on arpeg with @lform.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:arpeg/@line.form">
        <xsl:attribute name="lform" select="."/>
        <xsl:if test="$verbose">
            <xsl:message select="'Replacing @line.form with @lform on arpeg ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || '.'"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Replace @line.width on arpeg with @lwidth.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:arpeg/@line.width">
        <xsl:attribute name="lwidth" select="."/>
        <xsl:if test="$verbose">
            <xsl:message select="'Replacing @line.width with @lwidth on arpeg ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || '.'"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Resolve @text.dist to @dir.dist.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@text.dist">
        <xsl:attribute name="dir.dist" select="."/>
        <xsl:if test="$verbose">
            <xsl:message select="'Replacing @text.dist with @dir.dist on ' || local-name(parent::mei:*) || ' ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id || '. Alternatives could be @reh.dist or @tempo.dist.'"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Move letter-spacing and line-height on @rend to separate attributes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:*[@rend and (contains(@rend, 'letter-spacing(') or contains(@rend, 'line-height('))]">
        <xsl:variable name="rendValues" select="tokenize(normalize-space(@rend), ' ')" as="xs:string+"/>
        <xsl:variable name="letterSpacingRend" select="$rendValues[starts-with(., 'letter-spacing(')]" as="xs:string?"/>
        <xsl:variable name="lineHeightRend" select="$rendValues[starts-with(., 'line-height(')]" as="xs:string?"/>
        <xsl:variable name="remainingRends" select="$rendValues[not(. = $letterSpacingRend) and not(. = $lineHeightRend)]" as="xs:string*"/>
        <xsl:copy>
            <xsl:if test="exists($letterSpacingRend)">
                <xsl:attribute name="letterspacing" select="substring-before(substring-after($letterSpacingRend, '('),')')"/>
            </xsl:if>
            <xsl:if test="exists($lineHeightRend)">
                <xsl:attribute name="lineheight" select="substring-before(substring-after($lineHeightRend, '('),')')"/>
            </xsl:if>
            <xsl:if test="exists($remainingRends)">
                <xsl:attribute name="rend" select="string-join($remainingRends, ' ')"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @* except @rend"/>
        </xsl:copy>
        
        <xsl:if test="$verbose">
            <xsl:message select="'Separating letter-spacing and line-height into separate attributes on ' || local-name(parent::mei:*) || ' ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Move a non-numeric value on instrDef/@n to instrDef/@label.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:instrDef/@n">
        <xsl:choose>
            <xsl:when test="matches(., '^[1-9]\d*$')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="matches(., '^[\w_-]+$')">
                <xsl:if test="$verbose">
                    <xsl:message select="'Changing instrDef/@n to @label, because it contains non-numeric characters.'"/>
                </xsl:if>
                <xsl:attribute name="label" select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">The @n on instrDef seems to be invalid in the source file.
                <xsl:value-of select="document-uri(root())"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Replace a value of "Bagpipe" on @midi.instrname with "Bag_pipe".</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@midi.instrname">
        <xsl:attribute name="midi.instrname" select="replace(., 'Bagpipe', 'Bag_pipe')"/>
        <xsl:if test="$verbose">
            <xsl:message select="'Changing Bagpipe to Bag_pipe on @midi.instrname on ' || local-name(parent::mei:*) || ' ' || ancestor-or-self::mei:*[@xml:id][1]/@xml:id"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Replace a value of "dblwhole" on @head.mod with "fences".</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@head.mod">
        <xsl:choose>
            <xsl:when test=". = 'dblwhole'">
                <xsl:attribute name="head.mod" select="'fences'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ======================================================================= -->
    <!-- SELF-DOCUMENTATION TEMPLATES                                            -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Documentation for files without top-level mei:meiHead.</xd:p>
            <xd:p>Matches root elements that are not mei:meiHead and do not contain an mei:meiHead element as direct child.</xd:p>
        </xd:desc>
        <xd:return>Inserts XML-comments for documentation then processes the XML-tree.</xd:return>
    </xd:doc>
    <xsl:template match="/mei:*[not(mei:meiHead) and not(self::mei:meiHead)]">
        <xsl:variable name="documentation-change" as="element()">
            <xsl:call-template name="revisionDesc-insert-change"/>
        </xsl:variable>
        <xsl:variable name="documentation-application" as="element()">
            <xsl:call-template name="appInfo-insert-current-application"/>
        </xsl:variable>
        <xsl:comment>
            <xsl:value-of select="$documentation-change/mei:date/@isodate, $documentation-change/mei:changeDesc/mei:p" separator=" – "/>
            <xsl:text> Agent: </xsl:text>
            <xsl:value-of select="$documentation-application/mei:ptr/@target, $documentation-application/@version" separator=" – "/>
        </xsl:comment>
    <xsl:next-match/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Add a change element for the conversion.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:meiHead[count(ancestor::*) le 1]/mei:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <xsl:call-template name="revisionDesc-insert-change"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Add a record of the conversion to revisionDesc.</xd:desc>
    </xd:doc>
    <xsl:template name="revisionDesc-insert-change">
        <!-- Add a record of the conversion to revisionDesc -->
        <change xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:if test="count(mei:change[@n]) = count(mei:change)">
                <xsl:attribute name="n" select="count(mei:change) + 1"/>
            </xsl:if>
            <xsl:attribute name="resp">
                <xsl:value-of select="concat('#', $progId)"/>
            </xsl:attribute>
            <changeDesc>
                <p><xsl:value-of select="'Converted to MEI version ' || $meiversion || ' using ' || $progName || ', version ' || $progVersion"/></p>
            </changeDesc>
            <date>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
                </xsl:attribute>
            </date>
        </change>
        <xsl:if test="$verbose">
            <xsl:message select="'Added change element to the encoding.'"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Insert mei:revisionDesc if not present.</xd:desc>
    </xd:doc>
    <xsl:template match="mei:meiHead[count(ancestor::*) le 1][not(mei:revisionDesc)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:element name="revisionDesc" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:call-template name="revisionDesc-insert-change"/>
            </xsl:element>
            <xsl:message>Added revisionDesc to the encoding.</xsl:message>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Insert mei:application with info about the XSLT to an exisiting mei:appInfo.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:meiHead[count(ancestor::*) le 1]/mei:encodingDesc/mei:appInfo">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
            <xsl:call-template name="appInfo-insert-current-application"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Create mei:application element with info about this XSLT.</xd:p>
        </xd:desc>
    </xd:doc>    
    <xsl:template name="appInfo-insert-current-application">
        <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="version" select="'v' || replace($progVersion, '&#32;', '_')"/>
            <xsl:attribute name="xml:id" select="$progId"/>
            
            <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei"><xsl:value-of select="$progName"/></xsl:element>
            <xsl:element name="ptr" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name=" target" select="$progGitUrl"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="$verbose">
            <xsl:message select="'Added application element with documentation of this XSLT.'"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Create mei:appInfo element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="encodingDesc-insert-appInfo">
        <xsl:element name="appInfo" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:call-template name="appInfo-insert-current-application"/>
        </xsl:element>
        <xsl:if test="$verbose">
            <xsl:message select="'Added appInfo element to the encoding.'"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy mei:encodingDesc and, if not present, insert mei:appInfo as first child  with self-documentation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:meiHead[count(ancestor::*) le 1]/mei:encodingDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(mei:appInfo)">
                <xsl:call-template name="encodingDesc-insert-appInfo"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy mei:fileDesc and, if not present, insert mei:encodingDesc/mei:appInfo after it with self-documentation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:meiHead[count(ancestor::*) le 1]/mei:fileDesc">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
        <xsl:if test="not(following-sibling::mei:encodingDesc)">
            <xsl:element name="encodingDesc" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:call-template name="encodingDesc-insert-appInfo"/>
            </xsl:element>
            <xsl:if test="$verbose">
                <xsl:message select="'Added encodingDesc element to the encoding.'"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Update @meiversion to the new version of MEI.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@meiversion">
        <xsl:attribute name="meiversion" select="$meiversion"/>
        <xsl:if test="$verbose">
            <xsl:message select="'Changing @meiversion on ' || local-name(parent::mei:*) || ' from ' || . || ' to ' || $meiversion"/>
        </xsl:if>
    </xsl:template>
    
    
    <!-- ======================================================================= -->
    <!-- COPY TEMPLATE                                                           -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Copy template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
