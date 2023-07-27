<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="xs math xd" version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jul 25, 2023</xd:p>
      <xd:p><xd:b>Author:</xd:b> Benjamin W. Bohl</xd:p>
      <xd:p>This XSLT is intended for linting Music Encoding Initiative flavoured XML files.</xd:p>
    </xd:desc>
  </xd:doc>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>The output format definition.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output media-type="text/xml" method="xml" indent="false" encoding="UTF-8" omit-xml-declaration="no"/>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>A static parameter to define the output mode.</xd:p>
      <xd:p>Otions are:</xd:p>
      <xd:ul>
        <xd:li><xd:b>clean</xd:b> this will return the file as single-line, stripped from linebreaks and indentation whitespace.</xd:li>
        <xd:li><xd:b>lint</xd:b> this will first clean (as by the above option) and afterwards indent the file.</xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>
  <xsl:param name="output-mode" static="yes"/>
  <xd:doc>
    <xd:desc>
      <xd:p>A character sequence used for indentation</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="indentation-characters" select="'  '"/>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Sequence of element local-names that should be preceded by a newline character and indentation.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="elements.break-before" select="('addrLine', 'lb', 'mei', 'meiHead', 'pb')"/>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Sequence od element local-names that should never be preceded by a newline character and indentation.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="elements.no-break" select="('rend')"/>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Sequence of element local-names, the contents of which should not be indented.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="elements.do-not-break-contents" select="('addrLine', 'desc', 'dir', 'head', 'p', 'rend', 'title')"/>
  <!-- ========== INTERNAL VARIABLES ========== -->
  <xd:doc scope="component">
    <xd:desc>Version of this XSLT</xd:desc>
  </xd:doc>
  <xsl:variable name="linter-version">0.0.1-alpha</xsl:variable>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Variable with new line character.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>
  <!-- ========== ROOT TEMPLATE ========== -->
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>The root template. Creates clean and optional lint variables. Switches to the desired output.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/">
    <xsl:variable name="clean">
      <xsl:apply-templates select="node() | @*" mode="clean"/>
    </xsl:variable>
    <xsl:variable name="lint" use-when="$output-mode = 'lint'">
      <xsl:apply-templates select="$clean" mode="lint"/>
    </xsl:variable>
    <xsl:copy-of select="$clean" use-when="$output-mode = 'clean'"/>
    <xsl:copy-of select="$lint" use-when="$output-mode = 'lint'"/>
  </xsl:template>
  <!-- ========== NAMED TEMPLATES ========== -->
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Template for text nodes to get rid of whitespace an newline characters.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template name="normalize_space-break">
    <xsl:analyze-string select="." regex="[\n]+">
      <xsl:matching-substring/>
      <xsl:non-matching-substring>
        <xsl:analyze-string select="." regex="^[\n\s]+$">
          <xsl:matching-substring/>
          <xsl:non-matching-substring>
            <xsl:analyze-string select="." regex="^\s\s+">
              <xsl:matching-substring>
                <xsl:text> </xsl:text>
              </xsl:matching-substring>
              <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="^\s+">
                  <xsl:matching-substring/>
                  <xsl:non-matching-substring>
                    <xsl:copy/>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  <!-- ========== CLEAN TEMPLATES ========== -->
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Overwrite XSLT default templates to copy every node.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="node() | @*" mode="clean clone">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Template for processing text nodes.</xd:p>
      <xd:p>Removes leading space character and trailing space or newline characters.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="text()" mode="clean">
    <xsl:variable name="number-of-nodes-in-parent" select="count(parent::mei:*/node())"/>
    <xsl:variable name="index-in-parent" select="position()"/>
    <xsl:message>Info: <xsl:text>node number: </xsl:text><xsl:value-of select="$index-in-parent"/> of <xsl:value-of select="$number-of-nodes-in-parent"/> nodes in parent.</xsl:message>
    <xsl:choose>
      <xsl:when test="$index-in-parent = 1">
        <xsl:analyze-string select="." regex="^\s">
          <xsl:matching-substring/>
          <xsl:non-matching-substring>
            <xsl:call-template name="normalize_space-break"/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test="$index-in-parent = $number-of-nodes-in-parent">
        <xsl:analyze-string select="." regex="[\s\n]+$">
          <xsl:matching-substring/>
          <xsl:non-matching-substring>
            <xsl:call-template name="normalize_space-break"/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test=". = ' '">
        <xsl:copy/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="normalize_space-break"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- ========== LINT TEMPLATES ========== -->
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>lint: Default template.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="node() | @*" mode="lint">
    <xsl:message>========================================</xsl:message>
    <xsl:variable name="is-attribute" select="
        if (count(. | ../@*) = count(../@*)) then
          xs:boolean('true')
        else
          xs:boolean('false')" as="xs:boolean"/>
    <xsl:variable name="is-element" select="
        if (self::*) then
          xs:boolean('true')
        else
          xs:boolean('false')" as="xs:boolean"/>
    <xsl:variable name="is-text" select="
        if (self::text()) then
          xs:boolean('true')
        else
          xs:boolean('false')" as="xs:boolean"/>
    <xsl:variable name="node-type">
      <xsl:choose>
        <xsl:when test="$is-attribute">attribute</xsl:when>
        <xsl:when test="$is-element">element</xsl:when>
        <xsl:when test="$is-text">text</xsl:when>
        <xsl:otherwise>undetermined</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:message>PROCESSING <xsl:value-of select="$node-type"/> NODE: <xsl:value-of select="local-name()"/> at: <xsl:value-of select="
        string-join((for $e in ancestor-or-self::*
        return
          local-name($e)), '/')"/></xsl:message>
    <xsl:message>is text: <xsl:value-of select="$is-text"/></xsl:message>
    <xsl:variable name="has.no-break-ancestor" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="local-name(parent::*) = $elements.do-not-break-contents">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nesting-depth" select="count(ancestor::*)"/>
    <xsl:variable name="indentation-start" select="
        string-join(for $i in 1 to $nesting-depth
        return
          '  ')"/>
    <xsl:variable name="indentation-end" select="
        string-join(for $i in 1 to $nesting-depth - 1
        return
          '  ')"/>
    <xsl:message>is element: <xsl:value-of select="$is-element"/></xsl:message>
    <xsl:if test="self::comment() or (self::* and not(local-name(.) = $elements.no-break) and not($has.no-break-ancestor)) or local-name(.) = $elements.break-before">
      <xsl:message>nesting-depth: <xsl:value-of select="$nesting-depth"/></xsl:message>
      <xsl:message>indentation start: ›<xsl:value-of select="$indentation-start"/>‹</xsl:message>
      <xsl:message>indentation end: ›<xsl:value-of select="$indentation-end"/>‹</xsl:message>
      <xsl:copy-of select="$nl, $indentation-start"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="self::text()">
        <xsl:next-match/>
      </xsl:when>
      <xsl:when test="self::*">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
          <xsl:variable name="current-element" select="."/>
          <xsl:for-each select="namespace::*">
            <xsl:variable name="prefix" select="name()"/>
            <xsl:if test="$current-element/descendant::*[(namespace-uri() = current() and substring-before(name(), ':') = $prefix) or @*[substring-before(name(), ':') = $prefix]]">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
          <xsl:apply-templates select="@* | node()" mode="lint"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="self::comment()">
        <xsl:comment select="concat(' ', normalize-space(.), ' ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@* | node()" mode="lint"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="(self::* and not(local-name(.) = $elements.no-break)) or self::comment()">
      <xsl:variable name="nesting-depth" select="count(ancestor::*)"/>
      <xsl:variable name="indentation" select="
          string-join(for $i in 1 to $nesting-depth
          return
            '  ')"/>
      <xsl:if test="not($has.no-break-ancestor) and not(following-sibling::node())">
        <xsl:copy-of select="$nl"/>
        <xsl:copy-of select="$indentation-end"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>lint: Assure xml-model processing instruction are preceded by a newline character.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="processing-instruction('xml-model')" mode="lint">
    <xsl:copy-of select="$nl, ."/>
  </xsl:template>
</xsl:stylesheet>
