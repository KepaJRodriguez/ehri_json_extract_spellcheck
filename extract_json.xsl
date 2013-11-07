<?xml version='2.0' encoding="UTF-8"?>
<!--
//*****************************************************************************
// Copyright 2013 by Junte Zhang <junte.zhang@meertens.knaw.nl>
// Distributed under the GNU General Public Licence
//*****************************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
	<xsl:output method="text" omit-xml-declaration="no" />
	<xsl:output encoding="utf-8"/>
	<xsl:output indent="no" />
	<!--<xsl:strip-space elements="*" />-->
	
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
  
  <!-- extract fields by CHI and collection in a for-each loop -->	
  <xsl:template match="/opt/anon">
    <xsl:variable name="lang">
      <xsl:choose>
        <xsl:when test="relationships/describes/data/@languageCode = ''">
          <xsl:text>unknown</xsl:text>
        </xsl:when>
        <xsl:when test="not(relationships/describes/data/@languageCode)">
          <xsl:text>unknown</xsl:text>
        </xsl:when>    
        <xsl:otherwise>
          <xsl:value-of select="relationships/describes/data/@languageCode"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="chi" select="replace(relationships/heldBy/relationships/describes/data/@name, '/', '')"/>
    <xsl:variable name="id" select="@id"/>
        
    <!-- archivalHistory-->
    <xsl:result-document method="text" href="../data/documentaryUnit_split/{$lang}.{$chi}.{$id}.archivalHistory.txt">
        <!-- do not print empty lines -->
        <xsl:if test="relationships/describes/data/@archivalHistory != ''">
          <xsl:value-of select="relationships/describes/data/@archivalHistory"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:result-document>
    
    <!-- biographicalHistory -->
    <xsl:result-document method="text" href="../data/documentaryUnit_split/{$lang}.{$chi}.{$id}.biographicalHistory.txt">
        <!-- do not print empty lines -->
        <xsl:if test="relationships/describes/data/@biographicalHistory != ''">
          <xsl:value-of select="relationships/describes/data/@biographicalHistory"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:result-document>        
    
    <!-- scopeAndContent -->
    <xsl:result-document method="text" href="../data/documentaryUnit_split/{$lang}.{$chi}.{$id}.scopeAndContent.txt">
        <!-- do not print empty lines -->
        <xsl:if test="relationships/describes/data/@scopeAndContent != ''">
          <xsl:value-of select="relationships/describes/data/@scopeAndContent"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:result-document>           

    <!-- archivistNote -->
    <xsl:result-document method="text" href="../data/documentaryUnit_split/{$lang}.{$chi}.{$id}.archivistNote.txt">
        <!-- do not print empty lines -->
        <xsl:if test="relationships/describes/data/@archivistNote != ''">
          <xsl:value-of select="relationships/describes/data/@archivistNote"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:result-document>    
            
    <!-- describes_data_name -->
    <xsl:result-document method="text" href="../data/documentaryUnit_split/{$lang}.{$chi}.{$id}.describes_data_name.txt">
        <!-- do not print empty lines -->
        <xsl:if test="relationships/describes/data/@name != ''">
          <xsl:value-of select="relationships/describes/data/@name"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:result-document>   
  
    <!-- ead_archdesc_did_abstract_ --> 
    <xsl:result-document method="text" href="../data/documentaryUnit_split/{$lang}.{$chi}.{$id}.abstract_.txt">
        <!-- do not print empty lines -->
        <xsl:if test="relationships/describes/descendant::data/@ead_archdesc_did_abstract_ != ''">
          <xsl:value-of select="relationships/describes/descendant::data/@ead_archdesc_did_abstract_"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:result-document>   
                    
    <!-- relatesTo_data_name -->
    <xsl:result-document method="text" href="../data/documentaryUnit_split/{$lang}.{$chi}.{$id}.relatesTo_data_name.txt">
        <!-- do not print empty lines -->
        <xsl:if test="relationships/describes/relationships/relatesTo/descendant::data/@name != ''">
          <xsl:value-of select="relationships/describes/relationships/relatesTo/descendant::data/@name"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:result-document>
  </xsl:template>
	
	<xsl:template match="text()|@*"/>
</xsl:stylesheet>
	