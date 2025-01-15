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
            <xd:p><xd:b>Created on:</xd:b> Jan 13, 2025</xd:p>
            <xd:p><xd:b>Author:</xd:b> Benjamin W. Bohl</xd:p>
            <xd:p><xd:b>Author:</xd:b> Stefan Münnich</xd:p>
            <xd:p>This XSLT translates an MEI v4 file to an MEI v5.1 file.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- ======================================================================= -->
    <!-- IMPORTS                                                                 -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>Import MEI v4 to v5.0 Stylesheet to reuse transformation.</xd:desc>
    </xd:doc>
    <xsl:import href="../mei40To50/mei40To50.xsl"/>
    
    <xd:doc>
        <xd:desc>Import MEI v5.0 to v5.1 Stylesheet to reuse transformation.</xd:desc>
    </xd:doc>
    <xsl:import href="../mei50To51/mei50To51.xsl"/>
    
    <!-- ======================================================================= -->
    <!-- PARAMETERS                                                              -->
    <!-- ======================================================================= -->
    
    <!-- see mei40To50.xsl -->
    
    <!-- ======================================================================= -->
    <!-- GLOBAL VARIABLE OVERRIDES                                               -->
    <!-- ======================================================================= -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>program id</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="progId" as="xs:string">
        <xsl:text>mei40To51</xsl:text>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>program version</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="progVersion" as="xs:string">
        <xsl:text>1.0</xsl:text>
    </xsl:variable>
    
</xsl:stylesheet>
