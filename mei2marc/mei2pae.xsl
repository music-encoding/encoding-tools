<?xml version="1.0" encoding="UTF-8"?>

<!--

	mei2pae.xsl - XSLT (1.0) stylesheet for creating incipits in Plaine & Easie Code from MEI

  Klaus Rettinghaus <rettinghaus@bach-leipzig.de>
  Saxon Academy of Sciences and Humanities in Leipzig

	For info on MEI, see http://music-encoding.org
	For info on Plaine & Easie Code, see https://www.iaml.info/plaine-easie-code

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns="http://www.loc.gov/MARC21/slim" xmlns:mei="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="mei">
  <xsl:output method="text" encoding="UTF-8" indent="no" media-type="text/txt"/>
  <xsl:strip-space elements="*"/>

  <!-- Parameters -->
  <xsl:param name="staff">1</xsl:param>
  <xsl:param name="layer">1</xsl:param>
  <xsl:param name="measures">4</xsl:param>

  <!-- Global variables -->
  <!-- version -->
  <xsl:variable name="version">
    <xsl:text>1.0 ALPHA</xsl:text>
  </xsl:variable>

  <!-- Main ouput template -->
  <xsl:template match="/">
    <xsl:apply-templates select="//mei:score"/>
  </xsl:template>

  <xsl:template match="mei:beam">
    <xsl:value-of select="'{'"/>
    <xsl:apply-templates/>
    <xsl:value-of select="'}'"/>
  </xsl:template>

  <xsl:template match="mei:chord">
    <xsl:call-template name="setDuration"/>
    <xsl:call-template name="setDots"/>
    <xsl:for-each select="mei:note">
      <xsl:call-template name="setOctave"/>
      <xsl:call-template name="setAccidental"/>
      <xsl:value-of select="translate(@pname, 'cdefgab', 'CDEFGAB')"/>
      <xsl:value-of select="'^'"/>
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
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:layer">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:measure">
    <xsl:if test="position() &lt;= $measures">
      <xsl:apply-templates select="mei:staff[@n = $staff]/mei:layer[@n = $layer]"/>
      <xsl:call-template name="setBarline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="meterSig" match="mei:meterSig">
    <xsl:param name="meterSymbol" select="@sym" />
    <xsl:param name="meterCount" select="@count" />
    <xsl:param name="meterUnit" select="@unit" />
    <xsl:param name="meterRend" select="@form" />
    <xsl:choose>
      <xsl:when test="$meterRend = 'invis'">
      </xsl:when>
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
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:multiRest">
    <xsl:value-of select="concat('=', @num)"/>
  </xsl:template>

  <xsl:template match="mei:mRest">
    <xsl:text>=</xsl:text>
  </xsl:template>

  <xsl:template match="mei:note">
    <xsl:call-template name="setOctave"/>
    <xsl:call-template name="setDuration"/>
    <xsl:if test="@grace">
      <xsl:text>q</xsl:text>
    </xsl:if>
    <xsl:call-template name="setAccidental"/>
    <xsl:value-of select="translate(@pname, 'cdefgab', 'CDEFGAB')"/>
    <xsl:call-template name="setDots"/>
  </xsl:template>

  <xsl:template match="mei:rest">
    <xsl:call-template name="setDuration"/>
    <xsl:text>-</xsl:text>
  </xsl:template>

  <xsl:template match="mei:section">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:score">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:staffDef[@n = $staff]">
    <xsl:variable name="accidental" select="ancestor-or-self::*/@key.sig"/>
    <!-- clef -->
    <xsl:value-of select="'%'"/>
    <xsl:value-of select="concat(.//@clef.shape, '-', .//@clef.line)"/>
    <!-- key -->
    <xsl:if test="(substring($accidental, string-length($accidental), 1) = 'f') or (substring($accidental, string-length($accidental), 1) = 's')">
      <xsl:value-of select="'$'"/>
      <xsl:call-template name="setKey"/>
    </xsl:if>
    <!-- meter -->
    <xsl:if test="ancestor-or-self::*/@*[starts-with(name(),'meter')]">
      <xsl:value-of select="'@'"/>
      <xsl:call-template name="meterSig">
        <xsl:with-param name="meterSymbol" select="ancestor-or-self::*/@meter.sym[1]" />
        <xsl:with-param name="meterCount" select="ancestor-or-self::*/@meter.count[1]" />
        <xsl:with-param name="meterUnit" select="ancestor-or-self::*/@meter.unit[1]" />
        <xsl:with-param name="meterRend" select="ancestor-or-self::*/@meter.form[1]" />
      </xsl:call-template>
    </xsl:if>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- Helper templates -->
  <!-- set accidental -->
  <xsl:template name="setAccidental">
    <xsl:param name="accidental" select=".//@accid"/>
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
      <xsl:when test="$barLineStyle='invis'">
      </xsl:when>
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
    <xsl:apply-templates select="mei:dot"/>
  </xsl:template>

  <xsl:template name="setDuration">
    <xsl:param name="durval" select="@dur"/>
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
        <xsl:value-of select="@dur"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="setOctave">
    <xsl:param name="oct">
      <xsl:choose>
        <xsl:when test="@oct &gt; 3">
          <xsl:value-of select="@oct - 3"/>
        </xsl:when>
        <xsl:when test="@oct &lt; 4">
          <xsl:value-of select="@oct - 4"/>
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
