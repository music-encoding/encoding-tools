<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="xs math xd" version="3.0">


  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> 2023–2025</xd:p>
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


  <!-- ======================================================================= -->
  <!-- PARAMETERS                                                              -->
  <!-- ======================================================================= -->

  <xd:doc scope="component">
    <xd:desc>
      <xd:p>A static parameter to define the output mode.</xd:p>
      <xd:p>Options are:</xd:p>
      <xd:ul>
        <xd:li><xd:b>documentation</xd:b> this will return the original file with added documentation of applying meiLint.xsl.</xd:li>
        <xd:li><xd:b>clean</xd:b> this will return the file as single-line, stripped from linebreaks and indentation whitespace.</xd:li>
        <xd:li><xd:b>lint</xd:b> this will first clean (as by the above option) and afterwards indent the file.</xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>
  <xsl:param name="output-mode" static="yes" select="'lint'" as="xs:string"/>


  <xd:doc>
    <xd:desc>
      <xd:p>A character sequence used for indentation</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="indentation-characters" select="'  '" as="xs:string"/>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Sequence of element local-names that should be preceded by a newline character and indentation.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="elements.break-before" select="('addrLine', 'lb', 'mei', 'meiHead', 'pb')" as="xs:string*"/>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Sequence od element local-names that should never be preceded by a newline character and indentation.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="elements.no-break" select="('rend')" as="xs:string*"/>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Sequence of element local-names, the contents of which should not be indented.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="elements.do-not-break-contents" select="('addrLine', 'desc', 'dir', 'head', 'p', 'rend', 'title')" as="xs:string*"/>


  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->


  <xd:doc scope="component">
    <xd:desc>URL of this XSLT</xd:desc>
  </xd:doc>
  <xsl:variable name="linter-url" as="xs:anyURI">https://github.com/music-encoding/encoding-tools/blob/main/meiLint/meiLint.xsl</xsl:variable>


  <xd:doc scope="component">
    <xd:desc>Version of this XSLT</xd:desc>
  </xd:doc>
  <xsl:variable name="linter-version" as="xs:string">v1.0.0</xsl:variable>


  <xd:doc scope="component">
    <xd:desc>Linter ID</xd:desc>
  </xd:doc>
  <xsl:variable name="linter-id" select="xs:ID('meiLint_' || $linter-version)" as="xs:ID"/>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Variable with new line character.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="nl" as="item()">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>


  <!-- ======================================================================= -->
  <!-- MAIN OUTPUT TEMPLATE                                                    -->
  <!-- ======================================================================= -->


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>The root template. Creates documentation, clean, and lint variables. Returns one of these, depending on the value of the 'output-mode' parameter.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/">

    <xsl:variable name="documentation" as="node()+">
      <xsl:apply-templates select="node() | @*" mode="documentation"/>
    </xsl:variable>

    <xsl:variable name="clean" as="node()+">
      <xsl:apply-templates select="$documentation" mode="clean"/>
    </xsl:variable>

    <xsl:variable name="lint" use-when="$output-mode = 'lint'" as="node()+">
      <xsl:apply-templates select="$clean" mode="lint"/>
    </xsl:variable>

    <xsl:copy-of select="$documentation" use-when="$output-mode = 'documentation'"/>

    <xsl:copy-of select="$clean" use-when="$output-mode = 'clean'"/>

    <xsl:copy-of select="$lint" use-when="$output-mode = 'lint'"/>

  </xsl:template>


  <!-- ======================================================================= -->
  <!-- NAMED TEMPLATES                                                    -->
  <!-- ======================================================================= -->


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

                <xsl:analyze-string select="." regex="^\s+|\s+$">

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


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Application documentation template.</xd:p>
    </xd:desc>
    <xd:return>An mei:application element describing this XSLT.</xd:return>
  </xd:doc>
  <xsl:template name="documentation-application">

    <xsl:choose>

      <xsl:when test="id($linter-id)">
        <!-- do nothing if an xml:id with the value of $linter-id can be found in the document --> </xsl:when>

      <xsl:otherwise>

        <!-- create an mei:application element -->

        <xsl:element name="application">

          <xsl:attribute name="version" select="$linter-version"/>

          <xsl:attribute name="xml:id" select="$linter-id"/>

          <xsl:element name="name">

            <xsl:value-of select="tokenize($linter-url, '/')[last()]"/>

          </xsl:element>

          <xsl:element name="ptr">

            <xsl:attribute name="target" select="$linter-url"/>

          </xsl:element>

        </xsl:element>

      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Change documentation template.</xd:p>
    </xd:desc>
    <xd:param name="n">The value for the n attribute of the generate mei:change element.</xd:param>
    <xd:return>An mei:change element.</xd:return>
    <xd:param name="n">The desired value for change/@n.</xd:param>
  </xd:doc>
  <xsl:template name="documentation-change">

    <xsl:param name="n" required="true" as="xs:NMTOKEN"/>

    <xsl:element name="change">

      <xsl:attribute name="n" select="$n"/>

      <xsl:attribute name="resp" select="'#' || $linter-id"/>

      <xsl:element name="changeDesc">

        <xsl:element name="p">Applied <xsl:value-of select="$output-mode"/> mode.</xsl:element>

      </xsl:element>

      <xsl:element name="date">

        <xsl:attribute name="isodate" select="format-dateTime(current-dateTime(), '[Y]-[M,2]-[D,2]T[H]:[m]:[s][Z]')"/>

      </xsl:element>

    </xsl:element>

  </xsl:template>


  <!-- ======================================================================= -->
  <!-- DOCUMENTATION-MODE TEMPLATES                                            -->
  <!-- ======================================================================= -->


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>
        <xd:b>documentation: root-element pre-ckeck for meiHead.</xd:b>
      </xd:p>
      <xd:p>Matches root elements that either are mei:meiHead or have a direct child mei:meiHead.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/mei:*[self::mei:meiHead or mei:meiHead]" mode="documentation">

    <xsl:copy>

      <xsl:apply-templates select="@* | node()" mode="documentation"/>

    </xsl:copy>

  </xsl:template>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Documentation for files without top-level mei:meiHead.</xd:p>
      <xd:p>Matches root elements that are not mei:meiHead and do not contain an mei:meiHead element as direct child.</xd:p>
    </xd:desc>
    <xd:return>Inserts XML-comments for documentation then processes the XML-tree.</xd:return>
  </xd:doc>
  <xsl:template match="/mei:*[not(mei:meiHead) and not(self::mei:meiHead)]" mode="documentation">

    <xsl:variable name="comment" as="text()">

      <xsl:call-template name="documentation-change">

        <xsl:with-param name="n" select="xs:NMTOKEN(1)"/>

      </xsl:call-template>

      <xsl:value-of select="$nl"/>

      <xsl:call-template name="documentation-application"/>

    </xsl:variable>

    <xsl:comment>
      
      <xsl:value-of select="$comment//mei:date/@isodate, $comment//mei:changeDesc/mei:p" separator=" – "/>
      
      <xsl:text> Agent: </xsl:text>
      
      <xsl:value-of select="$comment//mei:application/mei:ptr/@target, $comment//mei:application/@version" separator=" – "/>
    
    </xsl:comment>

    <xsl:apply-templates select="." mode="clone"/>

  </xsl:template>

  <xd:doc scope="component">
    <xd:desc>
      <xd:p>documentation: Insert documentation into top mei:meiHead.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/mei:*/mei:meiHead" mode="documentation">

    <xsl:variable name="exists-appInfo" select="exists(mei:encodingDesc/mei:appInfo)" as="xs:boolean"/>

    <xsl:variable name="exists-revisionDesc" select="exists(mei:reivisionDesc)" as="xs:boolean"/>

    <xsl:variable name="nodes-before-encodingDesc" select="mei:fileDesc/preceding-sibling::node(), mei:fileDesc" as="node()*"/>

    <xsl:variable name="nodes-after-encodingDesc" select="mei:fileDesc/following-sibling::node() except (mei:encodingDesc)" as="node()*"/>

    <xsl:variable name="nodes-after-appInfo" select="
        if ($exists-appInfo) then
          mei:encodingDesc/mei:appInfo/following-sibling::node()
        else
          mei:encodingDesc/node() except (mei:head)" as="node()*"/>

    <xsl:copy>

      <xsl:apply-templates select="@*" mode="documentation"/>

      <xsl:apply-templates select="$nodes-before-encodingDesc" mode="documentation"/>

      <xsl:element name="encodingDesc">

        <xsl:apply-templates select="mei:encodingDesc/@*" mode="documentation"/>

        <xsl:apply-templates select="mei:encodingDesc/mei:head" mode="documentation"/>

        <xsl:element name="appInfo">

          <xsl:apply-templates select="mei:encodingDesc/mei:appInfo/@* | mei:encodingDesc/mei:appInfo/node()" mode="documentation"/>

          <xsl:call-template name="documentation-application"/>

        </xsl:element>

        <xsl:apply-templates select="$nodes-after-appInfo" mode="documentation"/>

      </xsl:element>

      <xsl:apply-templates select="$nodes-after-encodingDesc except (mei:revisionDesc)" mode="documentation"/>

      <xsl:element name="revisionDesc">

        <xsl:variable name="count-change" select="xs:nonNegativeInteger(count(mei:revisionDesc/mei:change))" as="xs:nonNegativeInteger"/>

        <xsl:apply-templates select="mei:revisionDesc/@* | mei:revisionDesc/node()" mode="documentation"/>

        <xsl:call-template name="documentation-change">

          <xsl:with-param name="n" select="xs:NMTOKEN($count-change + 1)"/>

        </xsl:call-template>

      </xsl:element>

    </xsl:copy>

  </xsl:template>


  <!-- ========== CLEAN TEMPLATES ========== -->

  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Overwrite XSLT default templates to copy every node.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="node() | @*" mode="clean clone documentation">

    <xsl:copy>

      <xsl:apply-templates select="@* | node()" mode="#current"/>

    </xsl:copy>

  </xsl:template>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Cleanup namespace declarations on elements.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*" mode="clean">
    
    <xsl:variable name="name.new" as="xs:Name">
      
      <xsl:choose>

        <xsl:when test="namespace-uri() = 'http://www.music-encoding.org/ns/mei'">

          <xsl:copy-of select="xs:NCName(local-name())"/>

        </xsl:when>

        <xsl:otherwise>

          <xsl:copy-of select="xs:Name(name())"/>

        </xsl:otherwise>

      </xsl:choose>
      
    </xsl:variable>

    <xsl:element name="{$name.new}" namespace="{namespace-uri()}">

      <xsl:variable name="current-element" select="." as="element()"/>

      <xsl:for-each select="namespace::*">

        <xsl:variable name="prefix" select="name()" as="xs:string"/>

        <xsl:if test="$current-element/descendant::*[(namespace-uri() = current() and substring-before(name(), ':') = $prefix) or @*[substring-before(name(), ':') = $prefix]]">

          <xsl:copy-of select=".[. != 'http://www.music-encoding.org/ns/mei']"/>

        </xsl:if>

      </xsl:for-each>

      <xsl:apply-templates select="@* | node()" mode="clean"/>

    </xsl:element>

  </xsl:template>


  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Template for processing text nodes.</xd:p>
      <xd:p>Removes leading space character and trailing space or newline characters.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="text()" mode="clean">

    <xsl:variable name="number-of-nodes-in-parent" select="xs:nonNegativeInteger(count(parent::mei:*/node()))" as="xs:nonNegativeInteger"/>

    <xsl:variable name="index-in-parent" select="xs:nonNegativeInteger(position())" as="xs:nonNegativeInteger"/>

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


  <!-- ======================================================================= -->
  <!-- LINT-MODE TEMPLATES                                                     -->
  <!-- ======================================================================= -->


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

    <xsl:variable name="node-type" as="xs:string">

      <xsl:choose>

        <xsl:when test="$is-attribute">attribute</xsl:when>

        <xsl:when test="$is-element">element</xsl:when>

        <xsl:when test="$is-text">text</xsl:when>

        <xsl:otherwise>undetermined</xsl:otherwise>

      </xsl:choose>

    </xsl:variable>

    <xsl:message>LINT-MODE PROCESSING <xsl:value-of select="$node-type"/> NODE: <xsl:value-of select="local-name()"/> at: <xsl:value-of select="
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

    <xsl:variable name="nesting-depth" select="xs:nonNegativeInteger(count(ancestor::*))" as="xs:nonNegativeInteger"/>

    <xsl:variable name="indentation-start" select="
      if ($nesting-depth gt 0) then
        string-join(for $i in 1 to $nesting-depth return '  ')
      else ()" as="xs:string?"/>

    <xsl:variable name="indentation-end" select="
      if ($nesting-depth gt 0) then
        string-join(for $i in 1 to $nesting-depth - 1 return '  ')
      else ()" as="xs:string?"/>

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

      <xsl:variable name="nesting-depth" select="xs:nonNegativeInteger(count(ancestor::*))" as="xs:nonNegativeInteger"/>

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
