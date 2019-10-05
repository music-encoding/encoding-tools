<?xml version="1.0" encoding="UTF-8" ?>

<!--

	mei2pae.xsl - XSLT (1.0) stylesheet for creating incipits in Plaine & Easie Code from MEI

  Klaus Rettinghaus <rettinghaus@bach-leipzig.de>
  Saxon Academy of Sciences and Humanities in Leipzig

	For info on MEI, see http://music-encoding.org
	For info on Plaine & Easie Code, see https://www.iaml.info/plaine-easie-code

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.loc.gov/MARC21/slim" xmlns:mei="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="mei">
  <xsl:output method="text" encoding="UTF-8" indent="no" media-type="text/txt" />
  <xsl:strip-space elements="*" />

  <!-- Parameters -->
  <!-- These define the "leading voice" and the length of the incipit -->
  <!-- Default is the first voice with a length of 4 measures -->
  <xsl:param name="staff">1</xsl:param>
  <xsl:param name="layer">1</xsl:param>
  <xsl:param name="measures">4</xsl:param>

  <!-- Global variables -->
  <!-- version -->
  <xsl:variable name="version">
    <xsl:text>1.0 BETA</xsl:text>
  </xsl:variable>

  <!-- Main ouput templates -->
  <xsl:template match="/">
    <!-- select only the first score in the file -->
    <xsl:apply-templates select="descendant::mei:score[1]" />
  </xsl:template>

  <xsl:template match="mei:measure" mode="music">
    <xsl:apply-templates select="mei:staff[@n = $staff]|mei:staffDef" />
    <xsl:call-template name="setBarline" />
  </xsl:template>

  <xsl:template match="mei:measure" mode="lyrics">
    <xsl:if test="position() &lt;= $measures">
      <xsl:apply-templates select="mei:staff[@n = $staff]/mei:layer[1]//mei:syl" />
    </xsl:if>
  </xsl:template>

  <!-- MEI beam -->
  <xsl:template match="mei:beam">
    <xsl:value-of select="'{'" />
    <xsl:apply-templates />
    <xsl:value-of select="'}'" />
  </xsl:template>

  <!-- MEI clef -->
  <xsl:template name="setClef" match="mei:clef|@*[starts-with(name(),'clef')]">
    <xsl:param name="clefShape" select="(//@shape|ancestor-or-self::*/@clef.shape)[1]" />
    <xsl:param name="clefLine" select="(//@line|ancestor-or-self::*/@clef.line)[1]" />
    <xsl:value-of select="concat('%', $clefShape, '-', $clefLine)" />
  </xsl:template>

  <!-- MEI chord -->
  <xsl:template match="mei:chord">
    <xsl:call-template name="setDuration" />
    <xsl:call-template name="setDots" />
    <xsl:for-each select="mei:note">
      <xsl:call-template name="setOctave" />
      <xsl:call-template name="setAccidental" />
      <xsl:value-of select="translate(@pname, 'cdefgab', 'CDEFGAB')" />
      <xsl:value-of select="'^'" />
    </xsl:for-each>
  </xsl:template>

  <!-- MEI key signature -->
  <xsl:template name="setKey" match="mei:keySig|@*[starts-with(name(),'key')]">
    <xsl:param name="keyTonic" select="(@pname|ancestor-or-self::*/@key.pname)[1]" />
    <xsl:param name="keyAccid" select="(@accid|ancestor-or-self::*/@key.accid)[1]" />
    <xsl:param name="keyMode" select="(@mode|ancestor-or-self::*/@key.mode)[1]" />
    <xsl:param name="keySig" select="(@sig|ancestor-or-self::*/@key.sig)[1]" />
    <xsl:param name="keySigMixed" select="(@sig.mixed|ancestor-or-self::*/@key.sig.mixed)[1]" />
    <xsl:if test="$keySig != 'mixed'">
      <xsl:value-of select="'$'" />
      <xsl:choose>
        <xsl:when test="$keySig='1s'">
          <xsl:text>xF</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='2s'">
          <xsl:text>xFC</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='3s'">
          <xsl:text>xFCG</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='4s'">
          <xsl:text>xFCGD</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='5s'">
          <xsl:text>xFCGDA</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='6s'">
          <xsl:text>xFCGDAE</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='7s'">
          <xsl:text>xFCGDAEB</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='1f'">
          <xsl:text>bB</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='2f'">
          <xsl:text>bBE</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='3f'">
          <xsl:text>bBEA</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='4f'">
          <xsl:text>bBEAD</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='5f'">
          <xsl:text>bBEADG</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='6f'">
          <xsl:text>bBEADGC</xsl:text>
        </xsl:when>
        <xsl:when test="$keySig='7f'">
          <xsl:text>bBEADGCF</xsl:text>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- MEI layer -->
  <xsl:template match="mei:layer[not(@n)][1]">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="mei:layer[@n = $layer]">
    <xsl:apply-templates />
  </xsl:template>

  <!-- MEI measure rest -->
  <xsl:template match="mei:mRest">
    <xsl:text>=</xsl:text>
  </xsl:template>

  <!-- MEI multi measure rest -->
  <xsl:template match="mei:multiRest">
    <xsl:value-of select="concat('=', @num)" />
  </xsl:template>

  <!-- MEI note -->
  <xsl:template match="mei:note">
    <xsl:call-template name="setOctave" />
    <xsl:call-template name="setDuration" />
    <xsl:if test="@grace">
      <xsl:text>q</xsl:text>
    </xsl:if>
    <xsl:call-template name="setAccidental" />
    <xsl:value-of select="translate(@pname, 'cdefgab', 'CDEFGAB')" />
    <xsl:call-template name="setDots" />
  </xsl:template>

  <!-- MEI rest -->
  <xsl:template match="mei:rest">
    <xsl:call-template name="setDuration" />
    <xsl:text>-</xsl:text>
  </xsl:template>

  <!-- MEI section -->
  <xsl:template match="mei:section">
    <xsl:apply-templates />
  </xsl:template>

  <!-- MEI staff -->
  <xsl:template match="mei:staff">
    <xsl:apply-templates />
  </xsl:template>

  <!-- MEI score -->
  <xsl:template match="mei:score">
    <xsl:apply-templates select="//mei:staffDef[@n = $staff]|/descendant::mei:measure[position() &lt;= $measures]" mode="music" />
  </xsl:template>

  <!-- MEI staff definition -->
  <xsl:template match="mei:staffDef" mode="music">
    <xsl:variable name="accidental" select="ancestor-or-self::*/@key.sig" />
    <!-- clef -->
    <xsl:call-template name="setClef" />
    <!-- key -->
    <xsl:if test="(substring($accidental, string-length($accidental), 1) = 'f') or (substring($accidental, string-length($accidental), 1) = 's')">
      <xsl:call-template name="setKey" />
    </xsl:if>
    <!-- meter -->
    <xsl:if test="ancestor-or-self::*/@*[starts-with(name(),'meter')]">
      <xsl:value-of select="'@'" />
      <xsl:call-template name="meterSig">
        <xsl:with-param name="meterSymbol" select="ancestor-or-self::*/@meter.sym[1]" />
        <xsl:with-param name="meterCount" select="ancestor-or-self::*/@meter.count[1]" />
        <xsl:with-param name="meterUnit" select="ancestor-or-self::*/@meter.unit[1]" />
        <xsl:with-param name="meterRend" select="ancestor-or-self::*/@meter.form[1]" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="position()=1">
      <xsl:value-of select="' '" />
    </xsl:if>
  </xsl:template>

  <!-- MEI syllable -->
  <xsl:template match="mei:syl">
    <xsl:apply-templates />
    <xsl:if test="@wordpos='t' or @con!='d'">
      <xsl:text></xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="meterSig" match="mei:meterSig">
    <xsl:param name="meterSymbol" select="@sym" />
    <xsl:param name="meterCount" select="@count" />
    <xsl:param name="meterUnit" select="@unit" />
    <xsl:param name="meterRend" select="@form" />
    <xsl:choose>
      <xsl:when test="$meterRend = 'invis'"></xsl:when>
      <xsl:when test="$meterSymbol">
        <!-- data.METERSIGN -->
        <xsl:choose>
          <xsl:when test="$meterSymbol = 'common'">
            <xsl:value-of select="'c'" />
          </xsl:when>
          <xsl:when test="$meterSymbol = 'cut'">
            <xsl:value-of select="'c/'" />
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$meterRend = 'num'">
        <xsl:value-of select="$meterCount" />
      </xsl:when>
      <xsl:when test="$meterUnit">
        <xsl:value-of select="concat($meterCount,'/',$meterUnit)" />
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <!-- Helper templates -->
  <!-- set accidental -->
  <xsl:template name="setAccidental">
    <xsl:param name="accidental" select=".//@accid" />
    <!-- data.ACCIDENTAL.WRITTEN -->
    <xsl:if test="$accidental = 's'">
      <xsl:text>x</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'f'">
      <xsl:text>b</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'ss'">
      <xsl:text>xx</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'x'">
      <xsl:text>xx</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'ff'">
      <xsl:text>bb</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'n'">
      <xsl:text>n</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="setBarline">
    <xsl:param name="barLineStyle" select="@right" />
    <!-- data.BARRENDITION -->
    <xsl:choose>
      <xsl:when test="starts-with($barLineStyle, 'dbl')">
        <xsl:text>//</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='invis'"></xsl:when>
      <xsl:when test="$barLineStyle='rptstart'">
        <xsl:text>//:</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='rptboth'">
        <xsl:text>://:</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='rptend'">
        <xsl:text>://</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='single'">
        <xsl:text>/</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>/</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="setDots">
    <xsl:param name="dots" select="@dots" />
    <xsl:if test="$dots &gt; 0">
      <xsl:text>.</xsl:text>
      <xsl:call-template name="setDots">
        <xsl:with-param name="dots" select="$dots - 1" />
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="mei:dot" />
  </xsl:template>

  <xsl:template name="setDuration">
    <xsl:param name="durval" select="@dur" />
    <!-- data.DURATION -->
    <xsl:choose>
      <xsl:when test="@dur = 'long'">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:when test="@dur = 'breve'">
        <xsl:text>9</xsl:text>
      </xsl:when>
      <xsl:when test="@dur = '16'">
        <xsl:text>6</xsl:text>
      </xsl:when>
      <xsl:when test="@dur = '32'">
        <xsl:text>3</xsl:text>
      </xsl:when>
      <xsl:when test="@dur = '64'">
        <xsl:text>6</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@dur" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="setOctave">
    <xsl:param name="oct">
      <xsl:choose>
        <xsl:when test="@oct &gt; 3">
          <xsl:value-of select="@oct - 3" />
        </xsl:when>
        <xsl:when test="@oct &lt; 4">
          <xsl:value-of select="@oct - 4" />
        </xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$oct &lt; 0">
        <xsl:text>,</xsl:text>
        <xsl:call-template name="setOctave">
          <xsl:with-param name="oct" select="$oct + 1" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$oct &gt; 0">
        <xsl:text>'</xsl:text>
        <xsl:call-template name="setOctave">
          <xsl:with-param name="oct" select="$oct - 1" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>