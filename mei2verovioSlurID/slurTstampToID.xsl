<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output encoding="UTF-16"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="mei:slur">
        <xsl:variable name="staffN" select="@staff"/>
        <xsl:variable name="layerN" select="@layer"/>
        <xsl:variable name="events" select="../mei:staff[@n = $staffN]/mei:layer[@n = $layerN]//*[@dur]"/>
       
        <xsl:variable name="startid">
            <xsl:choose>
                <xsl:when test="@tstamp = 1"><xsl:value-of select ="$events[1]/@xml:id"/></xsl:when>
               <xsl:when test="@tstamp &gt; 1">
                   <xsl:call-template name="sumDur">
                       <xsl:with-param name="events" select="$events"/>
                       <xsl:with-param name="tstamp" select="@tstamp"/>
                   </xsl:call-template></xsl:when>
                <xsl:when test="@tstamp = 4"><xsl:value-of select ="$events[1]/@xml:id"/></xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="endid">
            <xsl:choose>
                <xsl:when test="@tstamp2 = 1"><xsl:value-of select ="$events[1]/@xml:id"/></xsl:when>
                <xsl:when test="@tstamp2 &gt; 1">
                    <xsl:call-template name="sumDur">
                        <xsl:with-param name="events" select="$events"/>
                        <xsl:with-param name="tstamp" select="@tstamp2"/>
                    </xsl:call-template></xsl:when>
                <xsl:when test="@tstamp2 = 4"><xsl:value-of select ="$events[1]/@xml:id"/></xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:if test="not(@startid)">
                <xsl:attribute name="startid" select="concat('#', $startid)">
           </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@endid)">
                <xsl:attribute name="endid" select="concat('#', $endid)">
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="sumDur">
        <xsl:param name="events"/>
        <xsl:param name="tstamp" as="xs:double"/>
        <xsl:param name="position" select ="1"/>
        <xsl:param name="sum" select="1" as="xs:double"/>
        
        <xsl:variable name="newsum" select="$sum + 4 div number($events[position()=$position]/@dur)"/>
        <!-- wenn Summe(@meter.unit / events/@dur) ≥ tstamp -->
        <xsl:choose>
            <xsl:when test="$newsum gt $tstamp">
                <xsl:value-of select ="$events[position()=$position]/@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="sumDur">
                    <xsl:with-param name="events" select="$events"/>
                    <xsl:with-param name="tstamp" select="$tstamp"/>
                    <xsl:with-param name="position" select="$position + 1"/>
                    <xsl:with-param name="sum" select="$newsum"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>