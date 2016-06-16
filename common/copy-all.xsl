<?xml version="1.0"?>
<xsl:stylesheet  xml:space="default" version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output indent="yes"/>
  <!-- drop <pdml> attributes -->
  <xsl:template match="/*">
    <pdml>
      <xsl:apply-templates/>
    </pdml>
  </xsl:template>
  <!-- copy by default -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  <!-- skip text -->
  <xsl:template match="text()"/>
</xsl:stylesheet>
