<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:variable name="color-list" select="'#FFFFFF|#EEEEEE'"/> 
<xsl:template match="/">
	<html>
		<style type="text/css" title="currentStyle" media="screen">@import "css/styles.css";</style>
		
		<script language="javascript" src="../../../scripts/Resources.js"></script>
		<script language="javascript" src="../../../scripts/Lime.js"></script>
		<script language="vbscript" src="textfileimport.vbs"></script>	
		<script language="javascript" src="scripts/general.js"></script>

		<body id="importlog" onload="Resources.initializeResources('textfileimport');">
			<div class="header">
				<div resid="xmlLog.header">Information om importen
				</div>
				<div>
					<button resid="xmlLog.buttonSave"  class="saveButtonPosition usebutton" onclick="SaveLogFileToDisk()">Spara</button>					
					<button resid="xmlLog.buttonClose"  class=" right usebutton" onclick="Lime.removeActivePane(window.external);">Stäng</button>
				</div>
				<div class="line"></div>
			</div>
			
			<xsl:apply-templates>
					<xsl:sort select="importinfo"/> 
				</xsl:apply-templates>		
			
		</body>
	</html>
</xsl:template>

<xsl:template match="importinfo">
		<table cellpadding="0" cellspacing="0" border="0" width="700px">
				<tbody>
						<tr class="tableheaders">
								<th resid="xmlLog.mainList"  widht="400px">Huvudlista</th>
								<th resid="xmlLog.created" widht="100px">Antal nyskapade</th>
								<th resid="xmlLog.updated" widht="100px">Antal uppdaterade</th>
								<th resid="xmlLog.notImported" widht="100px">Ej importerade</th>
							</tr>
					
					<xsl:for-each select="//imports/import"> 
						<xsl:sort select="@level" order="ascending" data-type="text"/> 
							<tr class="tablelines" bgcolor="{substring($color-list,(((position() - 1) mod 2) * 8) + 1,7)}">
								<td><xsl:value-of select="@localname"/></td>
								<td><xsl:value-of select="@inserted"/></td>
								<td><xsl:value-of select="@updated"/></td>
								<td><xsl:value-of select="@deleted"/>&#xA0;</td>
							</tr>
					</xsl:for-each>					
				</tbody>
			</table>
			
				<xsl:apply-templates>
					<xsl:sort select="//errors/*/error/@level" order="ascending" data-type="number"/> 
				</xsl:apply-templates>
				
			<table cellpadding="0" cellspacing="0" border="0" width="700px" style="border:solid 0px #DEDFDE">
				<tr class="tablelines">
					<td resid="xmlLog.filepath" class="field1">Sökväg:</td>
					<td><xsl:value-of select="@filepath"/></td>
				</tr>
				<tr class="tablelines">
					<td resid="xmlLog.start" class="field1">Importen påbörjades:</td>
					<td><xsl:value-of select="@start"/></td>
				</tr>
				<tr class="tablelines">
					<td resid="xmlLog.end" class="field1">Klar</td>
					<td><xsl:value-of select="@end"/></td>
				</tr>
				<tr class="tablelines">
					<td resid="xmlLog.diff" class="field1">Antal minuter:</td>
					<td><xsl:value-of select="@diffMinutes"/></td>
				</tr>
			</table>

</xsl:template>

<xsl:template match="importinfo/errors/*">

	<div class="smallheader">
		<xsl:value-of select="@localname"/> 
	</div>

	<table cellpadding="0" cellspacing="0" border="0" width="1024px">
			<tr>
				<th resid="xmlLog.message" class="field1">Meddelande</th>
				<th resid="xmlLog.record" class="field2">Post/radnr</th>
				<th resid="xmlLog.field" class="field3">Fält</th>
				<th resid="xmlLog.originalValue" class="field4" title="logtitle.originalvalue">Orginalvärde</th>
				<th resid="xmlLog.replacedWith" class="field5" title="logtitle.replacedWith">Ersättningsvärde</th>
			</tr>
			
			<xsl:apply-templates>
				<xsl:sort select="@classid" order="ascending" data-type="number"/> 
			</xsl:apply-templates>
		</table>	
		
</xsl:template>

<xsl:template match="error">
	<xsl:if test="@errortype!='key field empty' and @errortype!='deleted line' ">
			<tr class="tablelines" bgcolor="{substring($color-list,(((position() - 1) mod 2) * 8) + 1,7)}">
				<xsl:choose>
					  <xsl:when test="@errortype='length error'">
						  <td resid="xmlLog.maxLength" class="field1" title="logtitle.maxLength">Maxlängd överskriden.</td>
					  </xsl:when>
					  <xsl:when test="@errortype='numeric error'">
						  <td resid="xmlLog.notNumeric" class="field1" title="logtitle.notNumeric">Ej numeriskt.</td>
					  </xsl:when>
					  <xsl:when test="@errortype='date error'">
						  <td resid="xmlLog.notDate" class="field1" title="logtitle.notDate">Ej datum.</td>
					  </xsl:when>
					  <xsl:when test="@errortype='min error'">
						  <td resid="xmlLog.tooLow" class="field1" title="logtitle.tooLow">För lågt värde.</td>
					  </xsl:when>
					  <xsl:when test="@errortype='max error'">
						  <td resid="xmlLog.tooHigh" class="field1" title="logtitle.tooHigh">För högt värde.</td>
					  </xsl:when>
					  <xsl:when test="@errortype='empty mandatory field'">
						  <td resid="xmlLog.emptyRequired" class="field1" title="logtitle.emptyRequired">Tomt obligatoriskt.</td>
					  </xsl:when>
				</xsl:choose>
				
				<td class="field2">
					<a>
						<xsl:attribute name="href"><xsl:value-of select="@link"/></xsl:attribute>
						<xsl:value-of select="@classid"/>
					</a>
				</td>
				
				<td class="field3"><xsl:value-of select="@localnamefield"/></td>
				
				<td class="field4"><xsl:value-of select="@originvalue"/></td>
				
					<xsl:choose>
						<xsl:when test="@replacevalue='*DELETED*'">
									<td resid="xmlLog.valueRemoved" class="field5">Värdet togs bort - [TOMT]</td>
						</xsl:when>
						<xsl:otherwise>		
							<td class="field5"><xsl:value-of select="@replacevalue"/></td>
						</xsl:otherwise>		
					</xsl:choose>
			</tr>
			</xsl:if>


			<xsl:if test="@errortype='deleted line' ">
				<tr class="tablelines" bgcolor="{substring($color-list,(((position() - 1) mod 2) * 8) + 1,7)}">
				<xsl:choose>
					  <xsl:when test="@level='main' ">
							<td resid="xmlLog.lineNotImported" class="field1 notimported" title="logtitle.mainNotImported">Ej importerad.</td>
					 </xsl:when>
					 <xsl:otherwise>
						 <td resid="xmlLog.lineNotImported" class="field1 notimported" title="logtitle.subNotImported">Ej importerad.</td>
					 </xsl:otherwise>
				</xsl:choose>
				
				<td class="field2" title="logtitle.lineno"><xsl:value-of select="@lineno"/></td>
				
				<td class="field3">&#xA0;</td>
				
				<td class="field4">&#xA0;</td>
				
				<td class="field5">&#xA0;</td>
				</tr>
 			</xsl:if>
</xsl:template>
</xsl:stylesheet>