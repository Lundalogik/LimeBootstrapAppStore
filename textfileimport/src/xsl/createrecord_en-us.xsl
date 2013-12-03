<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:variable name="color-list" select="'#FFFFFF|#EEEEEE'"/> 
<xsl:template match="/">
	
	<html>
		<style>
					BODY{
							margin: 20px;
							font-family: Verdana;	
							background-color:#FFFFFF;
							font-size: 10px;
						}
						
						TH{	
							margin: 0px;
							padding:4px;
							background: #DEDEDE;
							font-size: 10px;
							font-weight:bold;
							color:#000000;	
							margin-bottom:5px;
							text-align:left;
						}
						
						.subheaderTable{
							background: #BCD558;
						}
						
						TD{
							padding-top: 8px;
						}
												
						.tablelines{
							font-family: verdana;
							font-size: 10px;
							padding:4px;
							vertical-align: top;
							border-top: 1px solid #999999;
						}
						
						 .main{
							margin-bottom: 20px;	
							border: 1px solid #999999;
						}
						
						.sub{
							border: 1px solid #AAC832;
						}
						
						.field1{
							width: 74px;
							
						}
						
						.field2{
							width: 260px;
							
						}
										
						.field3{
							width: 690px;
			
						}
						
						.field1sub{
							width: 350px;
						}
										
						.field2sub{
							width: 350px;
						}
						
						.smallheader{
							font-size: 12px;
							font-weight: bolder;
							margin-bottom: 10px;
							letter-spacing: 3px;
						}

						.header{
							font-size: 16px;
							font-weight: bolder;
							margin-bottom: 5px;
						}
						
						.checkbox{
							width:12px;
							height:12px;
							margin-right: 5px;
						}
			
		</style>

		<body id="importlog" >
			<div class="header">
				<div>Import overview
				</div>
				<div>
					<br/>
				</div>
				<div class="line"></div>
			</div>
			<br/><br/>
				<xsl:apply-templates>
					<xsl:sort select="//container"/> 
				</xsl:apply-templates>
		</body>
	</html>
</xsl:template>

<xsl:template match="container">

	<div class="smallheader">
		<xsl:value-of select="@localname"/> 
	</div>

	<table cellpadding="0" cellspacing="0" border="0" width="1024px" class="main">
			<tr>
				<th class="field1">Key field</th>
				<th class="field2">Field from Lime</th>
				<th class="field3">Field from filel</th>
			</tr>
			
			<xsl:apply-templates>
				<xsl:sort select="@field" order="ascending" data-type="number"/> 
			</xsl:apply-templates>
		</table>	
		
</xsl:template>

<xsl:template match="box">
			<tr class="tablelines" bgcolor="{substring($color-list,(((position() - 1) mod 2) * 8) + 1,7)}">

				
				<td class="field1" style="border-top: solid 1px #999999;">
					<input type="checkbox" class="checkbox" disabled="true">
						<xsl:if test="@key=1">
							<xsl:attribute name="checked">true</xsl:attribute> 
						</xsl:if>
					</input>
				</td>
				<td class="field2" style="border-top: solid 1px #999999;">
					<xsl:value-of select="@field"/>
				</td>
				<td class="field3"  style="border-top: solid 1px #999999;">
					<xsl:apply-templates>
						<xsl:sort select="//filefield"/> 
					</xsl:apply-templates>
				</td>
			</tr>


</xsl:template>
	
<xsl:template match="filefield">
			<xsl:value-of select="@name"/><br/>
			<xsl:apply-templates>
				<xsl:sort select="/fileoptions/fileoption"/> 
			</xsl:apply-templates>
			
</xsl:template>

<xsl:template match="fileoptions">
		<br/>
		<table cellpadding="0" cellspacing="0" border="0" width="100%" class="sub">
			<th class="subheaderTable field1sub">Value in Lime</th>
			<th class="subheaderTable field2sub">Value in file</th>
			<xsl:apply-templates>
				<xsl:sort select="//fileoption"/> 
			</xsl:apply-templates>
		</table>
</xsl:template>

<xsl:template match="fileoption">
	<tr class="tablelines" bgcolor="{substring($color-list,(((position() - 1) mod 2) * 8) + 1,7)}">
		<td><xsl:value-of select="@limetext"/> </td>
		<td><xsl:value-of select="@text"/></td>
	</tr>
</xsl:template>

<xsl:template match="limeoptions">
		<br/>
		<table cellpadding="0" cellspacing="0" border="0" width="100%" class="sub">
			<th class="subheaderTable">Randomized between</th>
			<xsl:apply-templates>
				<xsl:sort select="//limeoption"/> 
			</xsl:apply-templates>
		</table>
</xsl:template>

<xsl:template match="limeoption">
	<xsl:if test="@selected=1">	
		<tr class="tablelines" bgcolor="{substring($color-list,(((position() - 1) mod 2) * 8) + 1,7)}">
			<td><xsl:value-of select="@text"/> </td>
		</tr>
	</xsl:if>
</xsl:template>



</xsl:stylesheet>