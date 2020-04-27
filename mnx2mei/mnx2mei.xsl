<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:temp="temporary"
    exclude-result-prefixes="xs math xd mei temp"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 23, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSLT converts from MNX Common to MEI Basic</xd:p>
            <xd:p>It operates in multiple passes, each encapsulated in a separate @mode. 
                The sequence of modes is as follows:
                <xd:ul>
                    <xd:li><xd:b>mode="structure"</xd:b>: Converts the basic structures (parts, measures, etc.)</xd:li>
                </xd:ul>
                Like MusicXML, MNX does not rely on an XML namespace. 
            </xd:p>
            <xd:p>
                <xd:b>Revisions</xd:b>
                <xd:ul>
                    <xd:li><xd:b>2020-04-23</xd:b>: First draft of this file, targeting the initial version of MEI Basic. ControlEvents seem pretty open in MNX, so the converter isn't too ambitious about them yet and only does a very first conversion on dynamics. Besides that, it's obvious how close MNX is modelled after MEI – many features can be translated pretty directly…</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xml"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The variable <xd:b>$mnx.file</xd:b> holds the complete input file for later reference.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="mnx.file" select="/" as="node()"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The start template, which also controls the processing order of multiple subsequent stylesheet runs in different modes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        
        <!-- initial check if input file matches expectations -->
        <xsl:variable name="is.compatible" select="temp:checkCompatibility($mnx.file)" as="xs:boolean"/>
        
        <!-- the structures of MNX are converted to MEI structures in this first variable -->
        <xsl:variable name="converted.structure" as="node()">
            <xsl:apply-templates select="mnx" mode="structure"/>    
        </xsl:variable>
        
        <!-- this variable takes care of converting MNX Metadata to MEI -->
        <xsl:variable name="converted.header" as="node()">
            <xsl:apply-templates select="$converted.structure" mode="header"/>
        </xsl:variable>
        
        <!-- this variable has all parts translated to staves and layers -->
        <xsl:variable name="converted.staves" as="node()">
            <xsl:apply-templates select="$converted.header" mode="staves"/>
        </xsl:variable>
        
        <!-- this variable generates the first scoreDef -->
        <xsl:variable name="with.scoreDef" as="node()">
            <xsl:apply-templates select="$converted.staves" mode="scoreDef"/>
        </xsl:variable>
        
        <!-- this variable does an initial conversion of MEI events -->
        <xsl:variable name="converted.events" as="node()">
            <xsl:apply-templates select="$with.scoreDef" mode="events"/>
        </xsl:variable>
        
        <!-- this variable holds converted controlevents -->
        <xsl:variable name="converted.controlevents" as="node()">
            <xsl:apply-templates select="$converted.events" mode="controlevents"/>
        </xsl:variable>
        
        <!-- this outputs the final result of all conversion steps -->
        <xsl:copy-of select="$converted.controlevents"/>
    </xsl:template>
    
    
    
    <!-- *** templates affecting structure *** -->
    
    <xd:doc>
        <xd:desc>Converts the mnx element to mei.</xd:desc>
    </xd:doc>
    <xsl:template match="mnx" mode="structure">
        <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="4.0.1-rc1+basic">
            
            <xsl:comment select="'Converted from MNX file ' || document-uri($mnx.file) || ' with mnx2mei.xsl on ' || current-date()"/>
            
            <!-- insert an empty header if no header is present in MNX -->
            <xsl:if test="not(head)">
                <meiHead>
                    <fileDesc corresp="{tokenize(document-uri($mnx.file),'/')[last()]}">
                        <titleStmt>
                            <title/>
                        </titleStmt>
                        <pubStmt/>
                    </fileDesc>                    
                </meiHead>    
            </xsl:if>
            <!-- continue processing -->
            <xsl:apply-templates select="node()" mode="structure"/>
        </mei>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template builds the very basic structure of an MEI file from the MNX.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="score" mode="structure">
        <xsl:variable name="mnx.common" select="child::mnx-common[@profile='standard']" as="node()"/>
        <music xmlns="http://www.music-encoding.org/ns/mei">
            <body>
                <mdiv>
                    <score>
                        <scoreDef-placeholder xmlns="temporary"/>
                        <section>
                            <xsl:for-each select="$mnx.common/global/measure">
                                <xsl:variable name="measure.pos" select="position()" as="xs:integer"/>
                                <measure>
                                    <xsl:attribute name="n" select="if(@index) then(@index) else if(some $m in $mnx.common/part/measure[$measure.pos] satisfies $m/@index) then(($mnx.common/part/measure[$measure.pos][@index])[1]/@index) else($measure.pos)"/>
                                    <xsl:if test="@number or (some $m in $mnx.common/part/measure[$measure.pos] satisfies $m/@number)">
                                        <mNum>
                                            <xsl:value-of select="if(@number) then(@number) else(($mnx.common/part/measure[$measure.pos][@number])[1]/@number)"/>
                                        </mNum>
                                    </xsl:if>
                                    <xsl:for-each select="$mnx.common/part">
                                        <xsl:variable name="part.pos" select="position()" as="xs:integer"/>
                                        <xsl:variable name="part.measure" select="measure[$measure.pos]" as="node()"/>
                                        <xsl:variable name="staff.count" select="if($part.measure//sequence/@staff) then(count(distinct-values($part.measure//sequence/@staff))) else(1)" as="xs:integer"/>
                                        <part xmlns="temporary" pos="{$part.pos}" staves="{$staff.count}">
                                            <xsl:copy-of select="$part.measure"/>
                                        </part>
                                    </xsl:for-each>
                                </measure>
                            </xsl:for-each>
                        </section>
                    </score>
                </mdiv>
            </body>
        </music>
    </xsl:template>
    
    
    
    <!-- *** templates affecting metadata *** -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Convert MNX metadata to MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="head" mode="header">
        <meiHead xmlns="http://www.music-encoding.org/ns/mei">
            <fileDesc corresp="{tokenize(document-uri($mnx.file),'/')[last()]}">
                <titleStmt>
                    <xsl:apply-templates select="title | subtitle | creator" mode="header.title"/>                    
                </titleStmt>
                <pubStmt>
                    <xsl:apply-templates select="rights" mode="header.pub"/>
                </pubStmt>
            </fileDesc>
        </meiHead>    
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts a main title to MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title" mode="header.title">
        <title type="main" xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="text()" mode="header"/>
        </title>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts a subordinate title to MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="subtitle" mode="header.title">
        <title type="subordinate" xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="text()" mode="header"/>
        </title>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts creators to MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="creator" mode="header.title">
        <xsl:choose>
            <xsl:when test="@type = 'composer'">
                <composer xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="text()" mode="header"/>
                </composer>
            </xsl:when>
            <xsl:when test="@type = 'lyricist'">
                <lyricist xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="text()" mode="header"/>
                </lyricist>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Converts legal information</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="rights" mode="header.pub">
        <availability xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="text()" mode="header"/>
        </availability>
    </xsl:template>
    
    
    
    <!-- *** templates parsing staff and layer *** -->
        
    <xd:doc>
        <xd:desc>
            <xd:p>Translates temporary parts into proper mei:staff and mei:layer.
                Considers that an mnx:part may require multiple staves.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="temp:part" mode="staves">
        <xsl:variable name="preceding.staves" select="sum(preceding-sibling::temp:part/xs:integer(@staves))" as="xs:integer"/>
        <xsl:variable name="own.staves" select="xs:integer(@staves)" as="xs:integer"/>
        <xsl:variable name="part.measure" select="." as="node()"/>
        
        <xsl:variable name="staff.labels" select="distinct-values($part.measure//sequence/@staff)" as="xs:string*"/>
        
        <xsl:for-each select="(1 to $own.staves)">
            <xsl:variable name="staff.pos" select="position()" as="xs:integer"/>
            <staff n="{($staff.pos + $preceding.staves)}" temp-part="{$part.measure/@pos}" xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:choose>
                    <xsl:when test="$own.staves gt 1">
                        <xsl:variable name="layers" select="$part.measure//sequence[@staff = $staff.labels[$staff.pos]]" as="node()+"/>
                        <xsl:for-each select="$layers">
                            <layer>
                                <xsl:if test="count($layers) gt 1">
                                    <xsl:attribute name="n" select="position()"/>
                                </xsl:if>
                                <xsl:apply-templates select="node()" mode="#current"/>
                            </layer>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="layers" select="$part.measure//sequence" as="node()+"/>
                        <xsl:for-each select="$layers">
                            <layer>
                                <xsl:if test="count($layers) gt 1">
                                    <xsl:attribute name="n" select="position()"/>
                                </xsl:if>
                                <xsl:apply-templates select="node()" mode="#current"/>
                            </layer>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>        
            </staff>
        </xsl:for-each>
        
        <xsl:if test="$part.measure/measure/directions">
            <controlEvents xmlns="temporary" staff="{if($own.staves = 1) then(($preceding.staves + 1)) else(string-join((for $num in 1 to $own.staves return (string($preceding.staves + $num))),' '))}">
                <xsl:copy-of select="$part.measure/measure/directions"/>
            </controlEvents>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- *** templates generating a scoreDef *** -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates the initial scoreDef</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="temp:scoreDef-placeholder" mode="scoreDef">
        <xsl:variable name="score" select="parent::mei:score" as="node()"/>
        <xsl:variable name="staves" select="distinct-values($score//mei:staff/@n)" as="xs:string+"/>
        <xsl:variable name="parts" select="distinct-values($score//mei:staff/@temp-part)" as="xs:string+"/>
        
        <scoreDef xmlns="http://www.music-encoding.org/ns/mei">
            
            <xsl:variable name="initial.timesig" select="$mnx.file//mnx-common/global/measure[1]//time/@signature" as="xs:string?"/>
            <xsl:variable name="initial.keysig" select="$mnx.file//mnx-common/global/measure[1]//key/@fifths" as="xs:string?"/>
            
            <xsl:if test="$initial.keysig">
                <xsl:choose>
                    <xsl:when test="starts-with($initial.keysig,'-')">
                        <xsl:attribute name="key.sig" select="substring-after($initial.keysig,'-') || 'f'"/>
                    </xsl:when>
                    <xsl:when test="$initial.keysig = '0'">
                        <xsl:attribute name="key.sig" select="'0'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="key.sig" select="$initial.keysig || 's'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
            <xsl:if test="$initial.timesig">
                <xsl:attribute name="meter.count" select="substring-before($initial.timesig,'/')"/>
                <xsl:attribute name="meter.unit" select="substring-after($initial.timesig,'/')"/>
            </xsl:if>
            
            <staffGrp>
                <xsl:for-each select="$parts">
                    <xsl:variable name="current.part" select="." as="xs:string"/>
                    <xsl:variable name="current.staves" select="distinct-values($score//mei:staff[@temp-part = $current.part]/@n)" as="xs:string+"/>
                    <xsl:variable name="part.elem" select="$mnx.file//mnx-common/part[position() = xs:integer($current.part)]" as="node()"/>
                    <xsl:choose>
                        <xsl:when test="count($current.staves) gt 1">
                            <staffGrp>
                                <xsl:if test="$part.elem/part-name">
                                    <label><xsl:value-of select="$part.elem/part-name/text()"/></label>
                                </xsl:if>
                                <xsl:for-each select="$current.staves">
                                    <xsl:variable name="staff.in.part" select="position()" as="xs:integer"/>                                    
                                    <staffDef n="{.}" lines="5">
                                        <xsl:variable name="clef.elem" select="$part.elem/measure[1]/directions/clef[$staff.in.part]" as="node()?"/>
                                        <xsl:if test="$clef.elem">
                                            <clef shape="{$clef.elem/@sign}" line="{$clef.elem/@line}"/>                                        
                                        </xsl:if>
                                    </staffDef>
                                </xsl:for-each>    
                            </staffGrp>
                        </xsl:when>
                        <xsl:otherwise>
                            <staffDef n="{$current.staves}" lines="5">
                                <xsl:if test="$part.elem/part-name">
                                    <label><xsl:value-of select="$part.elem/part-name/text()"/></label>
                                </xsl:if>
                                <xsl:variable name="clef.elem" select="$part.elem/measure[1]/directions/clef" as="node()?"/>
                                <xsl:if test="$clef.elem">
                                    <clef shape="{$clef.elem/@sign}" line="{$clef.elem/@line}"/>                                      
                                </xsl:if>                                
                            </staffDef>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </staffGrp>
        </scoreDef>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Removes a temporary attribute</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@temp-part" mode="scoreDef"/>
    
    
    
    <!-- *** templates translating individual events *** -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Translates MNX events into their MEI counterparts</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="event" mode="events">
        <xsl:variable name="event" select="." as="node()"/>
        
        <xsl:choose>
            <xsl:when test="rest and $event/@measure = 'yes'">
                <mRest xmlns="http://www.music-encoding.org/ns/mei"/>                    
            </xsl:when>
            <xsl:when test="rest">
                <rest xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="temp:parseDuration($event/@value)"/>
                </rest>
            </xsl:when>
            <xsl:when test="count(note) gt 1">
                <chord xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="temp:parseDuration($event/@value)"/>
                    <xsl:for-each select="note">
                        <xsl:variable name="note" select="." as="node()"/>
                        <note>
                            <xsl:sequence select="temp:parsePitch($note/@pitch)"/>
                            <xsl:sequence select="temp:parseAccidentals($note)"/>
                        </note>
                    </xsl:for-each>
                </chord>
            </xsl:when>
            <xsl:when test="count(note) = 1">
                <note xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="temp:parseDuration($event/@value)"/>
                    <xsl:sequence select="temp:parsePitch($event/note/@pitch)"/>
                    <xsl:sequence select="temp:parseAccidentals($event/note)"/>
                    
                    <!-- TODO: Lyrics are pretty unstable as of 2020/04, so the following implementation is more or less just a guess. Also: Need to consider chords with lyrics -->
                    <xsl:apply-templates select="lyric" mode="#current"/>
                </note>
            </xsl:when>
            <xsl:when test="not(note) and not(rest) and $event/@measure = 'yes'">
                <mSpace xmlns="http://www.music-encoding.org/ns/mei"/>
            </xsl:when>
            <xsl:when test="not(note) and not(rest)">
                <space xmlns="http://www.music-encoding.org/ns/mei">
                    <xsl:sequence select="temp:parseDuration($event/@value)"/>
                </space>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts lyrics.</xd:p>
            <xd:p><xd:b>Attention</xd:b>: Lyrics seem pretty unstable as of April 2020, so the following implementation is guesswork.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lyric" mode="events">
        <xsl:variable name="wordpos" as="xs:string?">
            <xsl:choose>
                <xsl:when test="@syllabic = 'single'"/>
                <xsl:when test="@syllabic = 'begin'"><xsl:value-of select="'i'"/></xsl:when>
                <xsl:when test="@syllabic = 'middle'"><xsl:value-of select="'m'"/></xsl:when>
                <xsl:when test="@syllabic = 'end'"><xsl:value-of select="'t'"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <verse xmlns="http://www.music-encoding.org/ns/mei">
            <syl>
                <xsl:if test="$wordpos">
                    <xsl:attribute name="wordpos" select="$wordpos"/>
                </xsl:if>
                <xsl:if test="$wordpos = ('i','m')">
                    <xsl:attribute name="con" select="'d'"/>
                </xsl:if>
                <xsl:apply-templates select="text()"/>
            </syl>    
        </verse>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts Beams</xd:p>
            <xd:p><xd:b>WARNING</xd:b>: MNX allows beams to cross barlines, utilizing 
                the @continue attribute on beamed (see 
                <xd:a href="https://w3c.github.io/mnx/specification/common/#element-attrdef-beamed-continue">MNX specs</xd:a>). 
                At this point, MEI Basic does not include the mei:beamSpan element, so 
                potentially data is lost when converting to MEI. If this kind of information 
                is present in an MNX input file, a warning will be given as xsl:message. 
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="beamed" mode="events">
        <beam xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="node() | @id" mode="#current"/>
        </beam>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts tuplets</xd:p>
            <xd:p><xd:b>Attention</xd:b>: There is some inconsistency between the MNX specs and some sample files, namely 
                <xd:a href="https://github.com/w3c/mnx/blob/master/examples/FaurReveSample-common.xml">Fauré: Après un rêve</xd:a>. 
                This affects the names of attributes (@inner / @outer vs. @actual / @normal). This stylesheet follows the specs,
                which seem to be more up-to-date.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tuplet" mode="events">
        <tuplet xmlns="http://www.music-encoding.org/ns/mei">
            
            <xsl:variable name="inner.unit" select="xs:integer(substring-after(@inner,'/'))" as="xs:integer"/>
            <xsl:variable name="outer.unit" select="xs:integer(substring-after(@outer,'/'))" as="xs:integer"/>
            <xsl:variable name="unit.ratio" select="$inner.unit div $outer.unit" as="xs:double"/>
            
            <xsl:variable name="inner.count" select="xs:integer(substring-before(@inner,'/'))" as="xs:integer"/>
            <xsl:variable name="outer.count" select="xs:integer(substring-before(@outer,'/'))" as="xs:integer"/>
            
            <xsl:attribute name="num" select="$inner.count"/>
            <xsl:attribute name="numbase" select="$outer.count * $unit.ratio"/>
            
            <xsl:if test="@show-number = 'none'">
                <xsl:attribute name="num.visible" select="'false'"/>
            </xsl:if>
            <xsl:if test="@show-number = 'inner' and @show-value = 'inner'">
                <xsl:attribute name="num.format" select="'ratio'"/>
            </xsl:if>
            <xsl:if test="@bracket and @bracket != 'auto'">
                <xsl:attribute name="bracket.visible" select="if(@bracket = 'yes') then('true') else('false')"/>
            </xsl:if>
            
            <xsl:apply-templates select="node()" mode="#current"/>
        </tuplet>
    </xsl:template>
    
    
    <!-- *** templates translating individual controlevents *** -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Translates MNX controlevents into their MEI counterparts</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:measure" mode="controlevents">
        <xsl:copy>
            <xsl:apply-templates select="mei:staff | @*" mode="#current"/>
            
            <xsl:variable name="full.staff.ces" select="temp:controlEvents" as="node()*"/>
            <xsl:variable name="single.layer.ces" select=".//mei:layer/directions" as="node()*"/>
            <xsl:variable name="all.ces" select="$full.staff.ces | $single.layer.ces" as="node()*"/>
            
            <xsl:apply-templates select="$all.ces//dynamics" mode="#current"/>
            
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Removing temporary placeholders</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="temp:controlEvents | directions" mode="controlevents"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts MNX dynamics to MEI dynam</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="dynamics" mode="controlevents">
        <xsl:variable name="starts.layer" select="exists(parent::directions[count(preceding-sibling::*) = 0 and parent::mei:layer])" as="xs:boolean"/>
        
        <xsl:variable name="tstamp" select="if($starts.layer) then('1') else('1')" as="xs:string"/>
        <xsl:variable name="staff" select="ancestor::mei:staff/@n" as="xs:string"/>
        
        <dynam xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="staff" select="$staff"/>
            <xsl:attribute name="tstamp" select="$tstamp"/>
            <xsl:value-of select="@type"/>
        </dynam>
    </xsl:template>
    
    
    <!-- *** generic functions *** -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>This function parses MNX durations to their MEI counterpart</xd:p>
        </xd:desc>
        <xd:param name="value">The input value, as specified by <xd:a href="https://w3c.github.io/mnx/specification/common/#note-value-syntax">MNX</xd:a>.</xd:param>
        <xd:return>Returns at least a @dur attribute, and if necessary also a @dots.</xd:return>
    </xd:doc>
    <xsl:function name="temp:parseDuration" as="attribute()+">
        <xsl:param name="value" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="starts-with($value,'*2')">
                <xsl:attribute name="dur" select="'breve'"/>
            </xsl:when>
            <xsl:when test="starts-with($value,'*4')">
                <xsl:attribute name="dur" select="'long'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="dur" select="replace($value,'[^\d]','')"/>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:variable name="dots" select="string-length(replace($value,'[^d]',''))" as="xs:integer"/>
        <xsl:if test="$dots gt 0">
            <xsl:attribute name="dots" select="$dots"/>
        </xsl:if>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This function parses MNX pitches into their MEI counterparts</xd:p>
        </xd:desc>
        <xd:param name="pitch">The original pitch attribute, as specified by <xd:a href="https://w3c.github.io/mnx/specification/common/#element-attrdef-note-pitch">MNX</xd:a>.</xd:param>
        <xd:return>Returns at least @pname and @oct attributes. Accidentals are handled separately.</xd:return>
    </xd:doc>
    <xsl:function name="temp:parsePitch" as="attribute()+">
        <xsl:param name="pitch" as="xs:string"/>
        
        <xsl:variable name="pname" select="lower-case(substring($pitch,1,1))" as="xs:string"/>
        <xsl:attribute name="pname" select="$pname"/>
        
        <xsl:variable name="oct" select="replace($pitch,'[^\d]','')" as="xs:string"/>
        <xsl:attribute name="oct" select="$oct"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This function generates mei:accid elements</xd:p>
        </xd:desc>
        <xd:param name="note">The original MNX note</xd:param>
        <xd:return>If applicable, an accid element with either @accid.ges or @accid as necessary.</xd:return>
    </xd:doc>
    <xsl:function name="temp:parseAccidentals" as="node()?">
        <xsl:param name="note" as="node()"/>
        
        <xsl:variable name="flats.ges" select="string-length(replace($note/@pitch,'[^b]',''))" as="xs:integer"/>
        <xsl:variable name="sharps.ges" select="string-length(replace($note/@pitch,'[^#]',''))" as="xs:integer"/>
        
        <xsl:variable name="accid.ges" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$flats.ges = 1"><xsl:value-of select="'f'"/></xsl:when>
                <xsl:when test="$sharps.ges = 1"><xsl:value-of select="'s'"/></xsl:when>
                <xsl:when test="$flats.ges = 2"><xsl:value-of select="'ff'"/></xsl:when>
                <xsl:when test="$sharps.ges = 2"><xsl:value-of select="'x'"/></xsl:when>
                <xsl:when test="$flats.ges = 3"><xsl:value-of select="'tf'"/></xsl:when>
                <xsl:when test="$sharps.ges = 3"><xsl:value-of select="'xs'"/></xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="accid" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$note/@accidental = 'sharp'"><xsl:value-of select="'s'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'natural'"><xsl:value-of select="'n'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'flat'"><xsl:value-of select="'f'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'double-sharp'"><xsl:value-of select="'x'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'sharp-sharp'"><xsl:value-of select="'ss'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'flat-flat'"><xsl:value-of select="'ff'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'natural-sharp'"><xsl:value-of select="'ns'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'natural-flat'"><xsl:value-of select="'nf'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'quarter-flat'"><xsl:value-of select="'1qf'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'quarter-sharp'"><xsl:value-of select="'1qs'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'three-quarters-flat'"><xsl:value-of select="'3qf'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'three-quarters-sharp'"><xsl:value-of select="'3qs'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'sharp-down'"><xsl:value-of select="'sd'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'sharp-up'"><xsl:value-of select="'su'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'natural-down'"><xsl:value-of select="'nd'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'natural-up'"><xsl:value-of select="'nu'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'flat-down'"><xsl:value-of select="'fd'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'flat-up'"><xsl:value-of select="'fu'"/></xsl:when>
                <!--<xsl:when test="$note/@accidental = 'double-sharp-down'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'double-sharp-up'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'flat-flat-down'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'flat-flat-up'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'arrow-down'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'arrow-up'"><xsl:value-of select="''"/></xsl:when>-->
                <xsl:when test="$note/@accidental = 'triple-sharp'"><xsl:value-of select="'ts'"/></xsl:when>
                <xsl:when test="$note/@accidental = 'triple-flat'"><xsl:value-of select="'tf'"/></xsl:when>
                <!--<xsl:when test="$note/@accidental = 'slash-quarter-sharp'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'slash-sharp'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'slash-flat'"><xsl:value-of select="''"/></xsl:when>
                <xsl:when test="$note/@accidental = 'double-slash-flat'"><xsl:value-of select="''"/></xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$accid or $accid.ges">
            <accid xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:choose>
                    <xsl:when test="$accid and $accid.ges and $accid eq $accid.ges">
                        <xsl:attribute name="accid" select="$accid"/>
                    </xsl:when>
                    <xsl:when test="$accid and $accid.ges and $accid ne $accid.ges">
                        <xsl:attribute name="accid" select="$accid"/>
                        <xsl:attribute name="accid.ges" select="$accid.ges"/>
                    </xsl:when>
                    <xsl:when test="$accid">
                        <xsl:attribute name="accid" select="$accid"/>
                    </xsl:when>
                    <xsl:when test="$accid.ges">
                        <xsl:attribute name="accid.ges" select="$accid.ges"/>
                    </xsl:when>
                </xsl:choose>
            </accid>
        </xsl:if>
        
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This function uses a simple set of XPath checks to determine wether an input file matches the expectations about a valid MNX file.</xd:p>
        </xd:desc>
        <xd:param name="mnx">The original MNX file to be checked.</xd:param>
        <xd:return>A boolean value specifying the results of the tests.</xd:return>
    </xd:doc>
    <xsl:function name="temp:checkCompatibility" as="xs:boolean">
        <xsl:param name="mnx" as="node()"/>
        
        <xsl:variable name="is.mnx.common" select="$mnx//score/mnx-common[@profile = 'standard']" as="xs:boolean"/>
        <xsl:if test="not($is.mnx.common)">
            <xsl:message select="'[FATAL] The input file does not match the expectations for an MNX Common file. Processing will be terminated.'"/>
        </xsl:if>
        
        <xsl:variable name="global.measures" select="$mnx//mnx-common/global/measure" as="node()*"/>
        <xsl:variable name="measures.match" select="every $part in $mnx//mnx-common/part satisfies (count($part/measure) = count($global.measures))" as="xs:boolean"/>
        <xsl:if test="not($measures.match)">
            <xsl:message select="'[FATAL] The number of measures does not match between all parts and the global setup. Processing will be stopped.'"/>
        </xsl:if>
        
        <!-- non-critical tests -->
        <xsl:if test="$mnx//beamed/@continue">
            <xsl:message select="'[WARNING] The input file contains one or more beams crossing a barline, which is out of scope for the MEI Basic profile. Information on continued beams will be lost for now.'"/>
        </xsl:if>
        
        <xsl:if test="$mnx//tuplet[@actual or @normal]">
            <xsl:message select="'[WARNING] The input file apparently conforms to an outdated draft of MNX, by using @actual and / or @normal on tuplet elements. At the time of writing this XSLT (April 2020), the MNX specs require the use of @inner / @outer instead. Please update your input file accordingly.'"/>
        </xsl:if>
        
        <xsl:value-of select="$is.mnx.common and $measures.match"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Translates IDs from custom namespace to official XML namespace.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@id" mode="#all">
        <xsl:attribute name="xml:id" select="."/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A simple copy template. Some modes are intentionally left out to sort elements into different locations in MEI.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="structure header staves scoreDef events controlevents">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>