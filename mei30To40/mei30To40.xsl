<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.music-encoding.org/ns/mei" xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="mei xlink">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"/>
  <xsl:strip-space elements="*"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS                                                              -->
  <!-- ======================================================================= -->

  <!--  -->
  <xsl:param name="removeEmptyElements" select="true()"/>

  <!-- Provides the location of the RNG schema. -->
  <xsl:param name="rng_model_path"/>

  <!-- Provides the location of the Schematron schema. -->
  <xsl:param name="sch_model_path"/>

  <!-- Controls the feedback provided by the stylesheet. The default value of 'true()'
    produces a log message for every change. When set to 'false()' no messages are produced. -->
  <xsl:param name="verbose" select="true()"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->

  <!-- document URI -->
  <xsl:variable name="docURI">
    <xsl:value-of select="document-uri(/)"/>
  </xsl:variable>

  <!-- program name -->
  <xsl:variable name="progname">
    <xsl:text>mei30To40.xsl</xsl:text>
  </xsl:variable>

  <!-- program version -->
  <xsl:variable name="version">
    <xsl:text>1.0 beta</xsl:text>
  </xsl:variable>

  <!-- program id -->
  <xsl:variable name="progid">
    <xsl:value-of select="concat('app_', format-dateTime(current-dateTime(), '[Y][d][H][m][s][f]'))"
    />
  </xsl:variable>

  <!-- new line -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>

  <!-- computed class declarations -->
  <xsl:variable name="classDecls">
    <xsl:call-template name="makeClassDecls"/>
  </xsl:variable>

  <!-- ======================================================================= -->
  <!-- UTILITIES / NAMED TEMPLATES                                             -->
  <!-- ======================================================================= -->

  <!-- Create classDecl/taxonomy from classification elements throughout in the document -->
  <xsl:template name="makeClassDecls">
    <classDecls xmlns:mei="http://www.music-encoding.org/ns/mei"
      xsl:exclude-result-prefixes="mei xlink">
      <xsl:for-each-group select="//mei:classification//mei:term" group-by="@classcode">
        <xsl:sort select="current-grouping-key()"/>
        <taxonomy>
          <bibl>
            <xsl:variable name="classCodeValue">
              <xsl:value-of select="substring(current-grouping-key(), 2)"/>
            </xsl:variable>
            <xsl:attribute name="xml:id">
              <xsl:value-of select="$classCodeValue"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when
                test="../following-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authURI[matches(., 'http:')]">
                <xsl:attribute name="target">
                  <xsl:value-of
                    select="../following-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authURI"
                  />
                </xsl:attribute>
              </xsl:when>
              <xsl:when
                test="../preceding-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authURI[matches(., 'http:')]">
                <xsl:attribute name="target">
                  <xsl:value-of
                    select="../preceding-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authURI"
                  />
                </xsl:attribute>
              </xsl:when>
              <xsl:when
                test="../following-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authority[matches(., 'http:')]">
                <xsl:attribute name="target">
                  <xsl:value-of
                    select="../following-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authority"
                  />
                </xsl:attribute>
              </xsl:when>
              <xsl:when
                test="../preceding-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authority[matches(., 'http:')]">
                <xsl:attribute name="target">
                  <xsl:value-of
                    select="../preceding-sibling::mei:classCode[matches(@xml:id, substring($classCodeValue, 2))]/@authority"
                  />
                </xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:value-of select="substring(current-grouping-key(), 2)"/>
          </bibl>
          <xsl:variable name="categories">
            <xsl:for-each select="current-group()">
              <xsl:sort select="."/>
              <xsl:if test="replace(lower-case(.), '\s+', '') ne ''">
                <xsl:variable name="groupValue">
                  <xsl:value-of select="."/>
                </xsl:variable>
                <category>
                  <xsl:attribute name="xml:id">
                    <!-- Remove internal quote characters from potential sources for @xml:id -->
                    <xsl:choose>
                      <xsl:when test="mei:identifier">
                        <xsl:variable name="tempID">
                          <xsl:value-of
                            select="replace(replace(replace(replace(normalize-space(mei:identifier[1]), ':', '_'), '^([^\i])', '_$1'), '\s', '_'), '&quot;', '')"
                          />
                        </xsl:variable>
                        <xsl:value-of select='replace($tempID, "&apos;", "")'/>
                      </xsl:when>
                      <xsl:when test="@xml:id">
                        <xsl:variable name="tempID">
                          <xsl:value-of select="replace(@xml:id, '&quot;', '')"/>
                        </xsl:variable>
                        <xsl:value-of select='replace($tempID, "&apos;", "")'/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:variable name="tempID">
                          <xsl:value-of
                            select="replace(replace(replace(replace(normalize-space($groupValue), ':', '_'), '^([^\i])', '_$1'), '\s', '_'), '&quot;', '')"
                          />
                        </xsl:variable>
                        <xsl:value-of select='replace($tempID, "&apos;", "")'/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:for-each select="mei:identifier">
                    <altId>
                      <xsl:value-of select="."/>
                    </altId>
                  </xsl:for-each>
                  <xsl:variable name="labelValue">
                    <xsl:for-each select="*[not(local-name() eq 'identifier')] | text()">
                      <xsl:value-of select="."/>
                      <xsl:if test="position() != last()">
                        <xsl:text>&#32;</xsl:text>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <label xsl:exclude-result-prefixes="mei xlink">
                    <xsl:value-of select="normalize-space($labelValue)"/>
                  </label>
                </category>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:for-each select="$categories//mei:category">
            <xsl:sort select="mei:label"/>
            <xsl:variable name="thisID">
              <xsl:value-of select="@xml:id"/>
            </xsl:variable>
            <xsl:variable name="thisValue">
              <xsl:value-of select="mei:label"/>
            </xsl:variable>
            <xsl:if test="not(preceding-sibling::*[mei:label eq $thisValue])">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
        </taxonomy>
      </xsl:for-each-group>
    </classDecls>
  </xsl:template>

  <!-- Calculate a displayable ID value -->
  <xsl:template name="thisID">
    <xsl:choose>
      <!-- this node is an element with an ID -->
      <xsl:when test="@xml:id">
        <xsl:value-of select="concat('[#', @xml:id, ']')"/>
      </xsl:when>
      <xsl:when test="count(. | ../@*) = count(../@*)">
        <!-- this node is an attribute -->
        <xsl:choose>
          <!-- use parent's ID when it's available -->
          <xsl:when test="../@xml:id">
            <xsl:value-of select="concat('[#', ../@xml:id, ']')"/>
          </xsl:when>
          <!-- otherwise generate an ID for the parent -->
          <xsl:otherwise>
            <xsl:value-of select="concat('[#', generate-id(..), ']')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- Generate an ID for an element without one -->
        <xsl:value-of select="concat('[#', generate-id(), ']')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Calculate a measure number -->
  <!--<xsl:template name="thisMeasure">
    <xsl:choose>
      <xsl:when test="ancestor::mei:measure[@n]">
        <xsl:value-of select="ancestor::mei:measure/@n"/>
      </xsl:when>
      <xsl:when test="ancestor::mei:measure">
        <xsl:for-each select="ancestor::mei:measure">
          <xsl:value-of select="count(preceding::mei:measure) + 1"/>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>-->

  <!-- Display a warning message -->
  <xsl:template name="warning">
    <xsl:param name="warningText"/>
    <xsl:message>
      <xsl:value-of select="concat($docURI, ': ')"/>
      <xsl:value-of select="normalize-space($warningText)"/>
    </xsl:message>
  </xsl:template>


  <!-- ======================================================================= -->
  <!-- MAIN OUTPUT TEMPLATE                                                    -->
  <!-- ======================================================================= -->

  <xsl:template match="/">
    <xsl:if test="$rng_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat(' href=&quot;', $rng_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:if test="$sch_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat(' href=&quot;', $sch_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="mei:*[@meiversion = '4.0.0']">
        <xsl:variable name="warning">The source document is already a version 4.0.0 MEI
          file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($warning)"/>
        </xsl:message>
      </xsl:when>
      <xsl:when test="mei:*">
        <xsl:apply-templates select="mei:* | comment()" mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="warning">The source document is not an MEI file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($warning)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MATCH TEMPLATES FOR ELEMENTS                                            -->
  <!-- ======================================================================= -->

  <!-- Create a comment containing existing markup -->
  <xsl:template match="mei:*" mode="comment">
    <xsl:value-of select="$nl"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:for-each select="@*">
      <xsl:text>&#32;</xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>="</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates mode="comment"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <!-- Map accessRestrict to bibl/imprint/annot -->
  <xsl:template match="mei:accessRestrict" mode="bibl">
    <annot>
      <xsl:apply-templates mode="bibl"/>
    </annot>
  </xsl:template>

  <!-- Copy accessRestrict and useRestrict in manifestation -->
  <xsl:template match="mei:accessRestrict | mei:useRestrict" mode="manifestation">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="manifestation"/>
    </xsl:copy>
  </xsl:template>

  <!-- Revise appInfo -->
  <xsl:template match="mei:appInfo" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="mei:application" mode="copy"/>
      <application xmlns:mei="http://www.music-encoding.org/ns/mei"
        xsl:exclude-result-prefixes="mei
        xlink">
        <xsl:attribute name="version">
          <xsl:value-of select="concat('v', replace($version, '&#32;', '_'))"/>
        </xsl:attribute>
        <xsl:attribute name="xml:id">
          <xsl:value-of select="$progid"/>
        </xsl:attribute>
        <name>
          <xsl:value-of select="$progname"/>
        </name>
      </application>
    </xsl:copy>
  </xsl:template>

  <!-- Use contents of availability -->
  <xsl:template match="mei:availability" mode="bibl">
    <xsl:apply-templates mode="bibl"/>
  </xsl:template>

  <!-- If back already exists, copy separated lyrics there -->
  <xsl:template match="mei:back" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="copy"/>
      <xsl:if test="ancestor::mei:music/descendant::mei:lyrics">
        <div type="add_lyrics">
          <xsl:variable name="lyricsCopy">
            <xsl:apply-templates select="//mei:lyrics" mode="move"/>
          </xsl:variable>
          <!-- Group verses by @pseudo-n attribute assigned during copy process -->
          <xsl:for-each-group select="$lyricsCopy//mei:verse" group-by="@pseudo-n">
            <lg type="verse" n="{current-grouping-key()}">
              <xsl:for-each select="current-group()">
                <l>
                  <xsl:apply-templates select="mei:syl"/>
                </l>
              </xsl:for-each>
            </lg>
          </xsl:for-each-group>
        </div>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Map @dur and @dots > 0 on control events to multiple @dur values -->
  <xsl:template
    match="
      mei:*[local-name() eq 'beamSpan' or local-name() eq 'bend' or
      local-name() eq 'bracketSpan' or local-name() eq 'gliss' or
      local-name() eq 'hairpin' or local-name() eq 'mRest' or
      local-name() eq 'mSpace' or local-name() eq 'octave' or
      local-name() eq 'slur' or local-name() eq 'tuplet' or
      local-name() eq 'trill' or local-name() eq 'fing' or
      local-name() eq 'fingGrp' or local-name() eq 'f' or
      local-name() eq 'harm' or local-name() eq 'annot' or
      local-name() eq 'dir' or local-name() eq 'dynam' or
      local-name() eq 'ornam' or local-name() eq 'phrase' or
      local-name() eq 'line'][@dots > 0]"
    mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() eq 'dur') and not(local-name() eq 'dots')]"
        mode="copy"/>
      <xsl:variable name="dots">
        <xsl:value-of select="@dots"/>
      </xsl:variable>
      <xsl:variable name="numDur">
        <xsl:choose>
          <xsl:when test="@dur eq 'breve'">.5</xsl:when>
          <xsl:when test="@dur eq 'long'">.25</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@dur"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="dots2durations">
        <duration>
          <xsl:value-of select="$numDur * 2"/>
        </duration>
        <duration>
          <xsl:value-of select="$numDur * 4"/>
        </duration>
        <duration>
          <xsl:value-of select="$numDur * 8"/>
        </duration>
        <duration>
          <xsl:value-of select="$numDur * 16"/>
        </duration>
      </xsl:variable>
      <xsl:attribute name="dur">
        <xsl:value-of select="concat(@dur, ' ')"/>
        <xsl:value-of select="$dots2durations/mei:duration[position() = 1 to $dots]"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- Remove change elements that don't contain any data -->
  <xsl:template match="mei:change[mei:changeDesc[mei:p[not(mei:* or text())]]]" mode="copy">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="mei:change[mei:respStmt/mei:*[matches(local-name(), '(name|corpName|persName)') and @resp and normalize-space() eq '']]"
    mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:if test="not(@resp)">
        <xsl:attribute name="resp">
          <xsl:value-of
            select="mei:respStmt/mei:*[matches(local-name(), '(name|corpName|persName)') and @resp][1]/@resp"
          />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="mei:changeDesc | mei:date" mode="copy"/>
    </xsl:copy>
  </xsl:template>


  <!-- Reorder content of classification -->
  <xsl:template match="mei:classification" mode="#all">
    <xsl:choose>
      <xsl:when test="mei:termList">
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates select="mei:termList" mode="copy"/>
        </xsl:copy>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Content reordered')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Rename componentGrp to componentList -->
  <xsl:template match="mei:componentGrp" mode="copy">
    <componentList>
      <xsl:apply-templates mode="copy"/>
    </componentList>
  </xsl:template>

  <!-- Remove source/seriesStmt/contents -->
  <xsl:template match="mei:contents[parent::mei:seriesStmt[parent::mei:source]]" mode="bibl"/>

  <!-- Map source/editionStmt/edition to bibl/edition in bibl mode -->
  <xsl:template match="mei:editionStmt[parent::mei:source]" mode="bibl">
    <xsl:apply-templates select="mei:edition" mode="bibl"/>
  </xsl:template>

  <!-- Add encodingDesc/classDecls if classification appears anywhere in the file -->
  <xsl:template match="mei:encodingDesc" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:choose>
        <!-- Copy existing appInfo -->
        <xsl:when test="mei:appInfo">
          <xsl:apply-templates select="mei:appInfo" mode="copy"/>
        </xsl:when>
        <!-- Make new appInfo -->
        <xsl:otherwise>
          <appInfo>
            <application>
              <xsl:attribute name="version">
                <xsl:value-of select="concat('v', replace($version, '&#32;', '_'))"/>
              </xsl:attribute>
              <xsl:attribute name="xml:id">
                <xsl:value-of select="$progid"/>
              </xsl:attribute>
              <name>
                <xsl:value-of select="$progname"/>
              </name>
            </application>
          </appInfo>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates
        select="
          mei:editorialDecl | mei:projectDesc | mei:samplingDecl |
          mei:domainsDecl | mei:tagsDecl"
        mode="copy"/>
      <!--<xsl:apply-templates mode="copy"/>-->
      <xsl:if test="not(mei:classDecls) and //mei:classification and $classDecls//mei:taxonomy">
        <xsl:copy-of select="$classDecls"/>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Added classDecls element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Remove empty identifier elements -->
  <xsl:template
    match="mei:identifier[normalize-space(.) eq '' and not(descendant::mei:ptr[@target] or descendant::mei:ref)]"
    mode="#all">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Remove @midi.instrname when @midi.instrnum; update General MIDI instrument names -->
  <xsl:template match="mei:instrDef" mode="copy">
    <xsl:copy>
      <xsl:apply-templates
        select="@*[not(local-name() eq 'midi.instrname') and not(local-name() eq 'midi.instrnum')]"
        mode="copy"/>
      <xsl:choose>
        <xsl:when test="@midi.instrname and @midi.instrnum">
          <xsl:apply-templates select="@*[not(local-name() eq 'midi.instrname')]" mode="copy"/>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of
                  select="
                    concat(local-name(.), '&#32;', $thisID, '&#32;: Removed @midi.instrname')"
                />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="@midi.instrnum">
            <xsl:apply-templates select="@midi.instrnum" mode="copy"/>
          </xsl:if>
          <xsl:if test="@midi.instrname">
            <xsl:attribute name="midi.instrname">
              <xsl:value-of
                select="
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(replace(replace(replace(replace(replace(
                  replace(@midi.instrname,
                  'Acoustic_Grand_Piano', 'Acoustic Grand Piano'),
                  'Bright_Acoustic_Piano', 'Bright Acoustic Piano'),
                  'Electric_Grand_Piano', 'Electric Grand Piano'),
                  'Honky-tonk_Piano', 'Honky-tonk Piano'),
                  'Electric_Piano_1', 'Electric Piano 1'),
                  'Electric_Piano_2', 'Electric Piano 2'),
                  'Tubular_Bells', 'Tubular Bells'),
                  'Drawbar_Organ', 'Drawbar Organ'),
                  'Percussive_Organ', 'Percussive Organ'),
                  'Rock_Organ', 'Rock Organ'),
                  'Church_Organ', 'Church Organ'),
                  'Reed_Organ', 'Reed Organ'),
                  'Tango_Accordion', 'Tango Accordion'),
                  'Acoustic_Guitar_nylon', 'Acoustic Guitar (nylon)'),
                  'Acoustic_Guitar_steel', 'Acoustic Guitar (steel)'),
                  'Electric_Guitar_jazz', 'Electric Guitar (jazz)'),
                  'Electric_Guitar_clean', 'Electric Guitar (clean)'),
                  'Electric_Guitar_muted', 'Electric Guitar (muted)'),
                  'Overdriven_Guitar', 'Overdriven Guitar'),
                  'Distortion_Guitar', 'Distortion Guitar'),
                  'Guitar_harmonics', 'Guitar harmonics'),
                  'Acoustic_Bass$', 'Acoustic Bass'),
                  'Electric_Bass_finger', 'Electric Bass (finger)'),
                  'Electric_Bass_pick', 'Electric Bass (pick)'),
                  'Fretless_Bass', 'Fretless Bass'),
                  'Slap_Bass_1', 'Slap Bass 1'),
                  'Slap_Bass_2', 'Slap Bass 2'),
                  'Synth_Bass_1', 'Synth Bass 1'),
                  'Synth_Bass_2', 'Synth Bass 2'),
                  'Tremolo_Strings', 'Tremolo Strings'),
                  'Pizzicato_Strings', 'Pizzicato Strings'),
                  'Orchestral_Harp', 'Orchestral Harp'),
                  'String_Ensemble_1', 'String Ensemble 1'),
                  'String_Ensemble_2', 'String Ensemble 2'),
                  'SynthStrings_1', 'SynthStrings 1'),
                  'SynthStrings_2', 'SynthStrings 2'),
                  'Choir_Aahs', 'Choir Aahs'),
                  'Voice_Oohs', 'Voice Oohs'),
                  'Synth_Voice', 'Synth Voice'),
                  'Orchestra_Hit', 'Orchestra Hit'),
                  'Muted_Trumpet', 'Muted Trumpet'),
                  'French_Horn', 'French Horn'),
                  'Brass_Section', 'Brass Section'),
                  'SynthBrass_1', 'SynthBrass 1'),
                  'SynthBrass_2', 'SynthBrass 2'),
                  'Soprano_Sax', 'Soprano Sax'),
                  'Alto_Sax', 'Alto Sax'),
                  'Tenor_Sax', 'Tenor Sax'),
                  'Baritone_Sax', 'Baritone Sax'),
                  'English_Horn', 'English Horn'),
                  'Pan_Flute', 'Pan Flute'),
                  'Blown_Bottle', 'Blown Bottle'),
                  'Lead_1_square', 'Lead 1 (square)'),
                  'Lead_2_sawtooth', 'Lead 2 (sawtooth)'),
                  'Lead_3_calliope', 'Lead 3 (calliope)'),
                  'Lead_4_chiff', 'Lead 4 (chiff)'),
                  'Lead_5_charang', 'Lead 5 (charang)'),
                  'Lead_6_voice', 'Lead 6 (voice)'),
                  'Lead_7_fifths', 'Lead 7 (fifths)'),
                  'Lead_8_bass_and_lead', 'Lead 8 (bass + lead)'),
                  'Pad_1_new_age', 'Pad 1 (new age)'),
                  'Pad_2_warm', 'Pad 2 (warm)'),
                  'Pad_3_polysynth', 'Pad 3 (polysynth)'),
                  'Pad_4_choir', 'Pad 4 (choir)'),
                  'Pad_5_bowed', 'Pad 5 (bowed)'),
                  'Pad_6_metallic', 'Pad 6 (metallic)'),
                  'Pad_7_halo', 'Pad 7 (halo)'),
                  'Pad_8_sweep', 'Pad 8 (sweep)'),
                  'FX_1_rain', 'FX 1 (rain)'),
                  'FX_2_soundtrack', 'FX 2 (soundtrack)'),
                  'FX_3_crystal', 'FX 3 (crystal)'),
                  'FX_4_atmosphere', 'FX 4 (atmosphere)'),
                  'FX_5_brightness', 'FX 5 (brightness)'),
                  'FX_6_goblins', 'FX 6 (goblins)'),
                  'FX_7_echoes', 'FX 7 (echoes)'),
                  'FX_8_sci-fi', 'FX 8 (sci-fi)'),
                  'Tinkle_Bell', 'Tinkle Bell'),
                  'Steel_Drums', 'Steel Drums'),
                  'Taiko_Drum', 'Taiko Drum'),
                  'Pad_8_sweep', 'Pad 8 (sweep)'),
                  'FX_1_rain', 'FX 1 (rain)'),
                  'FX_2_soundtrack', 'FX 2 (soundtrack)'),
                  'FX_3_crystal', 'FX 3 (crystal)'),
                  'FX_4_atmosphere', 'FX 4 (atmosphere)'),
                  'FX_5_brightness', 'FX 5 (brightness)'),
                  'FX_6_goblins', 'FX 6 (goblins)'),
                  'FX_7_echoes', 'FX 7 (echoes)'),
                  'FX_8_sci-fi', 'FX 8 (sci-fi)'),
                  'Tinkle_Bell', 'Tinkle Bell'),
                  'Steel_Drums', 'Steel Drums'),
                  'Taiko_Drum', 'Taiko Drum'),
                  'Melodic_Tom', 'Melodic Tom'),
                  'Synth_Drum', 'Synth Drum'),
                  'Reverse_Cymbal', 'Reverse Cymbal'),
                  'Guitar_Fret_Noise', 'Guitar Fret Noise'),
                  'Breath_Noise', 'Breath Noise'),
                  'Bird_Tweet', 'Bird Tweet'),
                  'Telephone_Ring', 'Telephone Ring'),
                  'Acoustic_Bass_Drum', 'Acoustic Bass Drum'),
                  'Bass_Drum_1', 'Bass Drum 1'),
                  'Side_Stick', 'Side Stick'),
                  'Acoustic_Snare', 'Acoustic Snare'),
                  'Hand_Clap', 'Hand Clap'),
                  'Electric_Snare', 'Electric Snare'),
                  'Low_Floor_Tom', 'Low Floor Tom'),
                  'Closed_Hi_Hat', 'Closed Hi Hat'),
                  'High_Floor_Tom', 'High Floor Tom'),
                  'Pedal_Hi-Hat', 'Pedal Hi-Hat'),
                  'Low_Tom', 'Low Tom'),
                  'Open_Hi-Hat', 'Open Hi-Hat'),
                  'Low-Mid_Tom', 'Low-Mid Tom'),
                  'Hi-Mid_Tom', 'Hi-Mid Tom'),
                  'Crash_Cymbal_1', 'Crash Cymbal 1'),
                  'High_Tom', 'High Tom'),
                  'Ride_Cymbal_1', 'Ride Cymbal 1'),
                  'Chinese_Cymbal', 'Chinese Cymbal'),
                  'Ride_Bell', 'Ride Bell'),
                  'Splash_Cymbal', 'Splash Cymbal'),
                  'Crash_Cymbal_2', 'Crash Cymbal 2'),
                  'Ride_Cymbal_2', 'Ride Cymbal 2'),
                  'Hi_Bongo', 'Hi Bongo'),
                  'Low_Bongo', 'Low Bongo'),
                  'Mute_Hi_Conga', 'Mute Hi Conga'),
                  'Open_Hi_Conga', 'Open Hi Conga'),
                  'Low_Conga', 'Low Conga'),
                  'High_Timbale', 'High Timbale'),
                  'Low_Timbale', 'Low Timbale'),
                  'High_Agogo', 'High Agogo'),
                  'Low_Agogo', 'Low Agogo'),
                  'Short_Whistle', 'Short Whistle'),
                  'Long_Whistle', 'Long Whistle'),
                  'Short_Guiro', 'Short Guiro'),
                  'Long_Guiro', 'Long Guiro'),
                  'Hi_Wood_Block', 'Hi Wood Block'),
                  'Low_Wood_Block', 'Low Wood Block'),
                  'Mute_Cuica', 'Mute Cuica'),
                  'Open_Cuica', 'Open Cuica'),
                  'Mute_Triangle', 'Mute Triangle'),
                  'Open_Triangle', 'Open Triangle')
                  "
              />
            </xsl:attribute>
            <xsl:if test="$verbose">
              <xsl:variable name="thisID">
                <xsl:call-template name="thisID"/>
              </xsl:variable>
              <xsl:call-template name="warning">
                <xsl:with-param name="warningText">
                  <xsl:value-of
                    select="
                      concat(local-name(.), '&#32;', $thisID, '&#32;: Modified value of @midi.instrname')"
                  />
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <!-- Map source/langUsage/language to bibl/annot -->
  <xsl:template match="mei:langUsage[parent::mei:source]" mode="bibl">
    <xsl:for-each select="mei:language">
      <annot label="language">
        <xsl:apply-templates mode="bibl"/>
      </annot>
    </xsl:for-each>
  </xsl:template>

  <!-- Move or delete lyrics element -->
  <xsl:template match="mei:lyrics" mode="copy">
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:choose>
            <xsl:when test="ancestor::mei:body">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: ', local-name(), ' element moved to back')"
              />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: ', local-name(), ' element removed')"
              />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Copy lyrics element, apply templates to content in move mode -->
  <xsl:template match="mei:lyrics" mode="move">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="move"/>
    </xsl:copy>
  </xsl:template>

  <!-- Add encodingDesc/classDecls if classification appears anywhere in the file -->
  <xsl:template match="mei:meiHead" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() eq 'meiversion')]" mode="copy"/>
      <xsl:apply-templates select="mei:fileDesc" mode="copy"/>
      <xsl:choose>
        <xsl:when test="mei:encodingDesc">
          <xsl:apply-templates select="mei:encodingDesc" mode="copy"/>
        </xsl:when>
        <xsl:when test="//mei:classification">
          <encodingDesc xmlns:mei="http://www.music-encoding.org/ns/mei"
            xsl:exclude-result-prefixes="mei
            xlink">
            <xsl:copy-of select="$classDecls"/>
            <xsl:if test="$verbose">
              <xsl:variable name="thisID">
                <xsl:call-template name="thisID"/>
              </xsl:variable>
              <xsl:call-template name="warning">
                <xsl:with-param name="warningText">
                  <xsl:value-of
                    select="
                      concat(local-name(.), '&#32;', $thisID, '&#32;: Added encodingDesc/classDecls')"
                  />
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
          </encodingDesc>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="mei:extMeta | mei:workDesc" mode="copy"/>
      <xsl:if
        test="
          mei:fileDesc/mei:sourceDesc/mei:source[mei:biblList |
          mei:classification | mei:componentGrp | mei:contents | mei:extMeta |
          mei:history | mei:itemList | mei:relationList |
          mei:physDesc[mei:*[not(matches(local-name(),
          '(dimensions|extent|perfDuration|watermark)'))]]]">
        <!-- source has complex description -->
        <manifestationList>
          <xsl:apply-templates select="mei:fileDesc/mei:sourceDesc/mei:source" mode="manifestation"
          />
        </manifestationList>
      </xsl:if>
      <xsl:apply-templates select="mei:revisionDesc" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <!-- Revise music element -->
  <xsl:template match="mei:music" mode="copy">
    <xsl:copy>
      <!-- Remove music/@meiversion -->
      <xsl:apply-templates select="@*[not(local-name() eq 'meiversion')]" mode="copy"/>
      <xsl:apply-templates mode="copy"/>
      <!-- If additional lyrics exist, but there's no back -->
      <xsl:if test="descendant::mei:lyrics and not(mei:back)">
        <back>
          <div type="add_lyrics">
            <xsl:variable name="lyricsCopy">
              <xsl:apply-templates select="//mei:lyrics" mode="move"/>
            </xsl:variable>
            <!-- Group verses by @pseudo-n attribute assigned during copy process -->
            <xsl:for-each-group select="$lyricsCopy//mei:verse" group-by="@pseudo-n">
              <lg type="verse" n="{current-grouping-key()}">
                <xsl:for-each select="current-group()">
                  <l>
                    <xsl:apply-templates select="mei:syl"/>
                  </l>
                </xsl:for-each>
              </lg>
            </xsl:for-each-group>
          </div>
        </back>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Use role-specific element (arranger, composer, etc.) -->
  <xsl:template match="mei:name | mei:corpName | mei:persName" mode="respStmtReorg">
    <xsl:choose>
      <xsl:when
        test="matches(lower-case(@role), 'arranger|author|composer|contributor|distributor|editor|funder|librettist|lyricist|publisher|sponsor')">
        <xsl:element name="{lower-case(@role)}">
          <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="child::node()" mode="copy"/>
          </xsl:element>
          <!--<xsl:apply-templates select="." mode="copy"/>-->
        </xsl:element>
      </xsl:when>
      <xsl:when test="matches(lower-case(@role), 'creator')">
        <composer>
          <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates select="child::node()" mode="copy"/>
          </xsl:element>
          <!--<xsl:apply-templates select="." mode="copy"/>-->
        </composer>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:name | mei:corpName | mei:persName" mode="copy">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="text() | mei:*[not(matches(local-name(), 'address'))]"
        mode="copy"/>
    </xsl:element>
    <xsl:if test="mei:address">
      <xsl:apply-templates select="mei:address" mode="copy"/>
    </xsl:if>
  </xsl:template>

  <!-- Keep source/notesStmt/annot elements in bibl mode -->
  <xsl:template match="mei:notesStmt[parent::mei:source]" mode="bibl">
    <xsl:apply-templates select="mei:annot" mode="bibl"/>
  </xsl:template>

  <!-- Remove empty p elements -->
  <xsl:template match="mei:p[normalize-space(.) eq '' and not(descendant::mei:ptr[@target])]"
    mode="copy">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Remove empty perfMedium elements -->
  <xsl:template
    match="mei:perfMedium[normalize-space(.) eq '' and not(descendant::mei:ptr[@target])]"
    mode="copy">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Remove physDesc in bibl mode -->
  <xsl:template match="mei:physDesc" mode="bibl"/>

  <!-- Remove empty physDesc elements -->
  <xsl:template match="mei:physDesc[normalize-space(.) eq '' and not(descendant::mei:ptr[@target])]"
    mode="copy">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Move physLoc/provenance inside physLoc/history -->
  <xsl:template match="mei:physLoc" mode="#all">
    <physLoc>
      <xsl:apply-templates select="mei:head" mode="copy"/>
      <xsl:apply-templates select="mei:repository" mode="copy"/>
      <xsl:apply-templates select="mei:identifier" mode="copy"/>
      <xsl:if test="mei:provenance">
        <history>
          <xsl:apply-templates select="mei:provenance" mode="copy"/>
        </history>
      </xsl:if>
    </physLoc>
  </xsl:template>

  <!-- Remove empty pubPlace elements -->
  <xsl:template match="mei:pubPlace[normalize-space(.) eq '' and not(descendant::mei:ptr[@target])]"
    mode="copy">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:pubStmt[parent::mei:fileDesc]" mode="copy">
    <pubStmt>
      <xsl:apply-templates select="mei:publisher | mei:distributor" mode="copy"/>
      <xsl:for-each select="mei:respStmt">
        <xsl:apply-templates
          select="mei:*[matches(local-name(), 'name|corpName|persName')][matches(lower-case(@role), '(publisher|distributor)')]"
          mode="respStmtReorg"/>
        <xsl:if
          test="
            mei:*[matches(local-name(), '(name|persName|corpName)')]
            [not(matches(lower-case(@role), 'publisher|distributor'))]">
          <respStmt>
            <xsl:apply-templates
              select="
                mei:*[matches(local-name(), '(name|persName|corpName)')]
                [not(matches(lower-case(@role), 'publisher|distributor'))]"
              mode="copy"/>
          </respStmt>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates
        select="mei:*[not(matches(local-name(), '(publisher|distributor|respStmt)'))]" mode="copy"/>
    </pubStmt>
  </xsl:template>

  <!-- Process children of titleStmt using bibl mode -->
  <xsl:template match="mei:titleStmt[parent::mei:source]" mode="bibl">
    <xsl:apply-templates mode="bibl"/>
  </xsl:template>

  <!-- Map pubStmt to imprint in bibl mode -->
  <xsl:template match="mei:pubStmt[parent::mei:source]" mode="bibl">
    <imprint>
      <xsl:apply-templates mode="bibl"/>
    </imprint>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(.), '&#32;', $thisID, '&#32;: Mapped to imprint element')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Process children of pubStmt and titleStmt using copy mode -->
  <xsl:template match="mei:pubStmt[parent::mei:source] | mei:titleStmt[parent::mei:source]"
    mode="copy">
    <xsl:apply-templates mode="copy"/>
  </xsl:template>

  <!-- Copy pubStmt in manifestation mode -->
  <xsl:template match="mei:pubStmt[parent::mei:source]" mode="manifestation">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="manifestation"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:respStmt" mode="bibl">
    <xsl:apply-templates
      select="mei:*[matches(local-name(), 'name|corpName|persName')][matches(lower-case(@role), '(arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor)')]"
      mode="respStmtReorg"/>
    <xsl:if
      test="
        mei:*[matches(local-name(), '(name|persName|corpName)')]
        [not(matches(lower-case(@role), '(arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor)'))]">
      <respStmt>
        <xsl:apply-templates
          select="
            mei:*[matches(local-name(), '(name|persName|corpName)')]
            [not(matches(lower-case(@role), '(arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor)'))]"
          mode="copy"/>
      </respStmt>
    </xsl:if>
  </xsl:template>

  <!-- Remove empty respStmt elements -->
  <xsl:template match="mei:respStmt[not(node())]" mode="copy" priority="2">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Where respStmt contains only a resp element, the resp actually holds a name -->
  <xsl:template match="mei:respStmt[mei:resp and count(mei:*) = 1]" mode="copy">
    <respStmt>
      <name>
        <xsl:value-of select="mei:resp"/>
      </name>
    </respStmt>
  </xsl:template>

  <!-- Update revision history -->
  <xsl:template match="mei:revisionDesc" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="copy"/>
      <xsl:choose>
        <!-- Already a v. 4.0.0 file -->
        <xsl:when test="ancestor::mei:mei[@meiversion = '4.0.0']">
          <xsl:variable name="warning">The source document is already a v. 4.0.0 MEI
            file</xsl:variable>
          <xsl:message>
            <xsl:value-of select="normalize-space($warning)"/>
          </xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <!-- Add a record of the conversion to revisionDesc -->
          <change xmlns:mei="http://www.music-encoding.org/ns/mei"
            xsl:exclude-result-prefixes="mei
            xlink">
            <xsl:if test="count(mei:change[@n]) = count(mei:change)">
              <xsl:attribute name="n">
                <xsl:value-of select="count(mei:change) + 1"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="resp">
              <xsl:value-of select="concat('#', $progid)"/>
            </xsl:attribute>
            <changeDesc>
              <p>Converted to MEI version 4.0.0 using <xsl:value-of select="$progname"/>, version
                <xsl:value-of select="$version"/></p>
            </changeDesc>
            <date>
              <xsl:attribute name="isodate">
                <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
              </xsl:attribute>
            </date>
          </change>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of
                  select="
                    concat(local-name(), '&#32;', $thisID, '&#32;: Added change element')"
                />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- Modify scoreDef labels; move @key.sig.mixed values to keySig/keyAccid -->
  <xsl:template match="mei:scoreDef" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() eq 'key.sig.mixed')]" mode="copy"/>
      <xsl:if test="@key.sig.mixed">
        <keySig xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:analyze-string select="@key.sig.mixed" regex="\s+">
            <xsl:non-matching-substring>
              <xsl:analyze-string select="." regex="([a-g])([\d])(.*)">
                <xsl:matching-substring>
                  <keyAccid>
                    <xsl:attribute name="pname">
                      <xsl:value-of select="regex-group(1)"/>
                    </xsl:attribute>
                    <xsl:attribute name="oct">
                      <xsl:value-of select="regex-group(2)"/>
                    </xsl:attribute>
                    <xsl:attribute name="accid">
                      <xsl:value-of select="regex-group(3)"/>
                    </xsl:attribute>
                  </keyAccid>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </keySig>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Moved @key.sig.mixed to keySig element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <!-- Map seriesStmt to series in bibl mode -->
  <xsl:template match="mei:seriesStmt" mode="bibl">
    <series>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="bibl"/>
    </series>
  </xsl:template>

  <xsl:template match="mei:seriesStmt" mode="manifestation copy">
    <seriesStmt>
      <xsl:apply-templates select="mei:title" mode="copy"/>
      <xsl:apply-templates select="mei:editor" mode="copy"/>
      <xsl:for-each select="mei:respStmt">
        <xsl:apply-templates
          select="mei:*[matches(local-name(), 'name|corpName|persName')][matches(lower-case(@role), '(arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor)')]"
          mode="respStmtReorg"/>
        <xsl:if
          test="
            mei:*[matches(local-name(), '(name|persName|corpName)')]
            [not(matches(lower-case(@role), '(arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor)'))]">
          <respStmt>
            <xsl:apply-templates
              select="
                mei:*[matches(local-name(), '(name|persName|corpName)')]
                [not(matches(lower-case(@role), '(arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor)'))]"
              mode="copy"/>
          </respStmt>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates
        select="mei:*[not(matches(local-name(), '(arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor|respStmt|title|editor)'))]"
        mode="copy"/>
    </seriesStmt>
  </xsl:template>

  <!-- Map source to bibl if it contains a "simple" description -->
  <xsl:template match="mei:source" mode="bibl">
    <!-- source has simple description -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <bibl>
        <xsl:apply-templates mode="bibl"/>
      </bibl>
    </xsl:copy>
  </xsl:template>

  <!-- Map source to manifestation if it contains a "complex" description -->
  <xsl:template match="mei:source" mode="manifestation">
    <!-- source has complex description -->
    <manifestation>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="manifestation"/>
    </manifestation>
  </xsl:template>

  <!-- Copy sourceDesc if all source children contain a "simple" description -->
  <xsl:template match="mei:sourceDesc" mode="copy">
    <!-- source has simple description -->
    <xsl:if
      test="
        not(mei:source[mei:biblList | mei:classification |
        mei:componentGrp | mei:contents | mei:extMeta |
        mei:history | mei:itemList | mei:relationList]) and
        not(mei:source/mei:physDesc[mei:*[not(matches(local-name(),
        '(dimensions|extent|perfDuration|watermark)'))]])">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="copy"/>
        <xsl:apply-templates select="mei:source" mode="bibl"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Modify staffDef labels; move @key.sig.mixed values to keySig/keyAccid -->
  <xsl:template match="mei:staffDef" mode="copy">
    <xsl:copy>
      <xsl:apply-templates
        select="@*[not(local-name() eq 'key.sig.mixed') and not(local-name() eq 'label') and not(local-name() eq 'label.abbr')]"
        mode="copy"/>
      <xsl:if test="@key.sig.mixed">
        <keySig xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:analyze-string select="@key.sig.mixed" regex="\s+">
            <xsl:non-matching-substring>
              <xsl:analyze-string select="." regex="([a-g])([\d])(.*)">
                <xsl:matching-substring>
                  <keyAccid>
                    <xsl:attribute name="pname">
                      <xsl:value-of select="regex-group(1)"/>
                    </xsl:attribute>
                    <xsl:attribute name="oct">
                      <xsl:value-of select="regex-group(2)"/>
                    </xsl:attribute>
                    <xsl:attribute name="accid">
                      <xsl:value-of select="regex-group(3)"/>
                    </xsl:attribute>
                  </keyAccid>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </keySig>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Moved @key.sig.mixed to keySig element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@label and not(mei:label)">
        <label xsl:exclude-result-prefixes="mei xlink">
          <xsl:value-of select="@label"/>
        </label>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Replaced @label with label element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@label.abbr and not(mei:labelAbbr)">
        <labelAbbr xsl:exclude-result-prefixes="mei xlink">
          <xsl:value-of select="@label.abbr"/>
        </labelAbbr>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Replaced @label.abbr with labelAbbr element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
      <!--<xsl:apply-templates select="mei:*[not(local-name() eq 'label')]" mode="copy"/>-->
    </xsl:copy>
  </xsl:template>

  <!-- Modify staffGrp labels -->
  <xsl:template match="mei:staffGrp" mode="copy">
    <xsl:copy>
      <xsl:apply-templates
        select="@*[not(local-name() eq 'label') and not(local-name() eq 'label.abbr')]" mode="copy"/>
      <xsl:choose>
        <xsl:when test="@label and not(mei:label)">
          <label xsl:exclude-result-prefixes="mei xlink">
            <xsl:value-of select="@label"/>
          </label>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of
                  select="
                    concat(local-name(.), '&#32;', $thisID, '&#32;: Replaced @label with label element')"
                />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:apply-templates select="mei:*[not(local-name() eq 'label')]" mode="copy"/>
        </xsl:when>
        <xsl:when test="@label.abbr and not(mei:labelAbbr)">
          <labelAbbr xsl:exclude-result-prefixes="mei xlink">
            <xsl:value-of select="@label.abbr"/>
          </labelAbbr>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of
                  select="
                    concat(local-name(.), '&#32;', $thisID, '&#32;: Replaced @label.abbr with labelAbbr element')"
                />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:apply-templates select="mei:*[not(local-name() eq 'label')]" mode="copy"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="mei:*" mode="copy"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- Substitute @class for @classcode -->
  <xsl:template match="mei:term[parent::mei:termList]" mode="copy">
    <xsl:if test="not(normalize-space(.) eq '')">
      <xsl:copy>
        <xsl:copy-of select="@*[not(local-name() eq 'classcode') and not(name() eq 'xml:id')]"/>
        <xsl:variable name="tempValue">
          <xsl:choose>
            <xsl:when test="mei:identifier">
              <xsl:value-of
                select="replace(replace(replace(normalize-space(mei:identifier[1]), ':', '_'), '^([^\i])', '_$1'), '\s', '_')"
              />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempValue2">
          <xsl:value-of select="replace($tempValue, '&quot;', '')"/>
        </xsl:variable>
        <xsl:variable name="tempValue3">
          <xsl:value-of select='replace($tempValue, "&apos;", "")'/>
        </xsl:variable>
        <xsl:if test="@classcode">
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="mei:identifier">
                <xsl:value-of
                  select="concat('#', $classDecls//mei:category[@xml:id eq $tempValue3]/@xml:id)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="concat('#', $classDecls//mei:category[mei:label[. eq $tempValue]][1]/@xml:id)"
                />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="mei:identifier">
            <xsl:value-of select="mei:*[not(local-name() eq 'identifier')]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space($tempValue)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Remove @classcode -->
  <xsl:template match="mei:termList" mode="copy">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name() eq 'classcode')]"/>
      <xsl:apply-templates select="mei:term" mode="copy">
        <xsl:sort/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- Use titlePart for title/title -->
  <xsl:template match="mei:title[ancestor::mei:title]" mode="bibl" priority="5">
    <xsl:text>&#32;</xsl:text>
    <titlePart xmlns:mei="http://www.music-encoding.org/ns/mei"
      xsl:exclude-result-prefixes="mei xlink">
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="bibl"/>
    </titlePart>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(.), '&#32;', $thisID, '&#32;: Replaced by titlePart element')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Use titlePart for title/title -->
  <xsl:template match="mei:title[ancestor::mei:title and not(ancestor::mei:titleStmt)]" mode="copy">
    <xsl:choose>
      <xsl:when test="count(ancestor::mei:title) mod 2 != 0">
        <xsl:text>&#32;</xsl:text>
        <titlePart xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates mode="copy"/>
        </titlePart>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Replaced by titlePart element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <title xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates mode="copy"/>
        </title>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Use titlePart for title/title -->
  <xsl:template match="mei:title[ancestor::mei:title]" mode="titleReorg">
    <xsl:choose>
      <xsl:when test="count(ancestor::mei:title) mod 2 != 0">
        <xsl:text>&#32;</xsl:text>
        <titlePart xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates mode="titleReorg"/>
        </titlePart>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Replaced by titlePart element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <title xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates mode="titleReorg"/>
        </title>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Remove empty titlePage elements -->
  <xsl:template
    match="mei:titlePage[normalize-space(.) eq '' and not(descendant::mei:ptr[@target])]"
    mode="copy">
    <xsl:if test="$removeEmptyElements">
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(.), '&#32;', $thisID, '&#32;: Empty; not copied')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:titleStmt[ancestor::mei:fileDesc]" mode="copy">
    <titleStmt>
      <xsl:for-each-group select="mei:title"
        group-starting-with="
          mei:title[every $i in tokenize(@type, '\s+')
            satisfies
            not(matches($i, 'subordinate') or matches($i, 'sub'))]">
        <xsl:variable name="titleStmt">
          <titleStmt xmlns:mei="http://www.music-encoding.org/ns/mei"
            xsl:exclude-result-prefixes="mei xlink">
            <xsl:copy-of select="current-group()"/>
          </titleStmt>
        </xsl:variable>
        <xsl:for-each select="$titleStmt/mei:titleStmt/mei:title[1]">
          <xsl:variable name="titleJoin">
            <xsl:copy>
              <xsl:apply-templates select="@*" mode="copy"/>
              <xsl:apply-templates mode="copy"/>
              <xsl:apply-templates select="following-sibling::mei:title" mode="copy"/>
            </xsl:copy>
          </xsl:variable>
          <xsl:apply-templates select="$titleJoin" mode="titleReorg"/>
        </xsl:for-each>
      </xsl:for-each-group>
      <xsl:apply-templates
        select="
          mei:arranger | mei:author | mei:composer | mei:creator | mei:editor |
          mei:funder | mei:librettist | mei:lyricist | mei:sponsor"
        mode="copy"/>
      <xsl:for-each select="mei:respStmt">
        <xsl:apply-templates select="mei:name | mei:corpname | mei:persName" mode="respStmtReorg"/>
        <xsl:if
          test="
            mei:*[matches(local-name(), '(name|persName|corpName)')]
            [not(matches(lower-case(@role), 'arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor'))]">
          <respStmt>
            <xsl:apply-templates
              select="
                mei:*[matches(local-name(), '(name|persName|corpName)')]
                [not(matches(lower-case(@role), 'arranger|author|composer|contributor|creator|editor|funder|librettist|lyricist|sponsor'))]"
              mode="copy"/>
          </respStmt>
        </xsl:if>
      </xsl:for-each>
    </titleStmt>
  </xsl:template>

  <!-- Remove titleStmt in work and expression; use its contents directly -->
  <xsl:template match="mei:titleStmt[ancestor::mei:work or ancestor::mei:expression]" mode="copy">
    <xsl:for-each-group select="mei:title"
      group-starting-with="
        mei:title[every $i in tokenize(@type, '\s+')
          satisfies
          not(matches($i, 'subordinate') or matches($i, 'sub'))]">
      <xsl:variable name="titleStmt">
        <titleStmt xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:copy-of select="current-group()"/>
        </titleStmt>
      </xsl:variable>
      <xsl:for-each select="$titleStmt/mei:titleStmt/mei:title[1]">
        <xsl:variable name="titleJoin">
          <xsl:copy>
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates mode="copy"/>
            <xsl:apply-templates select="following-sibling::mei:title" mode="copy"/>
          </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$titleJoin" mode="titleReorg"/>
      </xsl:for-each>
    </xsl:for-each-group>
    <xsl:apply-templates
      select="
        mei:arranger | mei:author | mei:composer | mei:creator | mei:editor |
        mei:funder | mei:librettist | mei:lyricist | mei:sponsor"
      mode="copy"/>
    <xsl:for-each select="mei:respStmt">
      <xsl:apply-templates select="mei:name | mei:corpname | mei:persName" mode="respStmtReorg"/>
    </xsl:for-each>
  </xsl:template>

  <!-- Map accessRestrict to bibl/imprint/date or bibl/imprint/annot -->
  <xsl:template match="mei:useRestrict" mode="bibl">
    <xsl:choose>
      <xsl:when test="matches(., '(&#x00A9;|\(c\)|copyright\s+\d+)')">
        <date type="copyright">
          <xsl:apply-templates mode="bibl"/>
        </date>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Mapped to date element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <annot>
          <xsl:apply-templates mode="bibl"/>
        </annot>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(.), '&#32;', $thisID, '&#32;: Mapped to annot element')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Copy verse element, assign a pseudo @n for later processing -->
  <xsl:template match="mei:verse" mode="move">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:attribute name="pseudo-n">
        <xsl:value-of select="position()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Create empty title element when work doesn't contain a title -->
  <xsl:template match="mei:work[not(mei:titleStmt/mei:title)]" mode="copy">
    <work>
      <title/>
      <xsl:apply-templates mode="copy"/>
    </work>
  </xsl:template>

  <!-- Rename workDesc to workList -->
  <xsl:template match="mei:workDesc" mode="copy">
    <workList>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="copy"/>
    </workList>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MATCH TEMPLATES FOR ATTRIBUTES                                          -->
  <!-- ======================================================================= -->

  <!-- Replace deprecated "marc-stacc" and "ten-stacc" values with "marc" and "stacc" 
    and "ten" and "stac" values, respectively -->
  <xsl:template match="@artic | @artic.ges" mode="#all">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of
        select="distinct-values(tokenize(replace(replace(normalize-space(.), 'ten-stacc', 'ten stacc'), 'marc-stacc', 'marc stacc'), ' '))"
      />
    </xsl:attribute>
    <xsl:if test="$verbose and matches(., 'ten-stacc|marc-stacc')">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename @authority to @auth -->
  <xsl:template match="@authority" mode="#all" priority="5">
    <xsl:attribute name="auth">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @auth')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename @authURI to @auth.uri -->
  <xsl:template match="@authURI" mode="#all">
    <xsl:attribute name="auth.uri">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @auth.uri')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename @barplace to @bar.method -->
  <xsl:template match="@barplace" mode="#all">
    <xsl:choose>
      <xsl:when test="not(. eq 'mensur')">
        <xsl:attribute name="bar.method">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(parent::*[matches(local-name(), '(staffDef|measure)')])">
          <xsl:attribute name="bar.method">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Rename @barthru to @bar.thru -->
  <xsl:template match="@barthru" mode="#all">
    <xsl:attribute name="bar.thru">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- Remove @def -->
  <xsl:template match="@def" mode="#all">
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Removed @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename @dur.ges -->
  <xsl:template match="@dur.ges" mode="#all">
    <xsl:choose>
      <xsl:when
        test="
          matches(.,
          '(long|longa|breve|brevis|semibrevis|minima|semiminima|fusa|semifusa)')">
        <xsl:attribute name="dur.ges">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="durType">
          <xsl:choose>
            <xsl:when test="matches(., 'b$')">dur.metrical</xsl:when>
            <xsl:when test="matches(., 'r$')">dur.recip</xsl:when>
            <xsl:when test="matches(., 's$')">dur.real</xsl:when>
            <xsl:otherwise>dur.ppq</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="{$durType}">
          <xsl:value-of select="replace(., '[bprs]$', '')"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @', $durType)"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Add 'pt' to @fontsize without specified units; rename @size to @fontsize -->
  <xsl:template
    match="
      @fontsize[normalize-space(.) eq string(number(normalize-space(.)))] |
      @size[normalize-space(.) eq string(number(normalize-space(.)))]"
    mode="#all">
    <xsl:attribute name="fontsize">
      <xsl:value-of select="concat(normalize-space(.), 'pt')"/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Replace 'cue' with 'small' in @fontsize; rename @size to @fontsize -->
  <xsl:template
    match="@fontsize[matches(normalize-space(.), 'cue')] | @size[matches(normalize-space(.), 'cue')]"
    mode="#all">
    <xsl:attribute name="fontsize">
      <xsl:choose>
        <xsl:when test="matches(normalize-space(.), 'cue')">
          <xsl:text>small</xsl:text>
        </xsl:when>
        <xsl:when test="matches(normalize-space(.), 'medium')">
          <xsl:text>normal</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Map beatRpt/@form values to new ones -->
  <xsl:template match="@form[parent::mei:beatRpt]" mode="#all">
    <xsl:attribute name="slash">
      <xsl:choose>
        <xsl:when test="matches(., '4')">1</xsl:when>
        <xsl:when test="matches(., '8')">2</xsl:when>
        <xsl:when test="matches(., '16')">3</xsl:when>
        <xsl:when test="matches(., '32')">4</xsl:when>
        <xsl:when test="matches(., '64')">5</xsl:when>
        <!-- The value "128" IS NOT mapped! -->
        <xsl:when test="matches(., 'mixed')">mixed</xsl:when>
      </xsl:choose>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <!-- Update values in mordent/@form and turn/@form -->
  <xsl:template match="@form[parent::mei:mordent or parent::mei:turn]" mode="#all">
    <xsl:attribute name="form">
      <xsl:choose>
        <xsl:when test=". eq 'inv'">
          <xsl:text>lower</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>upper</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @',
              local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename @glyphname to @glyph.name -->
  <xsl:template match="@glyphname" mode="#all">
    <xsl:attribute name="glyph.name">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @glyph.name')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename @glyphnum to @glyph.num -->
  <xsl:template match="@glyphnum" mode="#all">
    <xsl:attribute name="glyph.num">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @glyph.num')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Fix up for half-step values in @intm -->
  <xsl:template match="@intm" mode="#all">
    <xsl:attribute name="intm">
      <xsl:choose>
        <xsl:when test="matches(., '^[0-9\.\+\-]+$')">
          <xsl:value-of select="concat(normalize-space(.), 'hs')"/>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of
                  select="
                    concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
                />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- Rename @key.sig.show to @keysig.show -->
  <xsl:template match="@key.sig.show" mode="#all">
    <xsl:attribute name="keysig.show">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @keysig.show')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Add 'pt' to numeric values without specified units; replace 'cue' with 'small';
    replace 'medium' with 'normal'. -->
  <xsl:template match="@lyric.size | @mensur.size | @music.size | @text.size" mode="#all">
    <xsl:attribute name="{local-name()}">
      <xsl:choose>
        <xsl:when test="normalize-space(.) eq string(number(normalize-space(.)))">
          <xsl:value-of select="concat(normalize-space(.), 'pt')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="matches(., 'cue')">
              <xsl:text>small</xsl:text>
            </xsl:when>
            <xsl:when test="matches(., 'medium')">
              <xsl:text>normal</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename lendsymsize and lstartsymsize attributes -->
  <xsl:template match="@lendsymsize | @lstartsymsize" mode="#all">
    <xsl:variable name="newName">
      <xsl:value-of select="replace(local-name(), 'symsize', 'sym.size')"/>
    </xsl:variable>
    <xsl:attribute name="{$newName}">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @', $newName)"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename @measperf to @unitdur -->
  <xsl:template match="@measperf" mode="#all">
    <xsl:attribute name="unitdur">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @unitdur')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Update @meiversion -->
  <xsl:template match="@meiversion" mode="#all">
    <xsl:attribute name="meiversion">
      <xsl:text>4.0.1</xsl:text>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Replace meter.rend with meter.form or meter.showchange -->
  <xsl:template match="@meter.rend[matches(normalize-space(.), 'invis')]" mode="#all">
    <xsl:choose>
      <xsl:when test="parent::mei:scoreDef[not(preceding::mei:scoreDef)]">
        <xsl:attribute name="meter.form">
          <xsl:text>invis</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="parent::mei:staffDef[not(preceding::mei:staffDef)]">
        <xsl:attribute name="meter.form">
          <xsl:text>invis</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="meter.showchange">
          <xsl:text>false</xsl:text>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Replace spaces in @n with underscores -->
  <xsl:template match="@n" mode="#all">
    <xsl:attribute name="n">
      <xsl:choose>
        <xsl:when test="matches(., ' ')">
          <xsl:value-of select="replace(normalize-space(.), '\s', '_')"/>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of
                  select="
                    concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
                />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>

        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- Add @unit to @height and @width -->
  <xsl:template match="mei:graphic[@unit]" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() eq 'unit')]" mode="copy"/>
      <xsl:attribute name="height">
        <xsl:value-of select="concat(@height, @unit)" />
      </xsl:attribute>
      <xsl:attribute name="width">
        <xsl:value-of select="concat(@width, @unit)" />
      </xsl:attribute>
    </xsl:copy>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID" />
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Added @unit to @height and @width')" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Rename pad/@num to @width -->
  <xsl:template match="mei:pad/@num" mode="copy">
    <xsl:attribute name="width">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @width')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Correct common error in @xlink:show -->
  <xsl:template match="@xlink:show" mode="#all">
    <xsl:attribute name="xlink:show">
      <xsl:choose>
        <xsl:when test="matches(., '_?self')">
          <xsl:text>replace</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Modified value of @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Map fTrem/@slash to @beams -->
  <xsl:template match="@slash[parent::mei:fTrem]" mode="#all">
    <xsl:attribute name="beams">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Renamed @', local-name(), ' to @beams')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Remove @subtype -->
  <xsl:template match="@subtype" mode="#all"/>

  <!-- Remove @tstamp.ges -->
  <xsl:template match="@tstamp.ges" mode="#all">
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(..), '&#32;', $thisID, '&#32;: Removed @', local-name())"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Add values in @subtype to @type -->
  <xsl:template match="@type" mode="#all">
    <xsl:attribute name="type">
      <xsl:value-of select="."/>
      <xsl:if test="../@subtype">
        <xsl:value-of select="concat(' ', ../@subtype)"/>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(..), '&#32;', $thisID, '&#32;: Copied values in @', local-name(), ' to @type')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </xsl:attribute>
  </xsl:template>

  <!-- Identity template -->
  <xsl:template match="@* | node()" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
