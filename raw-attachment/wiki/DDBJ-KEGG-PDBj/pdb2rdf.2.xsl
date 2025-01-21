<xsl:stylesheet version="1.0"
         	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:pdbx="http://pdbj.protein.osaka-u.ac.jp/XML/pdbmlplus/pdbMLplus_v32.xsd"
		xmlns:pdb="http://www.pdbj.org/ontology/pdb.owl#"
		xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
		xmlns:ro="http://www.obofoundry.org/ro/ro.owl#"
		xmlns:foaf="http://xmlns.com/foaf/0.1/"
		xmlns:bibo="http://purl.org/ontology/bibo/"
	       	xmlns:dc="http://purl.org/dc/elements/1.1/">
  <xsl:output method="xml" indent="yes"/> 

  <xsl:template match="/">
	<rdf:RDF>
		<xsl:apply-templates/>
	</rdf:RDF>
  </xsl:template>
    
  <xsl:template match="pdbx:datablock">
	  <xsl:variable name="base" select="concat('http://www.pdbj.org/', translate(./pdbx:entryCategory/pdbx:entry/@id, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))"/>
	  <pdb:Structure rdf:about="{$base}">
		  <xsl:apply-templates select="pdbx:database_PDB_revCategory/pdbx:database_PDB_rev"/>
		  <xsl:apply-templates select="pdbx:entityCategory/pdbx:entity">
			  <xsl:with-param name="base" select="$base"/>
	          </xsl:apply-templates>
		  <xsl:apply-templates select="pdbx:citationCategory/pdbx:citation"/>
	  </pdb:Structure>
  </xsl:template>

  <xsl:template match="pdbx:entity">
	  <xsl:param name="base"/>
	  <xsl:variable name="id" select="@id"/>
	  <ro:contains>
		<xsl:element name="{pdbx:type}" namespace="http://www.pdbj.org/ontology/pdb.owl#">
			<xsl:attribute name="rdf:about"><xsl:value-of select="concat($base, '#', $id)"/></xsl:attribute>
			<xsl:apply-templates select="pdbx:pdbx_description"/>
			<xsl:apply-templates select="/pdbx:datablock/pdbx:entity_src_genCategory/pdbx:entity_src_gen[@entity_id=$id]"/>
			<xsl:apply-templates select="/pdbx:datablock/pdbx:struct_refCategory/pdbx:struct_ref[@id=$id]"/>
		</xsl:element> 
	  </ro:contains>
  </xsl:template>

  <xsl:template match="pdbx:struct_ref[pdbx:db_name='UNP']">
	  <rdfs:seeAlso rdf:resource="http://purl.uniprot.org/uniprot/{pdbx:pdbx_db_accession}"/>
  </xsl:template>

  <xsl:template match="pdbx:entity_src_gen">
	  <ro:derived-from>
		  <pdb:Gene>
			  <xsl:apply-templates/>
		  </pdb:Gene>
	  </ro:derived-from>
	<xsl:apply-templates mode="source"/>
  </xsl:template>

  <xsl:template match="pdbx:pdbx_description[not(@xsi:nil)]">
	  <rdfs:comment>
		  <xsl:value-of select="."/>
	  </rdfs:comment>
  </xsl:template>

  <xsl:template match="pdbx:pdbx_gene_src_gene[not(@xsi:nil)]|pdbx:title[not(@xsi:nil)]">
	  <rdfs:label>
		  <xsl:value-of select="."/>
	  </rdfs:label>
  </xsl:template>

  <xsl:template match="pdbx:pdbx_gene_src_organ[not(@xsi:nil)]" mode="source">
	  <ro:derived_from>
		  <pdb:Organ>
			  <rdfs:label>
				  <xsl:value-of select="."/>
			  </rdfs:label>
		  </pdb:Organ>
	  </ro:derived_from>
  </xsl:template>

  <xsl:template match="pdbx:pdbx_gene_src_cell_line[not(@xsi:nil)]" mode="source">
	  <ro:derived_from>
		  <pdb:CellLine>
			  <rdfs:label>
				  <xsl:value-of select="."/>
			  </rdfs:label>
		  </pdb:CellLine>
	  </ro:derived_from>
  </xsl:template>

  <xsl:template match="pdbx:pdbx_gene_src_cell[not(@xsi:nil)]" mode="source">
	  <ro:derived_from>
		  <pdb:Cell>
			  <rdfs:label>
				  <xsl:value-of select="."/>
			  </rdfs:label>
		  </pdb:Cell>
	  </ro:derived_from>
  </xsl:template>

  <!-- Set this as main URI instead
  <xsl:template match="pdbx:pdbx_database_id_DOI[not(@xsi:nil)]">
	  <rdfs:sameAs rdf:resource="urn:doi:{.}"/>
  </xsl:template>
  -->

  <xsl:template match="pdbx:database_PDB_rev[1]">
	  <dc:created>
		  <xsl:value-of select="pdbx:date_original"/>
	  </dc:created>
	  <xsl:if test="position()=last() and not(pdbx:date/@xsi:nil)">
	  	<dc:updated>
			<xsl:value-of select="pdbx:date"/>
	  	</dc:updated>
	</xsl:if>
  </xsl:template>

  <xsl:template match="pdbx:database_PDB_rev[last()]">
	  <dc:updated>
		  <xsl:value-of select="pdbx:date"/>
	  </dc:updated>
  </xsl:template>

  <xsl:template match="pdbx:pdbx_gene_ncbi_taxonomy_id">
	  <ro:derived-from>
		  <pdb:Taxon rdf:about="http://www.ncbi.nlm.nih.gov/Taxonomy/{.}">
			  <rdfs:label>
				  <xsl:value-of select="../pdbx:gene_src_scientific_name"/>
			  </rdfs:label>
			  <rdfs:label>
				  <xsl:value-of select="../pdbx:gene_src_common_name"/>
			  </rdfs:label>
		  </pdb:Taxon>
	  </ro:derived-from>
  </xsl:template>

  <!-- Should check for not xsi:nil value -->
  <xsl:template match="pdbx:citation[@id='primary']">
	  <foaf:page>
		  <bibo:AcademicArticle>
			  <xsl:if test="pdbx:pdbx_database_id_DOI[not(@xsi:nil)]">
				  <xsl:attribute name="rdf:about">
					  <xsl:text>urn:doi:</xsl:text>
					  <xsl:value-of select="pdbx:pdbx_database_id_DOI"/>
				  </xsl:attribute>
			  </xsl:if>
			  <rdfs:seeAlso rdf:resource="http://ncbi.nlm.nih.gov/pubmed/{pdbx:pdbx_database_id_PubMed}"/>
			 <xsl:apply-templates/>
		  </bibo:AcademicArticle>
	  </foaf:page>
  </xsl:template>

  <xsl:template match="*"/>
  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="source"/>
</xsl:stylesheet>
