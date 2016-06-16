<?xml version="1.0"?>
<xsl:stylesheet xml:space="default" version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="../../common/copy-all.xsl"/>
  <xsl:template match="proto[@name != 'dns']"/>
</xsl:stylesheet>
