<?xml version="1.0" encoding="UTF-8"?><xsl2:stylesheet 
  version="2.0"
  xmlns:xsl2="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:PDBx="http://pdbml.pdb.org/schema/pdbx-v32.xsd"
  xmlns:PDBo="http://www.pdbj.org/schema/pdbx-v32.owl#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  >
    
  <xsl2:output method="xml" indent="yes"/>
  <xsl2:strip-space elements="*"/>
  <xsl2:variable name="PDBID"><xsl2:value-of select="/PDBx:datablock/PDBx:entryCategory/PDBx:entry/@id"/></xsl2:variable>
  <xsl2:variable name="pdbid"><xsl2:value-of select="translate($PDBID, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/></xsl2:variable>
  <xsl2:variable name="base">http://service.pdbj.org/mine/xpath/<xsl2:value-of select="$PDBID"/></xsl2:variable>
  <xsl2:variable name="base_lower">http://service.pdbj.org/mine/xpath/<xsl2:value-of select="$pdbid"/></xsl2:variable>
  <xsl2:variable name="pdb_link">http://www.pdbj.org/rdf/</xsl2:variable>
  <xsl2:variable name="doi">http://dx.doi.org/</xsl2:variable>
  <xsl2:variable name="pubmed">http://www.ncbi.nlm.nih.gov/pubmed/</xsl2:variable>
  <xsl2:variable name="taxonomy">http://www.ncbi.nlm.nih.gov/taxonomy/</xsl2:variable>
  <xsl2:variable name="genbank">http://www.ncbi.nlm.nih.gov/nuccore/</xsl2:variable>
  <xsl2:variable name="uniprot">http://purl.uniprot.org/uniprot/</xsl2:variable>
  <xsl2:variable name="enzyme">http://purl.uniprot.org/enzyme/</xsl2:variable>
  <xsl2:variable name="go">http://www.ebi.ac.uk/QuickGo/GTerm?id=GO:/</xsl2:variable>
  <xsl2:variable name="rcsb">http://www.rcsb.org/pdb/explore.do?structureId=</xsl2:variable>
  <xsl2:variable name="pdbe">http://www.ebi.ac.uk/pdbe-srv/view/entry/</xsl2:variable>

  <xsl2:template match="/">
    <rdf:RDF>
      <xsl2:apply-templates/>
    </rdf:RDF>
  </xsl2:template>

  <!-- level 1 -->
  <xsl2:template match="/PDBx:datablock">
    <PDBo:datablock rdf:about="{$base}">
      <rdfs:sameAs rdf:resource="{$base}/PDBx:datablock"/>
      <rdfs:sameAs rdf:resource="{$base_lower}"/>
      <rdfs:seeAlso rdf:resource="{$rcsb}{$PDBID}"/>
      <rdfs:seeAlso rdf:resource="{$pdbe}{$PDBID}"/>
      <xsl2:variable name="base"><xsl2:value-of select="$base"/>/PDBx:datablock</xsl2:variable>
      <PDBo:datablockName><xsl2:value-of select="@datablockName"/></PDBo:datablockName>
      <xsl2:apply-templates>
        <xsl2:with-param name="base" select="$base"/>
      </xsl2:apply-templates>
    </PDBo:datablock>
  </xsl2:template>

  <!-- level 2 -->
  <xsl2:template match="/PDBx:datablock/*">
    <xsl2:variable name="new_base"><xsl2:value-of select="$base"/>/<xsl2:value-of select="name()"/></xsl2:variable>
    <xsl2:apply-templates>
      <xsl2:with-param name="base" select="$new_base"/>
    </xsl2:apply-templates>
  </xsl2:template>

  <!-- level 4 (PCData) -->
  <xsl2:template match="/PDBx:datablock/*/*/*[not(xsi:nil) and text() != '']">
    <xsl2:element name="PDBo:{concat(local-name(parent::node()),'.',local-name())}">
      <xsl2:value-of select="."/>
    </xsl2:element>
  </xsl2:template>

  <!-- level 4 (attribute) -->
  <xsl2:template match="/PDBx:datablock/*/*/@*">
    <xsl2:element name="PDBo:{concat(local-name(parent::node()),'.',translate(name(),'@',''))}">
      <xsl2:value-of select="."/>
    </xsl2:element>
  </xsl2:template>

  <!-- level 4 (linked data) -->
  <xsl2:template match="PDBx:citation/PDBx:pdbx_database_id_DOI[text() != '']" mode="linked">
    <PDBo:link_to_doi rdf:resource="{$doi}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:citation/PDBx:pdbx_database_id_PubMed[text() != '']" mode="linked">
    <PDBo:link_to_pubmed rdf:resource="{$pubmed}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:entity_src_gen/PDBx:pdbx_gene_src_ncbi_taxonomy_id[text() != '']" 
	        mode="linked">
    <PDBo:link_to_taxonomy_source rdf:resource="{$taxonomy}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:entity_src_gen/PDBx:pdbx_host_org_ncbi_taxonomy_id[text() != '']" 
	        mode="linked">
    <PDBo:link_to_taxonomy_host rdf:resource="{$taxonomy}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:entity_src_nat/PDBx:pdbx_ncbi_taxonomy_id[text() != '']" 
	        mode="linked">
    <PDBo:link_to_taxonomy_source rdf:resource="{$taxonomy}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:entity/PDBx:pdbx_ec[text() != '']" mode="linked">
    <PDBo:link_to_enzyme rdf:resource="{$enzyme}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:struct_ref/PDBx:pdbx_db_accession[../PDBx:db_name='UNP' and text() != '']" 
	        mode="linked">
    <PDBo:link_to_uniprot rdf:resource="{$uniprot}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:struct_ref/PDBx:pdbx_db_accession[../PDBx:db_name='GB' and text() != '']" 
	        mode="linked">
    <PDBo:link_to_genbank rdf:resource="{$genbank}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:gene_ontology/PDBx:goid[text() != '']" mode="linked">
    <PDBo:link_to_go rdf:resource="{$go}{text()}"/>
  </xsl2:template>

  <xsl2:template match="PDBx:pdbx_database_related[@db_name='PDB']/@db_id" mode="linked">
    <PDBo:link_to_pdb rdf:resource="{$pdb_link}{.}"/>
  </xsl2:template>

  <!-- level-3 templates follow -->
    
  <xsl2:template match="PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site">
    <PDBo:atom_siteCategory>
      <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_auth_alt_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(@pdbx_auth_alt_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_1</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@label_alt_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@label_alt_id='{replace(@label_alt_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_2</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_3</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_4</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_5</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_6</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_7</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!='' and @type_symbol!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@type_symbol='{replace(@type_symbol,' +','%20')}']">
            <rdfs:label>atom_siteKey_8</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_9</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@label_asym_id!='' and @label_comp_id!='' and @label_entity_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_entity_id='{replace(@label_entity_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_10</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_11</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_auth_alt_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(@pdbx_auth_alt_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_12</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_seq_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_13</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_14</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_15</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_16</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_17</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_18</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_19</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_20</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_21</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_22</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_23</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_24</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_25</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_auth_alt_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(@pdbx_auth_alt_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_26</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_auth_alt_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(@pdbx_auth_alt_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_27</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!='' and @pdbx_PDB_model_num!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKey_28</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_29</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_30</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_atom_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!='' and @pdbx_PDB_ins_code!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(@pdbx_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKey_31</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_atom_id!='' and @auth_seq_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_32</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@auth_asym_id!='' and @auth_atom_id!='' and @auth_comp_id!='' and @auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_atom_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <rdfs:sameAs>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(@auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(@auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(@auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(@label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKey_33</rdfs:label>
          </PDBo:atom_site>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="PDBx:footnote_id!=''">
        <PDBo:reference_to_atom_sites_footnote>
          <PDBo:atom_sites_footnote rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_footnoteCategory/PDBx:atom_sites_footnote[@id='{replace(PDBx:footnote_id,' +','%20')}']">
            <rdfs:label>atom_sites_footnoteKeyref_1_0_0</rdfs:label>
          </PDBo:atom_sites_footnote>
        </PDBo:reference_to_atom_sites_footnote>
      </xsl2:if>
      <xsl2:if test="PDBx:type_symbol!=''">
        <PDBo:reference_to_atom_type>
          <PDBo:atom_type rdf:about="{$base}/PDBx:datablock/PDBx:atom_typeCategory/PDBx:atom_type[@symbol='{replace(PDBx:type_symbol,' +','%20')}']">
            <rdfs:label>atom_typeKeyref_1_0_0</rdfs:label>
          </PDBo:atom_type>
        </PDBo:reference_to_atom_type>
      </xsl2:if>
      <xsl2:if test="PDBx:label_comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(PDBx:label_comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_0_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:label_atom_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(PDBx:label_atom_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_0_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="PDBx:chemical_conn_number!=''">
        <PDBo:reference_to_chemical_conn_atom>
          <PDBo:chemical_conn_atom rdf:about="{$base}/PDBx:datablock/PDBx:chemical_conn_atomCategory/PDBx:chemical_conn_atom[@number='{replace(PDBx:chemical_conn_number,' +','%20')}']">
            <rdfs:label>chemical_conn_atomKeyref_1_0_0</rdfs:label>
          </PDBo:chemical_conn_atom>
        </PDBo:reference_to_chemical_conn_atom>
      </xsl2:if>
      <xsl2:if test="PDBx:label_entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:label_entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_0_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="PDBx:label_seq_id!=''">
        <PDBo:reference_to_entity_poly_seq>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@num='{replace(PDBx:label_seq_id,' +','%20')}']">
            <rdfs:label>entity_poly_seqKeyref_1_0_0</rdfs:label>
          </PDBo:entity_poly_seq>
        </PDBo:reference_to_entity_poly_seq>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_tls_group_id!=''">
        <PDBo:reference_to_pdbx_refine_tls>
          <PDBo:pdbx_refine_tls rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refine_tlsCategory/PDBx:pdbx_refine_tls[@id='{replace(PDBx:pdbx_tls_group_id,' +','%20')}']">
            <rdfs:label>pdbx_refine_tlsKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_refine_tls>
        </PDBo:reference_to_pdbx_refine_tls>
      </xsl2:if>
      <xsl2:if test="PDBx:label_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:label_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_0_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_ncs_dom_id!=''">
        <PDBo:reference_to_struct_ncs_dom>
          <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@id='{replace(PDBx:pdbx_ncs_dom_id,' +','%20')}']">
            <rdfs:label>struct_ncs_domKeyref_1_0_0</rdfs:label>
          </PDBo:struct_ncs_dom>
        </PDBo:reference_to_struct_ncs_dom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_site>
    </PDBo:atom_siteCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:atom_site_anisotropCategory/PDBx:atom_site_anisotrop">
    <PDBo:atom_site_anisotropCategory>
      <PDBo:atom_site_anisotrop rdf:about="{$base}/PDBx:datablock/PDBx:atom_site_anisotropCategory/PDBx:atom_site_anisotrop[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!='' and PDBx:pdbx_PDB_ins_code!='' and PDBx:pdbx_auth_alt_id!='' and PDBx:pdbx_auth_asym_id!='' and PDBx:pdbx_auth_atom_id!='' and PDBx:pdbx_auth_comp_id!='' and PDBx:pdbx_auth_seq_id!='' and PDBx:pdbx_label_alt_id!='' and PDBx:pdbx_label_asym_id!='' and PDBx:pdbx_label_atom_id!='' and PDBx:pdbx_label_comp_id!='' and PDBx:pdbx_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(@id,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_PDB_ins_code,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_auth_alt_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_auth_asym_id,' +','%20')}'%20and%20@id='{replace(PDBx:pdbx_auth_atom_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:pdbx_auth_comp_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_auth_seq_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:pdbx_label_alt_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:pdbx_label_asym_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:pdbx_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_label_comp_id,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(PDBx:pdbx_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_1_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_PDB_ins_code!='' and PDBx:pdbx_auth_alt_id!='' and PDBx:pdbx_auth_asym_id!='' and PDBx:pdbx_auth_atom_id!='' and PDBx:pdbx_auth_comp_id!='' and PDBx:pdbx_auth_seq_id!='' and PDBx:pdbx_label_alt_id!='' and PDBx:pdbx_label_alt_id!='' and PDBx:pdbx_label_asym_id!='' and PDBx:pdbx_label_atom_id!='' and PDBx:pdbx_label_comp_id!='' and PDBx:pdbx_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_auth_alt_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_auth_atom_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:pdbx_auth_comp_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:pdbx_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_label_alt_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:pdbx_label_alt_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:pdbx_label_asym_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:pdbx_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_label_comp_id,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(PDBx:pdbx_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_26_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:type_symbol!=''">
        <PDBo:reference_to_atom_type>
          <PDBo:atom_type rdf:about="{$base}/PDBx:datablock/PDBx:atom_typeCategory/PDBx:atom_type[@symbol='{replace(PDBx:type_symbol,' +','%20')}']">
            <rdfs:label>atom_typeKeyref_1_1_0</rdfs:label>
          </PDBo:atom_type>
        </PDBo:reference_to_atom_type>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_site_anisotrop>
    </PDBo:atom_site_anisotropCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:atom_sitesCategory/PDBx:atom_sites">
    <PDBo:atom_sitesCategory>
      <PDBo:atom_sites rdf:about="{$base}/PDBx:datablock/PDBx:atom_sitesCategory/PDBx:atom_sites[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_0_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_sites>
    </PDBo:atom_sitesCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:atom_sites_altCategory/PDBx:atom_sites_alt">
    <PDBo:atom_sites_altCategory>
      <PDBo:atom_sites_alt rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_altCategory/PDBx:atom_sites_alt[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@label_alt_id='{replace(@id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_2_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_sites_alt>
    </PDBo:atom_sites_altCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:atom_sites_alt_ensCategory/PDBx:atom_sites_alt_ens">
    <PDBo:atom_sites_alt_ensCategory>
      <PDBo:atom_sites_alt_ens rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_alt_ensCategory/PDBx:atom_sites_alt_ens[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_sites_alt_ens>
    </PDBo:atom_sites_alt_ensCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:atom_sites_alt_genCategory/PDBx:atom_sites_alt_gen">
    <PDBo:atom_sites_alt_genCategory>
      <PDBo:atom_sites_alt_gen rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_alt_genCategory/PDBx:atom_sites_alt_gen[@alt_id='{replace(@alt_id,' +','%20')}'%20and%20@ens_id='{replace(@ens_id,' +','%20')}']">
      <xsl2:if test="@alt_id!=''">
        <PDBo:reference_to_atom_sites_alt>
          <PDBo:atom_sites_alt rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_altCategory/PDBx:atom_sites_alt[@id='{replace(@alt_id,' +','%20')}']">
            <rdfs:label>atom_sites_altKeyref_1_0_0</rdfs:label>
          </PDBo:atom_sites_alt>
        </PDBo:reference_to_atom_sites_alt>
      </xsl2:if>
      <xsl2:if test="@ens_id!=''">
        <PDBo:reference_to_atom_sites_alt_ens>
          <PDBo:atom_sites_alt_ens rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_alt_ensCategory/PDBx:atom_sites_alt_ens[@id='{replace(@ens_id,' +','%20')}']">
            <rdfs:label>atom_sites_alt_ensKeyref_1_0_0</rdfs:label>
          </PDBo:atom_sites_alt_ens>
        </PDBo:reference_to_atom_sites_alt_ens>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_sites_alt_gen>
    </PDBo:atom_sites_alt_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:atom_sites_footnoteCategory/PDBx:atom_sites_footnote">
    <PDBo:atom_sites_footnoteCategory>
      <PDBo:atom_sites_footnote rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_footnoteCategory/PDBx:atom_sites_footnote[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_sites_footnote>
    </PDBo:atom_sites_footnoteCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:atom_typeCategory/PDBx:atom_type">
    <PDBo:atom_typeCategory>
      <PDBo:atom_type rdf:about="{$base}/PDBx:datablock/PDBx:atom_typeCategory/PDBx:atom_type[@symbol='{replace(@symbol,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:atom_type>
    </PDBo:atom_typeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:auditCategory/PDBx:audit">
    <PDBo:auditCategory>
      <PDBo:audit rdf:about="{$base}/PDBx:datablock/PDBx:auditCategory/PDBx:audit[@revision_id='{replace(@revision_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:audit>
    </PDBo:auditCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:audit_authorCategory/PDBx:audit_author">
    <PDBo:audit_authorCategory>
      <PDBo:audit_author rdf:about="{$base}/PDBx:datablock/PDBx:audit_authorCategory/PDBx:audit_author[@pdbx_ordinal='{replace(@pdbx_ordinal,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:audit_author>
    </PDBo:audit_authorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:audit_conformCategory/PDBx:audit_conform">
    <PDBo:audit_conformCategory>
      <PDBo:audit_conform rdf:about="{$base}/PDBx:datablock/PDBx:audit_conformCategory/PDBx:audit_conform[@dict_name='{replace(@dict_name,' +','%20')}'%20and%20@dict_version='{replace(@dict_version,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:audit_conform>
    </PDBo:audit_conformCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:audit_contact_authorCategory/PDBx:audit_contact_author">
    <PDBo:audit_contact_authorCategory>
      <PDBo:audit_contact_author rdf:about="{$base}/PDBx:datablock/PDBx:audit_contact_authorCategory/PDBx:audit_contact_author[@name='{replace(@name,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:audit_contact_author>
    </PDBo:audit_contact_authorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:audit_linkCategory/PDBx:audit_link">
    <PDBo:audit_linkCategory>
      <PDBo:audit_link rdf:about="{$base}/PDBx:datablock/PDBx:audit_linkCategory/PDBx:audit_link[@block_code='{replace(@block_code,' +','%20')}'%20and%20@block_description='{replace(@block_description,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:audit_link>
    </PDBo:audit_linkCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:cellCategory/PDBx:cell">
    <PDBo:cellCategory>
      <PDBo:cell rdf:about="{$base}/PDBx:datablock/PDBx:cellCategory/PDBx:cell[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_1_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:cell>
    </PDBo:cellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:cell_measurementCategory/PDBx:cell_measurement">
    <PDBo:cell_measurementCategory>
      <PDBo:cell_measurement rdf:about="{$base}/PDBx:datablock/PDBx:cell_measurementCategory/PDBx:cell_measurement[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_2_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:cell_measurement>
    </PDBo:cell_measurementCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:cell_measurement_reflnCategory/PDBx:cell_measurement_refln">
    <PDBo:cell_measurement_reflnCategory>
      <PDBo:cell_measurement_refln rdf:about="{$base}/PDBx:datablock/PDBx:cell_measurement_reflnCategory/PDBx:cell_measurement_refln[@index_h='{replace(@index_h,' +','%20')}'%20and%20@index_k='{replace(@index_k,' +','%20')}'%20and%20@index_l='{replace(@index_l,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:cell_measurement_refln>
    </PDBo:cell_measurement_reflnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp">
    <PDBo:chem_compCategory>
      <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@type!=''">
        <rdfs:sameAs>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@type='{replace(@type,' +','%20')}']">
            <rdfs:label>chem_compKey_2</rdfs:label>
          </PDBo:chem_comp>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp>
    </PDBo:chem_compCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_angleCategory/PDBx:chem_comp_angle">
    <PDBo:chem_comp_angleCategory>
      <PDBo:chem_comp_angle rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_angleCategory/PDBx:chem_comp_angle[@atom_id_1='{replace(@atom_id_1,' +','%20')}'%20and%20@atom_id_2='{replace(@atom_id_2,' +','%20')}'%20and%20@atom_id_3='{replace(@atom_id_3,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
      <xsl2:if test="@atom_id_2!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id_2,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_1_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="@atom_id_3!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id_3,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_1_1</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="@atom_id_1!='' and @comp_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id_1,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_2_0_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_angle>
    </PDBo:chem_comp_angleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom">
    <PDBo:chem_comp_atomCategory>
      <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
      <xsl2:if test="@atom_id!=''">
        <rdfs:sameAs>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKey_1</rdfs:label>
          </PDBo:chem_comp_atom>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@comp_id!=''">
        <rdfs:sameAs>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@comp_id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKey_3</rdfs:label>
          </PDBo:chem_comp_atom>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_1_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_atom>
    </PDBo:chem_comp_atomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_bondCategory/PDBx:chem_comp_bond">
    <PDBo:chem_comp_bondCategory>
      <PDBo:chem_comp_bond rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_bondCategory/PDBx:chem_comp_bond[@atom_id_1='{replace(@atom_id_1,' +','%20')}'%20and%20@atom_id_2='{replace(@atom_id_2,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
      <xsl2:if test="@atom_id_1!='' and @comp_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id_1,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_2_1_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="@atom_id_2!='' and @comp_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id_2,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_2_1_1</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_bond>
    </PDBo:chem_comp_bondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_chirCategory/PDBx:chem_comp_chir">
    <PDBo:chem_comp_chirCategory>
      <PDBo:chem_comp_chir rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_chirCategory/PDBx:chem_comp_chir[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:chem_comp_chir rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_chirCategory/PDBx:chem_comp_chir[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>chem_comp_chirKey_1</rdfs:label>
          </PDBo:chem_comp_chir>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_2_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(PDBx:atom_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_2_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_chir>
    </PDBo:chem_comp_chirCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_chir_atomCategory/PDBx:chem_comp_chir_atom">
    <PDBo:chem_comp_chir_atomCategory>
      <PDBo:chem_comp_chir_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_chir_atomCategory/PDBx:chem_comp_chir_atom[@atom_id='{replace(@atom_id,' +','%20')}'%20and%20@chir_id='{replace(@chir_id,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_3_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="@atom_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_3_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="@chir_id!=''">
        <PDBo:reference_to_chem_comp_chir>
          <PDBo:chem_comp_chir rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_chirCategory/PDBx:chem_comp_chir[@id='{replace(@chir_id,' +','%20')}']">
            <rdfs:label>chem_comp_chirKeyref_1_0_0</rdfs:label>
          </PDBo:chem_comp_chir>
        </PDBo:reference_to_chem_comp_chir>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_chir_atom>
    </PDBo:chem_comp_chir_atomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_linkCategory/PDBx:chem_comp_link">
    <PDBo:chem_comp_linkCategory>
      <PDBo:chem_comp_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_linkCategory/PDBx:chem_comp_link[@link_id='{replace(@link_id,' +','%20')}']">
      <xsl2:if test="PDBx:type_comp_1!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@type='{replace(PDBx:type_comp_1,' +','%20')}']">
            <rdfs:label>chem_compKeyref_2_0_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:type_comp_2!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@type='{replace(PDBx:type_comp_2,' +','%20')}']">
            <rdfs:label>chem_compKeyref_2_0_1</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="@link_id!=''">
        <PDBo:reference_to_chem_link>
          <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@link_id,' +','%20')}']">
            <rdfs:label>chem_linkKeyref_1_0_0</rdfs:label>
          </PDBo:chem_link>
        </PDBo:reference_to_chem_link>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_link>
    </PDBo:chem_comp_linkCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_planeCategory/PDBx:chem_comp_plane">
    <PDBo:chem_comp_planeCategory>
      <PDBo:chem_comp_plane rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_planeCategory/PDBx:chem_comp_plane[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:chem_comp_plane rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_planeCategory/PDBx:chem_comp_plane[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>chem_comp_planeKey_1</rdfs:label>
          </PDBo:chem_comp_plane>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_4_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_plane>
    </PDBo:chem_comp_planeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_plane_atomCategory/PDBx:chem_comp_plane_atom">
    <PDBo:chem_comp_plane_atomCategory>
      <PDBo:chem_comp_plane_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_plane_atomCategory/PDBx:chem_comp_plane_atom[@atom_id='{replace(@atom_id,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@plane_id='{replace(@plane_id,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_5_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="@atom_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(@atom_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_4_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="@plane_id!=''">
        <PDBo:reference_to_chem_comp_plane>
          <PDBo:chem_comp_plane rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_planeCategory/PDBx:chem_comp_plane[@id='{replace(@plane_id,' +','%20')}']">
            <rdfs:label>chem_comp_planeKeyref_1_0_0</rdfs:label>
          </PDBo:chem_comp_plane>
        </PDBo:reference_to_chem_comp_plane>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_plane_atom>
    </PDBo:chem_comp_plane_atomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_torCategory/PDBx:chem_comp_tor">
    <PDBo:chem_comp_torCategory>
      <PDBo:chem_comp_tor rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_torCategory/PDBx:chem_comp_tor[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:chem_comp_tor rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_torCategory/PDBx:chem_comp_tor[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>chem_comp_torKey_1</rdfs:label>
          </PDBo:chem_comp_tor>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_id_2!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(PDBx:atom_id_2,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_5_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_id_3!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(PDBx:atom_id_3,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_5_1</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_id_4!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(PDBx:atom_id_4,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_1_5_2</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_id_1!='' and @comp_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@atom_id='{replace(PDBx:atom_id_1,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_2_2_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_tor>
    </PDBo:chem_comp_torCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_comp_tor_valueCategory/PDBx:chem_comp_tor_value">
    <PDBo:chem_comp_tor_valueCategory>
      <PDBo:chem_comp_tor_value rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_tor_valueCategory/PDBx:chem_comp_tor_value[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@tor_id='{replace(@tor_id,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp_atom>
          <PDBo:chem_comp_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_atomCategory/PDBx:chem_comp_atom[@comp_id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_comp_atomKeyref_3_0_0</rdfs:label>
          </PDBo:chem_comp_atom>
        </PDBo:reference_to_chem_comp_atom>
      </xsl2:if>
      <xsl2:if test="@tor_id!=''">
        <PDBo:reference_to_chem_comp_tor>
          <PDBo:chem_comp_tor rdf:about="{$base}/PDBx:datablock/PDBx:chem_comp_torCategory/PDBx:chem_comp_tor[@id='{replace(@tor_id,' +','%20')}']">
            <rdfs:label>chem_comp_torKeyref_1_0_0</rdfs:label>
          </PDBo:chem_comp_tor>
        </PDBo:reference_to_chem_comp_tor>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_comp_tor_value>
    </PDBo:chem_comp_tor_valueCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link">
    <PDBo:chem_linkCategory>
      <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link>
    </PDBo:chem_linkCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_angleCategory/PDBx:chem_link_angle">
    <PDBo:chem_link_angleCategory>
      <PDBo:chem_link_angle rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_angleCategory/PDBx:chem_link_angle[@atom_id_1='{replace(@atom_id_1,' +','%20')}'%20and%20@atom_id_2='{replace(@atom_id_2,' +','%20')}'%20and%20@atom_id_3='{replace(@atom_id_3,' +','%20')}'%20and%20@link_id='{replace(@link_id,' +','%20')}']">
      <xsl2:if test="@link_id!=''">
        <PDBo:reference_to_chem_link>
          <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@link_id,' +','%20')}']">
            <rdfs:label>chem_linkKeyref_1_1_0</rdfs:label>
          </PDBo:chem_link>
        </PDBo:reference_to_chem_link>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_angle>
    </PDBo:chem_link_angleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_bondCategory/PDBx:chem_link_bond">
    <PDBo:chem_link_bondCategory>
      <PDBo:chem_link_bond rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_bondCategory/PDBx:chem_link_bond[@atom_id_1='{replace(@atom_id_1,' +','%20')}'%20and%20@atom_id_2='{replace(@atom_id_2,' +','%20')}'%20and%20@link_id='{replace(@link_id,' +','%20')}']">
      <xsl2:if test="@link_id!=''">
        <PDBo:reference_to_chem_link>
          <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@link_id,' +','%20')}']">
            <rdfs:label>chem_linkKeyref_1_2_0</rdfs:label>
          </PDBo:chem_link>
        </PDBo:reference_to_chem_link>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_bond>
    </PDBo:chem_link_bondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_chirCategory/PDBx:chem_link_chir">
    <PDBo:chem_link_chirCategory>
      <PDBo:chem_link_chir rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_chirCategory/PDBx:chem_link_chir[@id='{replace(@id,' +','%20')}'%20and%20@link_id='{replace(@link_id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:chem_link_chir rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_chirCategory/PDBx:chem_link_chir[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>chem_link_chirKey_1</rdfs:label>
          </PDBo:chem_link_chir>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@link_id!=''">
        <PDBo:reference_to_chem_link>
          <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@link_id,' +','%20')}']">
            <rdfs:label>chem_linkKeyref_1_3_0</rdfs:label>
          </PDBo:chem_link>
        </PDBo:reference_to_chem_link>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_chir>
    </PDBo:chem_link_chirCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_chir_atomCategory/PDBx:chem_link_chir_atom">
    <PDBo:chem_link_chir_atomCategory>
      <PDBo:chem_link_chir_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_chir_atomCategory/PDBx:chem_link_chir_atom[@atom_id='{replace(@atom_id,' +','%20')}'%20and%20@chir_id='{replace(@chir_id,' +','%20')}']">
      <xsl2:if test="@chir_id!=''">
        <PDBo:reference_to_chem_link_chir>
          <PDBo:chem_link_chir rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_chirCategory/PDBx:chem_link_chir[@id='{replace(@chir_id,' +','%20')}']">
            <rdfs:label>chem_link_chirKeyref_1_0_0</rdfs:label>
          </PDBo:chem_link_chir>
        </PDBo:reference_to_chem_link_chir>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_chir_atom>
    </PDBo:chem_link_chir_atomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_planeCategory/PDBx:chem_link_plane">
    <PDBo:chem_link_planeCategory>
      <PDBo:chem_link_plane rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_planeCategory/PDBx:chem_link_plane[@id='{replace(@id,' +','%20')}'%20and%20@link_id='{replace(@link_id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:chem_link_plane rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_planeCategory/PDBx:chem_link_plane[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>chem_link_planeKey_1</rdfs:label>
          </PDBo:chem_link_plane>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@link_id!=''">
        <PDBo:reference_to_chem_link>
          <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@link_id,' +','%20')}']">
            <rdfs:label>chem_linkKeyref_1_4_0</rdfs:label>
          </PDBo:chem_link>
        </PDBo:reference_to_chem_link>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_plane>
    </PDBo:chem_link_planeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_plane_atomCategory/PDBx:chem_link_plane_atom">
    <PDBo:chem_link_plane_atomCategory>
      <PDBo:chem_link_plane_atom rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_plane_atomCategory/PDBx:chem_link_plane_atom[@atom_id='{replace(@atom_id,' +','%20')}'%20and%20@plane_id='{replace(@plane_id,' +','%20')}']">
      <xsl2:if test="@plane_id!=''">
        <PDBo:reference_to_chem_link_plane>
          <PDBo:chem_link_plane rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_planeCategory/PDBx:chem_link_plane[@id='{replace(@plane_id,' +','%20')}']">
            <rdfs:label>chem_link_planeKeyref_1_0_0</rdfs:label>
          </PDBo:chem_link_plane>
        </PDBo:reference_to_chem_link_plane>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_plane_atom>
    </PDBo:chem_link_plane_atomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_torCategory/PDBx:chem_link_tor">
    <PDBo:chem_link_torCategory>
      <PDBo:chem_link_tor rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_torCategory/PDBx:chem_link_tor[@id='{replace(@id,' +','%20')}'%20and%20@link_id='{replace(@link_id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:chem_link_tor rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_torCategory/PDBx:chem_link_tor[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>chem_link_torKey_1</rdfs:label>
          </PDBo:chem_link_tor>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@link_id!=''">
        <PDBo:reference_to_chem_link>
          <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@link_id,' +','%20')}']">
            <rdfs:label>chem_linkKeyref_1_5_0</rdfs:label>
          </PDBo:chem_link>
        </PDBo:reference_to_chem_link>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_tor>
    </PDBo:chem_link_torCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chem_link_tor_valueCategory/PDBx:chem_link_tor_value">
    <PDBo:chem_link_tor_valueCategory>
      <PDBo:chem_link_tor_value rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_tor_valueCategory/PDBx:chem_link_tor_value[@tor_id='{replace(@tor_id,' +','%20')}']">
      <xsl2:if test="@tor_id!=''">
        <PDBo:reference_to_chem_link_tor>
          <PDBo:chem_link_tor rdf:about="{$base}/PDBx:datablock/PDBx:chem_link_torCategory/PDBx:chem_link_tor[@id='{replace(@tor_id,' +','%20')}']">
            <rdfs:label>chem_link_torKeyref_1_0_0</rdfs:label>
          </PDBo:chem_link_tor>
        </PDBo:reference_to_chem_link_tor>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chem_link_tor_value>
    </PDBo:chem_link_tor_valueCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chemicalCategory/PDBx:chemical">
    <PDBo:chemicalCategory>
      <PDBo:chemical rdf:about="{$base}/PDBx:datablock/PDBx:chemicalCategory/PDBx:chemical[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_3_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chemical>
    </PDBo:chemicalCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chemical_conn_atomCategory/PDBx:chemical_conn_atom">
    <PDBo:chemical_conn_atomCategory>
      <PDBo:chemical_conn_atom rdf:about="{$base}/PDBx:datablock/PDBx:chemical_conn_atomCategory/PDBx:chemical_conn_atom[@number='{replace(@number,' +','%20')}']">
      <xsl2:if test="PDBx:type_symbol!=''">
        <PDBo:reference_to_atom_type>
          <PDBo:atom_type rdf:about="{$base}/PDBx:datablock/PDBx:atom_typeCategory/PDBx:atom_type[@symbol='{replace(PDBx:type_symbol,' +','%20')}']">
            <rdfs:label>atom_typeKeyref_1_2_0</rdfs:label>
          </PDBo:atom_type>
        </PDBo:reference_to_atom_type>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chemical_conn_atom>
    </PDBo:chemical_conn_atomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chemical_conn_bondCategory/PDBx:chemical_conn_bond">
    <PDBo:chemical_conn_bondCategory>
      <PDBo:chemical_conn_bond rdf:about="{$base}/PDBx:datablock/PDBx:chemical_conn_bondCategory/PDBx:chemical_conn_bond[@atom_1='{replace(@atom_1,' +','%20')}'%20and%20@atom_2='{replace(@atom_2,' +','%20')}']">
      <xsl2:if test="@atom_1!=''">
        <PDBo:reference_to_chemical_conn_atom>
          <PDBo:chemical_conn_atom rdf:about="{$base}/PDBx:datablock/PDBx:chemical_conn_atomCategory/PDBx:chemical_conn_atom[@number='{replace(@atom_1,' +','%20')}']">
            <rdfs:label>chemical_conn_atomKeyref_1_1_0</rdfs:label>
          </PDBo:chemical_conn_atom>
        </PDBo:reference_to_chemical_conn_atom>
      </xsl2:if>
      <xsl2:if test="@atom_2!=''">
        <PDBo:reference_to_chemical_conn_atom>
          <PDBo:chemical_conn_atom rdf:about="{$base}/PDBx:datablock/PDBx:chemical_conn_atomCategory/PDBx:chemical_conn_atom[@number='{replace(@atom_2,' +','%20')}']">
            <rdfs:label>chemical_conn_atomKeyref_1_1_1</rdfs:label>
          </PDBo:chemical_conn_atom>
        </PDBo:reference_to_chemical_conn_atom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chemical_conn_bond>
    </PDBo:chemical_conn_bondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:chemical_formulaCategory/PDBx:chemical_formula">
    <PDBo:chemical_formulaCategory>
      <PDBo:chemical_formula rdf:about="{$base}/PDBx:datablock/PDBx:chemical_formulaCategory/PDBx:chemical_formula[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_4_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:chemical_formula>
    </PDBo:chemical_formulaCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:citationCategory/PDBx:citation">
    <PDBo:citationCategory>
      <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:citation>
    </PDBo:citationCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:citation_authorCategory/PDBx:citation_author">
    <PDBo:citation_authorCategory>
      <PDBo:citation_author rdf:about="{$base}/PDBx:datablock/PDBx:citation_authorCategory/PDBx:citation_author[@citation_id='{replace(@citation_id,' +','%20')}'%20and%20@name='{replace(@name,' +','%20')}'%20and%20@ordinal='{replace(@ordinal,' +','%20')}']">
      <xsl2:if test="@citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(@citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_0_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:citation_author>
    </PDBo:citation_authorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:citation_editorCategory/PDBx:citation_editor">
    <PDBo:citation_editorCategory>
      <PDBo:citation_editor rdf:about="{$base}/PDBx:datablock/PDBx:citation_editorCategory/PDBx:citation_editor[@citation_id='{replace(@citation_id,' +','%20')}'%20and%20@name='{replace(@name,' +','%20')}']">
      <xsl2:if test="@citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(@citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_1_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:citation_editor>
    </PDBo:citation_editorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:computingCategory/PDBx:computing">
    <PDBo:computingCategory>
      <PDBo:computing rdf:about="{$base}/PDBx:datablock/PDBx:computingCategory/PDBx:computing[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_5_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:computing>
    </PDBo:computingCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:databaseCategory/PDBx:database">
    <PDBo:databaseCategory>
      <PDBo:database rdf:about="{$base}/PDBx:datablock/PDBx:databaseCategory/PDBx:database[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_6_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database>
    </PDBo:databaseCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:database_2Category/PDBx:database_2">
    <PDBo:database_2Category>
      <PDBo:database_2 rdf:about="{$base}/PDBx:datablock/PDBx:database_2Category/PDBx:database_2[@database_code='{replace(@database_code,' +','%20')}'%20and%20@database_id='{replace(@database_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database_2>
    </PDBo:database_2Category>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:database_PDB_caveatCategory/PDBx:database_PDB_caveat">
    <PDBo:database_PDB_caveatCategory>
      <PDBo:database_PDB_caveat rdf:about="{$base}/PDBx:datablock/PDBx:database_PDB_caveatCategory/PDBx:database_PDB_caveat[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database_PDB_caveat>
    </PDBo:database_PDB_caveatCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:database_PDB_matrixCategory/PDBx:database_PDB_matrix">
    <PDBo:database_PDB_matrixCategory>
      <PDBo:database_PDB_matrix rdf:about="{$base}/PDBx:datablock/PDBx:database_PDB_matrixCategory/PDBx:database_PDB_matrix[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_7_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database_PDB_matrix>
    </PDBo:database_PDB_matrixCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:database_PDB_remarkCategory/PDBx:database_PDB_remark">
    <PDBo:database_PDB_remarkCategory>
      <PDBo:database_PDB_remark rdf:about="{$base}/PDBx:datablock/PDBx:database_PDB_remarkCategory/PDBx:database_PDB_remark[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database_PDB_remark>
    </PDBo:database_PDB_remarkCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:database_PDB_revCategory/PDBx:database_PDB_rev">
    <PDBo:database_PDB_revCategory>
      <PDBo:database_PDB_rev rdf:about="{$base}/PDBx:datablock/PDBx:database_PDB_revCategory/PDBx:database_PDB_rev[@num='{replace(@num,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database_PDB_rev>
    </PDBo:database_PDB_revCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:database_PDB_rev_recordCategory/PDBx:database_PDB_rev_record">
    <PDBo:database_PDB_rev_recordCategory>
      <PDBo:database_PDB_rev_record rdf:about="{$base}/PDBx:datablock/PDBx:database_PDB_rev_recordCategory/PDBx:database_PDB_rev_record[@rev_num='{replace(@rev_num,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}']">
      <xsl2:if test="@rev_num!=''">
        <PDBo:reference_to_database_PDB_rev>
          <PDBo:database_PDB_rev rdf:about="{$base}/PDBx:datablock/PDBx:database_PDB_revCategory/PDBx:database_PDB_rev[@num='{replace(@rev_num,' +','%20')}']">
            <rdfs:label>database_PDB_revKeyref_1_0_0</rdfs:label>
          </PDBo:database_PDB_rev>
        </PDBo:reference_to_database_PDB_rev>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database_PDB_rev_record>
    </PDBo:database_PDB_rev_recordCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:database_PDB_tvectCategory/PDBx:database_PDB_tvect">
    <PDBo:database_PDB_tvectCategory>
      <PDBo:database_PDB_tvect rdf:about="{$base}/PDBx:datablock/PDBx:database_PDB_tvectCategory/PDBx:database_PDB_tvect[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:database_PDB_tvect>
    </PDBo:database_PDB_tvectCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn">
    <PDBo:diffrnCategory>
      <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(PDBx:crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_0_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn>
    </PDBo:diffrnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_attenuatorCategory/PDBx:diffrn_attenuator">
    <PDBo:diffrn_attenuatorCategory>
      <PDBo:diffrn_attenuator rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_attenuatorCategory/PDBx:diffrn_attenuator[@code='{replace(@code,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_attenuator>
    </PDBo:diffrn_attenuatorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_detectorCategory/PDBx:diffrn_detector">
    <PDBo:diffrn_detectorCategory>
      <PDBo:diffrn_detector rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_detectorCategory/PDBx:diffrn_detector[@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_0_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_detector>
    </PDBo:diffrn_detectorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_measurementCategory/PDBx:diffrn_measurement">
    <PDBo:diffrn_measurementCategory>
      <PDBo:diffrn_measurement rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_measurementCategory/PDBx:diffrn_measurement[@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_1_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_measurement>
    </PDBo:diffrn_measurementCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_orient_matrixCategory/PDBx:diffrn_orient_matrix">
    <PDBo:diffrn_orient_matrixCategory>
      <PDBo:diffrn_orient_matrix rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_orient_matrixCategory/PDBx:diffrn_orient_matrix[@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_2_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_orient_matrix>
    </PDBo:diffrn_orient_matrixCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_orient_reflnCategory/PDBx:diffrn_orient_refln">
    <PDBo:diffrn_orient_reflnCategory>
      <PDBo:diffrn_orient_refln rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_orient_reflnCategory/PDBx:diffrn_orient_refln[@diffrn_id='{replace(@diffrn_id,' +','%20')}'%20and%20@index_h='{replace(@index_h,' +','%20')}'%20and%20@index_k='{replace(@index_k,' +','%20')}'%20and%20@index_l='{replace(@index_l,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_3_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_orient_refln>
    </PDBo:diffrn_orient_reflnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_radiationCategory/PDBx:diffrn_radiation">
    <PDBo:diffrn_radiationCategory>
      <PDBo:diffrn_radiation rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_radiationCategory/PDBx:diffrn_radiation[@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_4_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:if test="PDBx:wavelength_id!=''">
        <PDBo:reference_to_diffrn_radiation_wavelength>
          <PDBo:diffrn_radiation_wavelength rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_radiation_wavelengthCategory/PDBx:diffrn_radiation_wavelength[@id='{replace(PDBx:wavelength_id,' +','%20')}']">
            <rdfs:label>diffrn_radiation_wavelengthKeyref_1_0_0</rdfs:label>
          </PDBo:diffrn_radiation_wavelength>
        </PDBo:reference_to_diffrn_radiation_wavelength>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_radiation>
    </PDBo:diffrn_radiationCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_radiation_wavelengthCategory/PDBx:diffrn_radiation_wavelength">
    <PDBo:diffrn_radiation_wavelengthCategory>
      <PDBo:diffrn_radiation_wavelength rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_radiation_wavelengthCategory/PDBx:diffrn_radiation_wavelength[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_radiation_wavelength>
    </PDBo:diffrn_radiation_wavelengthCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_reflnCategory/PDBx:diffrn_refln">
    <PDBo:diffrn_reflnCategory>
      <PDBo:diffrn_refln rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_reflnCategory/PDBx:diffrn_refln[@diffrn_id='{replace(@diffrn_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_5_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:if test="PDBx:attenuator_code!=''">
        <PDBo:reference_to_diffrn_attenuator>
          <PDBo:diffrn_attenuator rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_attenuatorCategory/PDBx:diffrn_attenuator[@code='{replace(PDBx:attenuator_code,' +','%20')}']">
            <rdfs:label>diffrn_attenuatorKeyref_1_0_0</rdfs:label>
          </PDBo:diffrn_attenuator>
        </PDBo:reference_to_diffrn_attenuator>
      </xsl2:if>
      <xsl2:if test="PDBx:wavelength_id!=''">
        <PDBo:reference_to_diffrn_radiation_wavelength>
          <PDBo:diffrn_radiation_wavelength rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_radiation_wavelengthCategory/PDBx:diffrn_radiation_wavelength[@id='{replace(PDBx:wavelength_id,' +','%20')}']">
            <rdfs:label>diffrn_radiation_wavelengthKeyref_1_1_0</rdfs:label>
          </PDBo:diffrn_radiation_wavelength>
        </PDBo:reference_to_diffrn_radiation_wavelength>
      </xsl2:if>
      <xsl2:if test="PDBx:scale_group_code!=''">
        <PDBo:reference_to_diffrn_scale_group>
          <PDBo:diffrn_scale_group rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_scale_groupCategory/PDBx:diffrn_scale_group[@code='{replace(PDBx:scale_group_code,' +','%20')}']">
            <rdfs:label>diffrn_scale_groupKeyref_1_0_0</rdfs:label>
          </PDBo:diffrn_scale_group>
        </PDBo:reference_to_diffrn_scale_group>
      </xsl2:if>
      <xsl2:if test="PDBx:standard_code!=''">
        <PDBo:reference_to_diffrn_standard_refln>
          <PDBo:diffrn_standard_refln rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_standard_reflnCategory/PDBx:diffrn_standard_refln[@code='{replace(PDBx:standard_code,' +','%20')}']">
            <rdfs:label>diffrn_standard_reflnKeyref_1_0_0</rdfs:label>
          </PDBo:diffrn_standard_refln>
        </PDBo:reference_to_diffrn_standard_refln>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_refln>
    </PDBo:diffrn_reflnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_reflnsCategory/PDBx:diffrn_reflns">
    <PDBo:diffrn_reflnsCategory>
      <PDBo:diffrn_reflns rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_reflnsCategory/PDBx:diffrn_reflns[@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_6_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_reflns>
    </PDBo:diffrn_reflnsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_reflns_classCategory/PDBx:diffrn_reflns_class">
    <PDBo:diffrn_reflns_classCategory>
      <PDBo:diffrn_reflns_class rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_reflns_classCategory/PDBx:diffrn_reflns_class[@code='{replace(@code,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_reflns_class>
    </PDBo:diffrn_reflns_classCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_scale_groupCategory/PDBx:diffrn_scale_group">
    <PDBo:diffrn_scale_groupCategory>
      <PDBo:diffrn_scale_group rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_scale_groupCategory/PDBx:diffrn_scale_group[@code='{replace(@code,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_scale_group>
    </PDBo:diffrn_scale_groupCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_sourceCategory/PDBx:diffrn_source">
    <PDBo:diffrn_sourceCategory>
      <PDBo:diffrn_source rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_sourceCategory/PDBx:diffrn_source[@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_7_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_source>
    </PDBo:diffrn_sourceCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_standard_reflnCategory/PDBx:diffrn_standard_refln">
    <PDBo:diffrn_standard_reflnCategory>
      <PDBo:diffrn_standard_refln rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_standard_reflnCategory/PDBx:diffrn_standard_refln[@code='{replace(@code,' +','%20')}'%20and%20@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@code!=''">
        <rdfs:sameAs>
          <PDBo:diffrn_standard_refln rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_standard_reflnCategory/PDBx:diffrn_standard_refln[@code='{replace(@code,' +','%20')}']">
            <rdfs:label>diffrn_standard_reflnKey_1</rdfs:label>
          </PDBo:diffrn_standard_refln>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_8_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_standard_refln>
    </PDBo:diffrn_standard_reflnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:diffrn_standardsCategory/PDBx:diffrn_standards">
    <PDBo:diffrn_standardsCategory>
      <PDBo:diffrn_standards rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_standardsCategory/PDBx:diffrn_standards[@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_9_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:diffrn_standards>
    </PDBo:diffrn_standardsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_2d_crystal_entityCategory/PDBx:em_2d_crystal_entity">
    <PDBo:em_2d_crystal_entityCategory>
      <PDBo:em_2d_crystal_entity rdf:about="{$base}/PDBx:datablock/PDBx:em_2d_crystal_entityCategory/PDBx:em_2d_crystal_entity[@entity_assembly_id='{replace(@entity_assembly_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entity_assembly_id!=''">
        <PDBo:reference_to_em_entity_assembly>
          <PDBo:em_entity_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_entity_assemblyCategory/PDBx:em_entity_assembly[@id='{replace(@entity_assembly_id,' +','%20')}']">
            <rdfs:label>em_entity_assemblyKeyref_1_0_0</rdfs:label>
          </PDBo:em_entity_assembly>
        </PDBo:reference_to_em_entity_assembly>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_2d_crystal_entity>
    </PDBo:em_2d_crystal_entityCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_2d_crystal_growCategory/PDBx:em_2d_crystal_grow">
    <PDBo:em_2d_crystal_growCategory>
      <PDBo:em_2d_crystal_grow rdf:about="{$base}/PDBx:datablock/PDBx:em_2d_crystal_growCategory/PDBx:em_2d_crystal_grow[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_2_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:buffer_id!=''">
        <PDBo:reference_to_em_buffer>
          <PDBo:em_buffer rdf:about="{$base}/PDBx:datablock/PDBx:em_bufferCategory/PDBx:em_buffer[@id='{replace(PDBx:buffer_id,' +','%20')}']">
            <rdfs:label>em_bufferKeyref_1_0_0</rdfs:label>
          </PDBo:em_buffer>
        </PDBo:reference_to_em_buffer>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_2d_crystal_grow>
    </PDBo:em_2d_crystal_growCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_2d_projection_selectionCategory/PDBx:em_2d_projection_selection">
    <PDBo:em_2d_projection_selectionCategory>
      <PDBo:em_2d_projection_selection rdf:about="{$base}/PDBx:datablock/PDBx:em_2d_projection_selectionCategory/PDBx:em_2d_projection_selection[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_3_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_8_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_2d_projection_selection>
    </PDBo:em_2d_projection_selectionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_3d_fittingCategory/PDBx:em_3d_fitting">
    <PDBo:em_3d_fittingCategory>
      <PDBo:em_3d_fitting rdf:about="{$base}/PDBx:datablock/PDBx:em_3d_fittingCategory/PDBx:em_3d_fitting[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:em_3d_fitting rdf:about="{$base}/PDBx:datablock/PDBx:em_3d_fittingCategory/PDBx:em_3d_fitting[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>em_3d_fittingKey_1</rdfs:label>
          </PDBo:em_3d_fitting>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_9_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_3d_fitting>
    </PDBo:em_3d_fittingCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_3d_fitting_listCategory/PDBx:em_3d_fitting_list">
    <PDBo:em_3d_fitting_listCategory>
      <PDBo:em_3d_fitting_list rdf:about="{$base}/PDBx:datablock/PDBx:em_3d_fitting_listCategory/PDBx:em_3d_fitting_list[@_3d_fitting_id='{replace(@_3d_fitting_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@_3d_fitting_id!=''">
        <PDBo:reference_to_em_3d_fitting>
          <PDBo:em_3d_fitting rdf:about="{$base}/PDBx:datablock/PDBx:em_3d_fittingCategory/PDBx:em_3d_fitting[@id='{replace(@_3d_fitting_id,' +','%20')}']">
            <rdfs:label>em_3d_fittingKeyref_1_0_0</rdfs:label>
          </PDBo:em_3d_fitting>
        </PDBo:reference_to_em_3d_fitting>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_3d_fitting_list>
    </PDBo:em_3d_fitting_listCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_3d_reconstructionCategory/PDBx:em_3d_reconstruction">
    <PDBo:em_3d_reconstructionCategory>
      <PDBo:em_3d_reconstruction rdf:about="{$base}/PDBx:datablock/PDBx:em_3d_reconstructionCategory/PDBx:em_3d_reconstruction[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_4_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_10_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_3d_reconstruction>
    </PDBo:em_3d_reconstructionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_assemblyCategory/PDBx:em_assembly">
    <PDBo:em_assemblyCategory>
      <PDBo:em_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_assemblyCategory/PDBx:em_assembly[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:em_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_assemblyCategory/PDBx:em_assembly[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>em_assemblyKey_1</rdfs:label>
          </PDBo:em_assembly>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_11_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_assembly>
    </PDBo:em_assemblyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_bufferCategory/PDBx:em_buffer">
    <PDBo:em_bufferCategory>
      <PDBo:em_buffer rdf:about="{$base}/PDBx:datablock/PDBx:em_bufferCategory/PDBx:em_buffer[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_buffer>
    </PDBo:em_bufferCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_buffer_componentsCategory/PDBx:em_buffer_components">
    <PDBo:em_buffer_componentsCategory>
      <PDBo:em_buffer_components rdf:about="{$base}/PDBx:datablock/PDBx:em_buffer_componentsCategory/PDBx:em_buffer_components[@buffer_id='{replace(@buffer_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@buffer_id!=''">
        <PDBo:reference_to_em_buffer>
          <PDBo:em_buffer rdf:about="{$base}/PDBx:datablock/PDBx:em_bufferCategory/PDBx:em_buffer[@id='{replace(@buffer_id,' +','%20')}']">
            <rdfs:label>em_bufferKeyref_1_1_0</rdfs:label>
          </PDBo:em_buffer>
        </PDBo:reference_to_em_buffer>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_buffer_components>
    </PDBo:em_buffer_componentsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_detectorCategory/PDBx:em_detector">
    <PDBo:em_detectorCategory>
      <PDBo:em_detector rdf:about="{$base}/PDBx:datablock/PDBx:em_detectorCategory/PDBx:em_detector[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:em_detector rdf:about="{$base}/PDBx:datablock/PDBx:em_detectorCategory/PDBx:em_detector[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>em_detectorKey_1</rdfs:label>
          </PDBo:em_detector>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_12_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_detector>
    </PDBo:em_detectorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_electron_diffractionCategory/PDBx:em_electron_diffraction">
    <PDBo:em_electron_diffractionCategory>
      <PDBo:em_electron_diffraction rdf:about="{$base}/PDBx:datablock/PDBx:em_electron_diffractionCategory/PDBx:em_electron_diffraction[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_13_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_electron_diffraction>
    </PDBo:em_electron_diffractionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_electron_diffraction_patternCategory/PDBx:em_electron_diffraction_pattern">
    <PDBo:em_electron_diffraction_patternCategory>
      <PDBo:em_electron_diffraction_pattern rdf:about="{$base}/PDBx:datablock/PDBx:em_electron_diffraction_patternCategory/PDBx:em_electron_diffraction_pattern[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_14_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_electron_diffraction_pattern>
    </PDBo:em_electron_diffraction_patternCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_electron_diffraction_phaseCategory/PDBx:em_electron_diffraction_phase">
    <PDBo:em_electron_diffraction_phaseCategory>
      <PDBo:em_electron_diffraction_phase rdf:about="{$base}/PDBx:datablock/PDBx:em_electron_diffraction_phaseCategory/PDBx:em_electron_diffraction_phase[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_15_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_electron_diffraction_phase>
    </PDBo:em_electron_diffraction_phaseCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_entity_assemblyCategory/PDBx:em_entity_assembly">
    <PDBo:em_entity_assemblyCategory>
      <PDBo:em_entity_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_entity_assemblyCategory/PDBx:em_entity_assembly[@assembly_id='{replace(@assembly_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:em_entity_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_entity_assemblyCategory/PDBx:em_entity_assembly[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>em_entity_assemblyKey_1</rdfs:label>
          </PDBo:em_entity_assembly>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@assembly_id!=''">
        <PDBo:reference_to_em_assembly>
          <PDBo:em_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_assemblyCategory/PDBx:em_assembly[@id='{replace(@assembly_id,' +','%20')}']">
            <rdfs:label>em_assemblyKeyref_1_0_0</rdfs:label>
          </PDBo:em_assembly>
        </PDBo:reference_to_em_assembly>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_entity_assembly>
    </PDBo:em_entity_assemblyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_entity_assembly_listCategory/PDBx:em_entity_assembly_list">
    <PDBo:em_entity_assembly_listCategory>
      <PDBo:em_entity_assembly_list rdf:about="{$base}/PDBx:datablock/PDBx:em_entity_assembly_listCategory/PDBx:em_entity_assembly_list[@entity_assembly_id='{replace(@entity_assembly_id,' +','%20')}'%20and%20@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_1_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_entity_assembly_list>
    </PDBo:em_entity_assembly_listCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_euler_angle_distributionCategory/PDBx:em_euler_angle_distribution">
    <PDBo:em_euler_angle_distributionCategory>
      <PDBo:em_euler_angle_distribution rdf:about="{$base}/PDBx:datablock/PDBx:em_euler_angle_distributionCategory/PDBx:em_euler_angle_distribution[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_16_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_euler_angle_distribution>
    </PDBo:em_euler_angle_distributionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_experimentCategory/PDBx:em_experiment">
    <PDBo:em_experimentCategory>
      <PDBo:em_experiment rdf:about="{$base}/PDBx:datablock/PDBx:em_experimentCategory/PDBx:em_experiment[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_17_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_experiment>
    </PDBo:em_experimentCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_helical_entityCategory/PDBx:em_helical_entity">
    <PDBo:em_helical_entityCategory>
      <PDBo:em_helical_entity rdf:about="{$base}/PDBx:datablock/PDBx:em_helical_entityCategory/PDBx:em_helical_entity[@entity_assembly_id='{replace(@entity_assembly_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entity_assembly_id!=''">
        <PDBo:reference_to_em_entity_assembly>
          <PDBo:em_entity_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_entity_assemblyCategory/PDBx:em_entity_assembly[@id='{replace(@entity_assembly_id,' +','%20')}']">
            <rdfs:label>em_entity_assemblyKeyref_1_1_0</rdfs:label>
          </PDBo:em_entity_assembly>
        </PDBo:reference_to_em_entity_assembly>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_helical_entity>
    </PDBo:em_helical_entityCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_icos_virus_shellsCategory/PDBx:em_icos_virus_shells">
    <PDBo:em_icos_virus_shellsCategory>
      <PDBo:em_icos_virus_shells rdf:about="{$base}/PDBx:datablock/PDBx:em_icos_virus_shellsCategory/PDBx:em_icos_virus_shells[@id='{replace(@id,' +','%20')}'%20and%20@virus_entity_id='{replace(@virus_entity_id,' +','%20')}']">
      <xsl2:if test="@virus_entity_id!=''">
        <PDBo:reference_to_em_virus_entity>
          <PDBo:em_virus_entity rdf:about="{$base}/PDBx:datablock/PDBx:em_virus_entityCategory/PDBx:em_virus_entity[@id='{replace(@virus_entity_id,' +','%20')}']">
            <rdfs:label>em_virus_entityKeyref_1_0_0</rdfs:label>
          </PDBo:em_virus_entity>
        </PDBo:reference_to_em_virus_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_icos_virus_shells>
    </PDBo:em_icos_virus_shellsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_image_scansCategory/PDBx:em_image_scans">
    <PDBo:em_image_scansCategory>
      <PDBo:em_image_scans rdf:about="{$base}/PDBx:datablock/PDBx:em_image_scansCategory/PDBx:em_image_scans[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:em_image_scans rdf:about="{$base}/PDBx:datablock/PDBx:em_image_scansCategory/PDBx:em_image_scans[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>em_image_scansKey_1</rdfs:label>
          </PDBo:em_image_scans>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_5_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_18_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_image_scans>
    </PDBo:em_image_scansCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_imagingCategory/PDBx:em_imaging">
    <PDBo:em_imagingCategory>
      <PDBo:em_imaging rdf:about="{$base}/PDBx:datablock/PDBx:em_imagingCategory/PDBx:em_imaging[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_6_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:detector_id!=''">
        <PDBo:reference_to_em_detector>
          <PDBo:em_detector rdf:about="{$base}/PDBx:datablock/PDBx:em_detectorCategory/PDBx:em_detector[@id='{replace(PDBx:detector_id,' +','%20')}']">
            <rdfs:label>em_detectorKeyref_1_0_0</rdfs:label>
          </PDBo:em_detector>
        </PDBo:reference_to_em_detector>
      </xsl2:if>
      <xsl2:if test="PDBx:scans_id!=''">
        <PDBo:reference_to_em_image_scans>
          <PDBo:em_image_scans rdf:about="{$base}/PDBx:datablock/PDBx:em_image_scansCategory/PDBx:em_image_scans[@id='{replace(PDBx:scans_id,' +','%20')}']">
            <rdfs:label>em_image_scansKeyref_1_0_0</rdfs:label>
          </PDBo:em_image_scans>
        </PDBo:reference_to_em_image_scans>
      </xsl2:if>
      <xsl2:if test="PDBx:sample_support_id!=''">
        <PDBo:reference_to_em_sample_support>
          <PDBo:em_sample_support rdf:about="{$base}/PDBx:datablock/PDBx:em_sample_supportCategory/PDBx:em_sample_support[@id='{replace(PDBx:sample_support_id,' +','%20')}']">
            <rdfs:label>em_sample_supportKeyref_1_0_0</rdfs:label>
          </PDBo:em_sample_support>
        </PDBo:reference_to_em_sample_support>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_19_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_imaging>
    </PDBo:em_imagingCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_sample_preparationCategory/PDBx:em_sample_preparation">
    <PDBo:em_sample_preparationCategory>
      <PDBo:em_sample_preparation rdf:about="{$base}/PDBx:datablock/PDBx:em_sample_preparationCategory/PDBx:em_sample_preparation[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:em_sample_preparation rdf:about="{$base}/PDBx:datablock/PDBx:em_sample_preparationCategory/PDBx:em_sample_preparation[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>em_sample_preparationKey_1</rdfs:label>
          </PDBo:em_sample_preparation>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="PDBx:buffer_id!=''">
        <PDBo:reference_to_em_buffer>
          <PDBo:em_buffer rdf:about="{$base}/PDBx:datablock/PDBx:em_bufferCategory/PDBx:em_buffer[@id='{replace(PDBx:buffer_id,' +','%20')}']">
            <rdfs:label>em_bufferKeyref_1_2_0</rdfs:label>
          </PDBo:em_buffer>
        </PDBo:reference_to_em_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:entity_assembly_id!=''">
        <PDBo:reference_to_em_entity_assembly>
          <PDBo:em_entity_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_entity_assemblyCategory/PDBx:em_entity_assembly[@id='{replace(PDBx:entity_assembly_id,' +','%20')}']">
            <rdfs:label>em_entity_assemblyKeyref_1_2_0</rdfs:label>
          </PDBo:em_entity_assembly>
        </PDBo:reference_to_em_entity_assembly>
      </xsl2:if>
      <xsl2:if test="PDBx:support_id!=''">
        <PDBo:reference_to_em_sample_support>
          <PDBo:em_sample_support rdf:about="{$base}/PDBx:datablock/PDBx:em_sample_supportCategory/PDBx:em_sample_support[@id='{replace(PDBx:support_id,' +','%20')}']">
            <rdfs:label>em_sample_supportKeyref_1_1_0</rdfs:label>
          </PDBo:em_sample_support>
        </PDBo:reference_to_em_sample_support>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_20_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_sample_preparation>
    </PDBo:em_sample_preparationCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_sample_supportCategory/PDBx:em_sample_support">
    <PDBo:em_sample_supportCategory>
      <PDBo:em_sample_support rdf:about="{$base}/PDBx:datablock/PDBx:em_sample_supportCategory/PDBx:em_sample_support[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_7_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_sample_support>
    </PDBo:em_sample_supportCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_single_particle_entityCategory/PDBx:em_single_particle_entity">
    <PDBo:em_single_particle_entityCategory>
      <PDBo:em_single_particle_entity rdf:about="{$base}/PDBx:datablock/PDBx:em_single_particle_entityCategory/PDBx:em_single_particle_entity[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_21_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_single_particle_entity>
    </PDBo:em_single_particle_entityCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_virus_entityCategory/PDBx:em_virus_entity">
    <PDBo:em_virus_entityCategory>
      <PDBo:em_virus_entity rdf:about="{$base}/PDBx:datablock/PDBx:em_virus_entityCategory/PDBx:em_virus_entity[@entity_assembly_id='{replace(@entity_assembly_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:em_virus_entity rdf:about="{$base}/PDBx:datablock/PDBx:em_virus_entityCategory/PDBx:em_virus_entity[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>em_virus_entityKey_1</rdfs:label>
          </PDBo:em_virus_entity>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entity_assembly_id!=''">
        <PDBo:reference_to_em_entity_assembly>
          <PDBo:em_entity_assembly rdf:about="{$base}/PDBx:datablock/PDBx:em_entity_assemblyCategory/PDBx:em_entity_assembly[@id='{replace(@entity_assembly_id,' +','%20')}']">
            <rdfs:label>em_entity_assemblyKeyref_1_3_0</rdfs:label>
          </PDBo:em_entity_assembly>
        </PDBo:reference_to_em_entity_assembly>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_virus_entity>
    </PDBo:em_virus_entityCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:em_vitrificationCategory/PDBx:em_vitrification">
    <PDBo:em_vitrificationCategory>
      <PDBo:em_vitrification rdf:about="{$base}/PDBx:datablock/PDBx:em_vitrificationCategory/PDBx:em_vitrification[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_8_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:sample_preparation_id!=''">
        <PDBo:reference_to_em_sample_preparation>
          <PDBo:em_sample_preparation rdf:about="{$base}/PDBx:datablock/PDBx:em_sample_preparationCategory/PDBx:em_sample_preparation[@id='{replace(PDBx:sample_preparation_id,' +','%20')}']">
            <rdfs:label>em_sample_preparationKeyref_1_0_0</rdfs:label>
          </PDBo:em_sample_preparation>
        </PDBo:reference_to_em_sample_preparation>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_22_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:em_vitrification>
    </PDBo:em_vitrificationCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entityCategory/PDBx:entity">
    <PDBo:entityCategory>
      <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_parent_entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:pdbx_parent_entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_2_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity>
    </PDBo:entityCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_keywordsCategory/PDBx:entity_keywords">
    <PDBo:entity_keywordsCategory>
      <PDBo:entity_keywords rdf:about="{$base}/PDBx:datablock/PDBx:entity_keywordsCategory/PDBx:entity_keywords[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_3_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_keywords>
    </PDBo:entity_keywordsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_linkCategory/PDBx:entity_link">
    <PDBo:entity_linkCategory>
      <PDBo:entity_link rdf:about="{$base}/PDBx:datablock/PDBx:entity_linkCategory/PDBx:entity_link[@link_id='{replace(@link_id,' +','%20')}']">
      <xsl2:if test="@link_id!=''">
        <PDBo:reference_to_chem_link>
          <PDBo:chem_link rdf:about="{$base}/PDBx:datablock/PDBx:chem_linkCategory/PDBx:chem_link[@id='{replace(@link_id,' +','%20')}']">
            <rdfs:label>chem_linkKeyref_1_6_0</rdfs:label>
          </PDBo:chem_link>
        </PDBo:reference_to_chem_link>
      </xsl2:if>
      <xsl2:if test="PDBx:entity_id_1!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:entity_id_1,' +','%20')}']">
            <rdfs:label>entityKeyref_1_4_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="PDBx:entity_id_2!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:entity_id_2,' +','%20')}']">
            <rdfs:label>entityKeyref_1_4_1</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="PDBx:entity_seq_num_1!=''">
        <PDBo:reference_to_entity_poly_seq>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@num='{replace(PDBx:entity_seq_num_1,' +','%20')}']">
            <rdfs:label>entity_poly_seqKeyref_1_1_0</rdfs:label>
          </PDBo:entity_poly_seq>
        </PDBo:reference_to_entity_poly_seq>
      </xsl2:if>
      <xsl2:if test="PDBx:entity_seq_num_2!=''">
        <PDBo:reference_to_entity_poly_seq>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@num='{replace(PDBx:entity_seq_num_2,' +','%20')}']">
            <rdfs:label>entity_poly_seqKeyref_1_1_1</rdfs:label>
          </PDBo:entity_poly_seq>
        </PDBo:reference_to_entity_poly_seq>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_link>
    </PDBo:entity_linkCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_name_comCategory/PDBx:entity_name_com">
    <PDBo:entity_name_comCategory>
      <PDBo:entity_name_com rdf:about="{$base}/PDBx:datablock/PDBx:entity_name_comCategory/PDBx:entity_name_com[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_5_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_name_com>
    </PDBo:entity_name_comCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_name_sysCategory/PDBx:entity_name_sys">
    <PDBo:entity_name_sysCategory>
      <PDBo:entity_name_sys rdf:about="{$base}/PDBx:datablock/PDBx:entity_name_sysCategory/PDBx:entity_name_sys[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_6_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_name_sys>
    </PDBo:entity_name_sysCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_polyCategory/PDBx:entity_poly">
    <PDBo:entity_polyCategory>
      <PDBo:entity_poly rdf:about="{$base}/PDBx:datablock/PDBx:entity_polyCategory/PDBx:entity_poly[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_7_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_poly>
    </PDBo:entity_polyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq">
    <PDBo:entity_poly_seqCategory>
      <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@mon_id='{replace(@mon_id,' +','%20')}'%20and%20@num='{replace(@num,' +','%20')}']">
      <xsl2:if test="@num!=''">
        <rdfs:sameAs>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@num='{replace(@num,' +','%20')}']">
            <rdfs:label>entity_poly_seqKey_1</rdfs:label>
          </PDBo:entity_poly_seq>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entity_id!='' and @hetero!='' and @mon_id!='' and @num!=''">
        <rdfs:sameAs>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@hetero='{replace(@hetero,' +','%20')}'%20and%20@mon_id='{replace(@mon_id,' +','%20')}'%20and%20@num='{replace(@num,' +','%20')}']">
            <rdfs:label>entity_poly_seqKey_2</rdfs:label>
          </PDBo:entity_poly_seq>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@mon_id!='' and @num!=''">
        <rdfs:sameAs>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@mon_id='{replace(@mon_id,' +','%20')}'%20and%20@num='{replace(@num,' +','%20')}']">
            <rdfs:label>entity_poly_seqKey_3</rdfs:label>
          </PDBo:entity_poly_seq>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@mon_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@mon_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_6_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity_poly>
          <PDBo:entity_poly rdf:about="{$base}/PDBx:datablock/PDBx:entity_polyCategory/PDBx:entity_poly[@entity_id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entity_polyKeyref_1_0_0</rdfs:label>
          </PDBo:entity_poly>
        </PDBo:reference_to_entity_poly>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_poly_seq>
    </PDBo:entity_poly_seqCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_src_genCategory/PDBx:entity_src_gen">
    <PDBo:entity_src_genCategory>
      <PDBo:entity_src_gen rdf:about="{$base}/PDBx:datablock/PDBx:entity_src_genCategory/PDBx:entity_src_gen[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_8_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="PDBx:start_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:start_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_src_gen>
    </PDBo:entity_src_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entity_src_natCategory/PDBx:entity_src_nat">
    <PDBo:entity_src_natCategory>
      <PDBo:entity_src_nat rdf:about="{$base}/PDBx:datablock/PDBx:entity_src_natCategory/PDBx:entity_src_nat[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_9_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entity_src_nat>
    </PDBo:entity_src_natCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entryCategory/PDBx:entry">
    <PDBo:entryCategory>
      <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entry>
    </PDBo:entryCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:entry_linkCategory/PDBx:entry_link">
    <PDBo:entry_linkCategory>
      <PDBo:entry_link rdf:about="{$base}/PDBx:datablock/PDBx:entry_linkCategory/PDBx:entry_link[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_23_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:entry_link>
    </PDBo:entry_linkCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:exptlCategory/PDBx:exptl">
    <PDBo:exptlCategory>
      <PDBo:exptl rdf:about="{$base}/PDBx:datablock/PDBx:exptlCategory/PDBx:exptl[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@method='{replace(@method,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_24_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:exptl>
    </PDBo:exptlCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal">
    <PDBo:exptl_crystalCategory>
      <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:exptl_crystal>
    </PDBo:exptl_crystalCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:exptl_crystal_faceCategory/PDBx:exptl_crystal_face">
    <PDBo:exptl_crystal_faceCategory>
      <PDBo:exptl_crystal_face rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystal_faceCategory/PDBx:exptl_crystal_face[@crystal_id='{replace(@crystal_id,' +','%20')}'%20and%20@index_h='{replace(@index_h,' +','%20')}'%20and%20@index_k='{replace(@index_k,' +','%20')}'%20and%20@index_l='{replace(@index_l,' +','%20')}']">
      <xsl2:if test="@crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(@crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_1_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:exptl_crystal_face>
    </PDBo:exptl_crystal_faceCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:exptl_crystal_growCategory/PDBx:exptl_crystal_grow">
    <PDBo:exptl_crystal_growCategory>
      <PDBo:exptl_crystal_grow rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystal_growCategory/PDBx:exptl_crystal_grow[@crystal_id='{replace(@crystal_id,' +','%20')}']">
      <xsl2:if test="@crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(@crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_2_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:exptl_crystal_grow>
    </PDBo:exptl_crystal_growCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:exptl_crystal_grow_compCategory/PDBx:exptl_crystal_grow_comp">
    <PDBo:exptl_crystal_grow_compCategory>
      <PDBo:exptl_crystal_grow_comp rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystal_grow_compCategory/PDBx:exptl_crystal_grow_comp[@crystal_id='{replace(@crystal_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(@crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_3_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:exptl_crystal_grow_comp>
    </PDBo:exptl_crystal_grow_compCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:geomCategory/PDBx:geom">
    <PDBo:geomCategory>
      <PDBo:geom rdf:about="{$base}/PDBx:datablock/PDBx:geomCategory/PDBx:geom[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_25_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:geom>
    </PDBo:geomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:geom_angleCategory/PDBx:geom_angle">
    <PDBo:geom_angleCategory>
      <PDBo:geom_angle rdf:about="{$base}/PDBx:datablock/PDBx:geom_angleCategory/PDBx:geom_angle[@atom_site_id_1='{replace(@atom_site_id_1,' +','%20')}'%20and%20@atom_site_id_2='{replace(@atom_site_id_2,' +','%20')}'%20and%20@atom_site_id_3='{replace(@atom_site_id_3,' +','%20')}'%20and%20@site_symmetry_1='{replace(@site_symmetry_1,' +','%20')}'%20and%20@site_symmetry_2='{replace(@site_symmetry_2,' +','%20')}'%20and%20@site_symmetry_3='{replace(@site_symmetry_3,' +','%20')}']">
      <xsl2:if test="PDBx:atom_site_auth_asym_id_1!='' and PDBx:atom_site_auth_atom_id_1!='' and PDBx:atom_site_auth_comp_id_1!='' and PDBx:atom_site_auth_seq_id_1!='' and @atom_site_id_1!='' and PDBx:atom_site_label_alt_id_1!='' and PDBx:atom_site_label_asym_id_1!='' and PDBx:atom_site_label_atom_id_1!='' and PDBx:atom_site_label_comp_id_1!='' and PDBx:atom_site_label_seq_id_1!='' and PDBx:pdbx_PDB_model_num!='' and PDBx:pdbx_atom_site_PDB_ins_code_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_1,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_1,' +','%20')}'%20and%20@id='{replace(@atom_site_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_1,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_1,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_1,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_1,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_PDB_model_num,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:pdbx_atom_site_PDB_ins_code_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_3_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_2!='' and PDBx:atom_site_auth_atom_id_2!='' and PDBx:atom_site_auth_comp_id_2!='' and PDBx:atom_site_auth_seq_id_2!='' and @atom_site_id_2!='' and PDBx:atom_site_label_alt_id_2!='' and PDBx:atom_site_label_asym_id_2!='' and PDBx:atom_site_label_atom_id_2!='' and PDBx:atom_site_label_comp_id_2!='' and PDBx:atom_site_label_seq_id_2!='' and PDBx:pdbx_atom_site_PDB_ins_code_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_2,' +','%20')}'%20and%20@id='{replace(@atom_site_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_2,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_atom_site_PDB_ins_code_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_4_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_3!='' and PDBx:atom_site_auth_atom_id_3!='' and PDBx:atom_site_auth_comp_id_3!='' and PDBx:atom_site_auth_seq_id_3!='' and @atom_site_id_3!='' and PDBx:atom_site_label_alt_id_3!='' and PDBx:atom_site_label_asym_id_3!='' and PDBx:atom_site_label_atom_id_3!='' and PDBx:atom_site_label_comp_id_3!='' and PDBx:atom_site_label_seq_id_3!='' and PDBx:pdbx_atom_site_PDB_ins_code_3!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_3,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_3,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_3,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_3,' +','%20')}'%20and%20@id='{replace(@atom_site_id_3,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_3,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_3,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_3,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_3,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_3,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_atom_site_PDB_ins_code_3,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_4_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:geom_angle>
    </PDBo:geom_angleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:geom_bondCategory/PDBx:geom_bond">
    <PDBo:geom_bondCategory>
      <PDBo:geom_bond rdf:about="{$base}/PDBx:datablock/PDBx:geom_bondCategory/PDBx:geom_bond[@atom_site_id_1='{replace(@atom_site_id_1,' +','%20')}'%20and%20@atom_site_id_2='{replace(@atom_site_id_2,' +','%20')}'%20and%20@site_symmetry_1='{replace(@site_symmetry_1,' +','%20')}'%20and%20@site_symmetry_2='{replace(@site_symmetry_2,' +','%20')}']">
      <xsl2:if test="PDBx:atom_site_auth_asym_id_1!='' and PDBx:atom_site_auth_atom_id_1!='' and PDBx:atom_site_auth_comp_id_1!='' and PDBx:atom_site_auth_seq_id_1!='' and @atom_site_id_1!='' and PDBx:atom_site_label_alt_id_1!='' and PDBx:atom_site_label_asym_id_1!='' and PDBx:atom_site_label_atom_id_1!='' and PDBx:atom_site_label_comp_id_1!='' and PDBx:atom_site_label_seq_id_1!='' and PDBx:pdbx_PDB_model_num!='' and PDBx:pdbx_atom_site_PDB_ins_code_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_1,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_1,' +','%20')}'%20and%20@id='{replace(@atom_site_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_1,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_1,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_1,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_1,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_PDB_model_num,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:pdbx_atom_site_PDB_ins_code_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_3_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_2!='' and PDBx:atom_site_auth_atom_id_2!='' and PDBx:atom_site_auth_comp_id_2!='' and PDBx:atom_site_auth_seq_id_2!='' and @atom_site_id_2!='' and PDBx:atom_site_label_alt_id_2!='' and PDBx:atom_site_label_asym_id_2!='' and PDBx:atom_site_label_atom_id_2!='' and PDBx:atom_site_label_comp_id_2!='' and PDBx:atom_site_label_seq_id_2!='' and PDBx:pdbx_atom_site_PDB_ins_code_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_2,' +','%20')}'%20and%20@id='{replace(@atom_site_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_2,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_atom_site_PDB_ins_code_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_4_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:geom_bond>
    </PDBo:geom_bondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:geom_contactCategory/PDBx:geom_contact">
    <PDBo:geom_contactCategory>
      <PDBo:geom_contact rdf:about="{$base}/PDBx:datablock/PDBx:geom_contactCategory/PDBx:geom_contact[@atom_site_id_1='{replace(@atom_site_id_1,' +','%20')}'%20and%20@atom_site_id_2='{replace(@atom_site_id_2,' +','%20')}'%20and%20@site_symmetry_1='{replace(@site_symmetry_1,' +','%20')}'%20and%20@site_symmetry_2='{replace(@site_symmetry_2,' +','%20')}']">
      <xsl2:if test="PDBx:atom_site_auth_asym_id_1!='' and PDBx:atom_site_auth_atom_id_1!='' and PDBx:atom_site_auth_comp_id_1!='' and PDBx:atom_site_auth_seq_id_1!='' and @atom_site_id_1!='' and PDBx:atom_site_label_alt_id_1!='' and PDBx:atom_site_label_asym_id_1!='' and PDBx:atom_site_label_atom_id_1!='' and PDBx:atom_site_label_comp_id_1!='' and PDBx:atom_site_label_seq_id_1!='' and PDBx:pdbx_PDB_model_num!='' and PDBx:pdbx_atom_site_PDB_ins_code_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_1,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_1,' +','%20')}'%20and%20@id='{replace(@atom_site_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_1,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_1,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_1,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_1,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_PDB_model_num,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:pdbx_atom_site_PDB_ins_code_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_3_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_2!='' and PDBx:atom_site_auth_atom_id_2!='' and PDBx:atom_site_auth_comp_id_2!='' and PDBx:atom_site_auth_seq_id_2!='' and @atom_site_id_2!='' and PDBx:atom_site_label_alt_id_2!='' and PDBx:atom_site_label_asym_id_2!='' and PDBx:atom_site_label_atom_id_2!='' and PDBx:atom_site_label_comp_id_2!='' and PDBx:atom_site_label_seq_id_2!='' and PDBx:pdbx_atom_site_PDB_ins_code_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_2,' +','%20')}'%20and%20@id='{replace(@atom_site_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_2,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_atom_site_PDB_ins_code_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_4_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:geom_contact>
    </PDBo:geom_contactCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:geom_hbondCategory/PDBx:geom_hbond">
    <PDBo:geom_hbondCategory>
      <PDBo:geom_hbond rdf:about="{$base}/PDBx:datablock/PDBx:geom_hbondCategory/PDBx:geom_hbond[@atom_site_id_A='{replace(@atom_site_id_A,' +','%20')}'%20and%20@atom_site_id_D='{replace(@atom_site_id_D,' +','%20')}'%20and%20@atom_site_id_H='{replace(@atom_site_id_H,' +','%20')}'%20and%20@site_symmetry_A='{replace(@site_symmetry_A,' +','%20')}'%20and%20@site_symmetry_D='{replace(@site_symmetry_D,' +','%20')}'%20and%20@site_symmetry_H='{replace(@site_symmetry_H,' +','%20')}']">
      <xsl2:if test="PDBx:atom_site_auth_asym_id_A!='' and PDBx:atom_site_auth_atom_id_A!='' and PDBx:atom_site_auth_comp_id_A!='' and PDBx:atom_site_auth_seq_id_A!='' and @atom_site_id_A!='' and PDBx:atom_site_label_alt_id_A!='' and PDBx:atom_site_label_asym_id_A!='' and PDBx:atom_site_label_atom_id_A!='' and PDBx:atom_site_label_comp_id_A!='' and PDBx:atom_site_label_seq_id_A!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_A,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_A,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_A,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_A,' +','%20')}'%20and%20@id='{replace(@atom_site_id_A,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_A,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_A,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_A,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_A,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_A,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_5_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_D!='' and PDBx:atom_site_auth_atom_id_D!='' and PDBx:atom_site_auth_comp_id_D!='' and PDBx:atom_site_auth_seq_id_D!='' and @atom_site_id_D!='' and PDBx:atom_site_label_alt_id_D!='' and PDBx:atom_site_label_asym_id_D!='' and PDBx:atom_site_label_atom_id_D!='' and PDBx:atom_site_label_comp_id_D!='' and PDBx:atom_site_label_seq_id_D!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_D,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_D,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_D,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_D,' +','%20')}'%20and%20@id='{replace(@atom_site_id_D,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_D,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_D,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_D,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_D,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_D,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_5_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_H!='' and PDBx:atom_site_auth_atom_id_H!='' and PDBx:atom_site_auth_comp_id_H!='' and PDBx:atom_site_auth_seq_id_H!='' and @atom_site_id_H!='' and PDBx:atom_site_label_alt_id_H!='' and PDBx:atom_site_label_asym_id_H!='' and PDBx:atom_site_label_atom_id_H!='' and PDBx:atom_site_label_comp_id_H!='' and PDBx:atom_site_label_seq_id_H!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_H,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_H,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_H,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_H,' +','%20')}'%20and%20@id='{replace(@atom_site_id_H,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_H,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_H,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_H,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_H,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_H,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_5_0_2</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:geom_hbond>
    </PDBo:geom_hbondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:geom_torsionCategory/PDBx:geom_torsion">
    <PDBo:geom_torsionCategory>
      <PDBo:geom_torsion rdf:about="{$base}/PDBx:datablock/PDBx:geom_torsionCategory/PDBx:geom_torsion[@atom_site_id_1='{replace(@atom_site_id_1,' +','%20')}'%20and%20@atom_site_id_2='{replace(@atom_site_id_2,' +','%20')}'%20and%20@atom_site_id_3='{replace(@atom_site_id_3,' +','%20')}'%20and%20@atom_site_id_4='{replace(@atom_site_id_4,' +','%20')}'%20and%20@site_symmetry_1='{replace(@site_symmetry_1,' +','%20')}'%20and%20@site_symmetry_2='{replace(@site_symmetry_2,' +','%20')}'%20and%20@site_symmetry_3='{replace(@site_symmetry_3,' +','%20')}'%20and%20@site_symmetry_4='{replace(@site_symmetry_4,' +','%20')}']">
      <xsl2:if test="PDBx:atom_site_auth_asym_id_1!='' and PDBx:atom_site_auth_atom_id_1!='' and PDBx:atom_site_auth_comp_id_1!='' and PDBx:atom_site_auth_seq_id_1!='' and @atom_site_id_1!='' and PDBx:atom_site_label_alt_id_1!='' and PDBx:atom_site_label_asym_id_1!='' and PDBx:atom_site_label_atom_id_1!='' and PDBx:atom_site_label_comp_id_1!='' and PDBx:atom_site_label_seq_id_1!='' and PDBx:pdbx_PDB_model_num!='' and PDBx:pdbx_atom_site_PDB_ins_code_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_1,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_1,' +','%20')}'%20and%20@id='{replace(@atom_site_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_1,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_1,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_1,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_1,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_PDB_model_num,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:pdbx_atom_site_PDB_ins_code_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_3_3_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_2!='' and PDBx:atom_site_auth_atom_id_2!='' and PDBx:atom_site_auth_comp_id_2!='' and PDBx:atom_site_auth_seq_id_2!='' and @atom_site_id_2!='' and PDBx:atom_site_label_alt_id_2!='' and PDBx:atom_site_label_asym_id_2!='' and PDBx:atom_site_label_atom_id_2!='' and PDBx:atom_site_label_comp_id_2!='' and PDBx:atom_site_label_seq_id_2!='' and PDBx:pdbx_atom_site_PDB_ins_code_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_2,' +','%20')}'%20and%20@id='{replace(@atom_site_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_2,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_atom_site_PDB_ins_code_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_4_3_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_3!='' and PDBx:atom_site_auth_atom_id_3!='' and PDBx:atom_site_auth_comp_id_3!='' and PDBx:atom_site_auth_seq_id_3!='' and @atom_site_id_3!='' and PDBx:atom_site_label_alt_id_3!='' and PDBx:atom_site_label_asym_id_3!='' and PDBx:atom_site_label_atom_id_3!='' and PDBx:atom_site_label_comp_id_3!='' and PDBx:atom_site_label_seq_id_3!='' and PDBx:pdbx_atom_site_PDB_ins_code_3!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_3,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_3,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_3,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_3,' +','%20')}'%20and%20@id='{replace(@atom_site_id_3,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_3,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_3,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_3,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_3,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_3,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_atom_site_PDB_ins_code_3,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_4_3_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:atom_site_auth_asym_id_4!='' and PDBx:atom_site_auth_atom_id_4!='' and PDBx:atom_site_auth_comp_id_4!='' and PDBx:atom_site_auth_seq_id_4!='' and @atom_site_id_4!='' and PDBx:atom_site_label_alt_id_4!='' and PDBx:atom_site_label_asym_id_4!='' and PDBx:atom_site_label_atom_id_4!='' and PDBx:atom_site_label_comp_id_4!='' and PDBx:atom_site_label_seq_id_4!='' and PDBx:pdbx_atom_site_PDB_ins_code_4!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:atom_site_auth_asym_id_4,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:atom_site_auth_atom_id_4,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:atom_site_auth_comp_id_4,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:atom_site_auth_seq_id_4,' +','%20')}'%20and%20@id='{replace(@atom_site_id_4,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:atom_site_label_alt_id_4,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:atom_site_label_asym_id_4,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:atom_site_label_atom_id_4,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:atom_site_label_comp_id_4,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:atom_site_label_seq_id_4,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_atom_site_PDB_ins_code_4,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_4_3_2</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:geom_torsion>
    </PDBo:geom_torsionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:journalCategory/PDBx:journal">
    <PDBo:journalCategory>
      <PDBo:journal rdf:about="{$base}/PDBx:datablock/PDBx:journalCategory/PDBx:journal[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_26_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:journal>
    </PDBo:journalCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:journal_indexCategory/PDBx:journal_index">
    <PDBo:journal_indexCategory>
      <PDBo:journal_index rdf:about="{$base}/PDBx:datablock/PDBx:journal_indexCategory/PDBx:journal_index[@term='{replace(@term,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:journal_index>
    </PDBo:journal_indexCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:ndb_original_ndb_coordinatesCategory/PDBx:ndb_original_ndb_coordinates">
    <PDBo:ndb_original_ndb_coordinatesCategory>
      <PDBo:ndb_original_ndb_coordinates rdf:about="{$base}/PDBx:datablock/PDBx:ndb_original_ndb_coordinatesCategory/PDBx:ndb_original_ndb_coordinates[@coord_section='{replace(@coord_section,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:ndb_original_ndb_coordinates>
    </PDBo:ndb_original_ndb_coordinatesCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:ndb_struct_conf_naCategory/PDBx:ndb_struct_conf_na">
    <PDBo:ndb_struct_conf_naCategory>
      <PDBo:ndb_struct_conf_na rdf:about="{$base}/PDBx:datablock/PDBx:ndb_struct_conf_naCategory/PDBx:ndb_struct_conf_na[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@feature='{replace(@feature,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_27_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:ndb_struct_conf_na>
    </PDBo:ndb_struct_conf_naCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:ndb_struct_feature_naCategory/PDBx:ndb_struct_feature_na">
    <PDBo:ndb_struct_feature_naCategory>
      <PDBo:ndb_struct_feature_na rdf:about="{$base}/PDBx:datablock/PDBx:ndb_struct_feature_naCategory/PDBx:ndb_struct_feature_na[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@feature='{replace(@feature,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_28_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:ndb_struct_feature_na>
    </PDBo:ndb_struct_feature_naCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:ndb_struct_na_base_pairCategory/PDBx:ndb_struct_na_base_pair">
    <PDBo:ndb_struct_na_base_pairCategory>
      <PDBo:ndb_struct_na_base_pair rdf:about="{$base}/PDBx:datablock/PDBx:ndb_struct_na_base_pairCategory/PDBx:ndb_struct_na_base_pair[@i_label_asym_id='{replace(@i_label_asym_id,' +','%20')}'%20and%20@i_label_comp_id='{replace(@i_label_comp_id,' +','%20')}'%20and%20@i_label_seq_id='{replace(@i_label_seq_id,' +','%20')}'%20and%20@i_symmetry='{replace(@i_symmetry,' +','%20')}'%20and%20@j_label_asym_id='{replace(@j_label_asym_id,' +','%20')}'%20and%20@j_label_comp_id='{replace(@j_label_comp_id,' +','%20')}'%20and%20@j_label_seq_id='{replace(@j_label_seq_id,' +','%20')}'%20and%20@j_symmetry='{replace(@j_symmetry,' +','%20')}'%20and%20@model_number='{replace(@model_number,' +','%20')}']">
      <xsl2:if test="PDBx:i_auth_asym_id!='' and PDBx:i_auth_seq_id!='' and @i_label_asym_id!='' and @i_label_comp_id!='' and @i_label_seq_id!='' and @model_number!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:i_auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:i_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@i_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@i_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@i_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@model_number,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_6_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:j_auth_asym_id!='' and PDBx:j_auth_seq_id!='' and @j_label_asym_id!='' and @j_label_comp_id!='' and @j_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:j_auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:j_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@j_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@j_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@j_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_7_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:ndb_struct_na_base_pair>
    </PDBo:ndb_struct_na_base_pairCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:ndb_struct_na_base_pair_stepCategory/PDBx:ndb_struct_na_base_pair_step">
    <PDBo:ndb_struct_na_base_pair_stepCategory>
      <PDBo:ndb_struct_na_base_pair_step rdf:about="{$base}/PDBx:datablock/PDBx:ndb_struct_na_base_pair_stepCategory/PDBx:ndb_struct_na_base_pair_step[@i_label_asym_id_1='{replace(@i_label_asym_id_1,' +','%20')}'%20and%20@i_label_asym_id_2='{replace(@i_label_asym_id_2,' +','%20')}'%20and%20@i_label_comp_id_1='{replace(@i_label_comp_id_1,' +','%20')}'%20and%20@i_label_comp_id_2='{replace(@i_label_comp_id_2,' +','%20')}'%20and%20@i_label_seq_id_1='{replace(@i_label_seq_id_1,' +','%20')}'%20and%20@i_label_seq_id_2='{replace(@i_label_seq_id_2,' +','%20')}'%20and%20@i_symmetry_1='{replace(@i_symmetry_1,' +','%20')}'%20and%20@i_symmetry_2='{replace(@i_symmetry_2,' +','%20')}'%20and%20@j_label_asym_id_1='{replace(@j_label_asym_id_1,' +','%20')}'%20and%20@j_label_asym_id_2='{replace(@j_label_asym_id_2,' +','%20')}'%20and%20@j_label_comp_id_1='{replace(@j_label_comp_id_1,' +','%20')}'%20and%20@j_label_comp_id_2='{replace(@j_label_comp_id_2,' +','%20')}'%20and%20@j_label_seq_id_1='{replace(@j_label_seq_id_1,' +','%20')}'%20and%20@j_label_seq_id_2='{replace(@j_label_seq_id_2,' +','%20')}'%20and%20@j_symmetry_1='{replace(@j_symmetry_1,' +','%20')}'%20and%20@j_symmetry_2='{replace(@j_symmetry_2,' +','%20')}'%20and%20@model_number='{replace(@model_number,' +','%20')}']">
      <xsl2:if test="PDBx:i_auth_asym_id_1!='' and PDBx:i_auth_seq_id_1!='' and @i_label_asym_id_1!='' and @i_label_comp_id_1!='' and @i_label_seq_id_1!='' and @model_number!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:i_auth_asym_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:i_auth_seq_id_1,' +','%20')}'%20and%20@label_asym_id='{replace(@i_label_asym_id_1,' +','%20')}'%20and%20@label_comp_id='{replace(@i_label_comp_id_1,' +','%20')}'%20and%20@label_seq_id='{replace(@i_label_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(@model_number,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_6_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:i_auth_asym_id_2!='' and PDBx:i_auth_seq_id_2!='' and @i_label_asym_id_2!='' and @i_label_comp_id_2!='' and @i_label_seq_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:i_auth_asym_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:i_auth_seq_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(@i_label_asym_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(@i_label_comp_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(@i_label_seq_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_7_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:j_auth_asym_id_1!='' and PDBx:j_auth_seq_id_1!='' and @j_label_asym_id_1!='' and @j_label_comp_id_1!='' and @j_label_seq_id_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:j_auth_asym_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:j_auth_seq_id_1,' +','%20')}'%20and%20@label_asym_id='{replace(@j_label_asym_id_1,' +','%20')}'%20and%20@label_comp_id='{replace(@j_label_comp_id_1,' +','%20')}'%20and%20@label_seq_id='{replace(@j_label_seq_id_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_7_1_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:j_auth_asym_id_2!='' and PDBx:j_auth_seq_id_2!='' and @j_label_asym_id_2!='' and @j_label_comp_id_2!='' and @j_label_seq_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:j_auth_asym_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:j_auth_seq_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(@j_label_asym_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(@j_label_comp_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(@j_label_seq_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_7_1_2</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:ndb_struct_na_base_pair_step>
    </PDBo:ndb_struct_na_base_pair_stepCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_SG_projectCategory/PDBx:pdbx_SG_project">
    <PDBo:pdbx_SG_projectCategory>
      <PDBo:pdbx_SG_project rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_SG_projectCategory/PDBx:pdbx_SG_project[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_SG_project>
    </PDBo:pdbx_SG_projectCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_atom_site_aniso_tlsCategory/PDBx:pdbx_atom_site_aniso_tls">
    <PDBo:pdbx_atom_site_aniso_tlsCategory>
      <PDBo:pdbx_atom_site_aniso_tls rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_atom_site_aniso_tlsCategory/PDBx:pdbx_atom_site_aniso_tls[@id='{replace(@id,' +','%20')}'%20and%20@tls_group_id='{replace(@tls_group_id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:auth_asym_id!='' and PDBx:auth_atom_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and @id!='' and PDBx:label_asym_id!='' and PDBx:label_atom_id!='' and PDBx:label_comp_id!='' and PDBx:label_seq_id!='' and PDBx:type_symbol!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(@id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_seq_id,' +','%20')}'%20and%20@type_symbol='{replace(PDBx:type_symbol,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_8_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:label_alt_id!=''">
        <PDBo:reference_to_atom_sites_alt>
          <PDBo:atom_sites_alt rdf:about="{$base}/PDBx:datablock/PDBx:atom_sites_altCategory/PDBx:atom_sites_alt[@id='{replace(PDBx:label_alt_id,' +','%20')}']">
            <rdfs:label>atom_sites_altKeyref_1_1_0</rdfs:label>
          </PDBo:atom_sites_alt>
        </PDBo:reference_to_atom_sites_alt>
      </xsl2:if>
      <xsl2:if test="@tls_group_id!=''">
        <PDBo:reference_to_pdbx_refine_tls>
          <PDBo:pdbx_refine_tls rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refine_tlsCategory/PDBx:pdbx_refine_tls[@id='{replace(@tls_group_id,' +','%20')}']">
            <rdfs:label>pdbx_refine_tlsKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_refine_tls>
        </PDBo:reference_to_pdbx_refine_tls>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_atom_site_aniso_tls>
    </PDBo:pdbx_atom_site_aniso_tlsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_auditCategory/PDBx:pdbx_audit">
    <PDBo:pdbx_auditCategory>
      <PDBo:pdbx_audit rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_auditCategory/PDBx:pdbx_audit[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="PDBx:current_version!=''">
        <PDBo:reference_to_audit>
          <PDBo:audit rdf:about="{$base}/PDBx:datablock/PDBx:auditCategory/PDBx:audit[@revision_id='{replace(PDBx:current_version,' +','%20')}']">
            <rdfs:label>auditKeyref_1_0_0</rdfs:label>
          </PDBo:audit>
        </PDBo:reference_to_audit>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_29_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_audit>
    </PDBo:pdbx_auditCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_audit_authorCategory/PDBx:pdbx_audit_author">
    <PDBo:pdbx_audit_authorCategory>
      <PDBo:pdbx_audit_author rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_audit_authorCategory/PDBx:pdbx_audit_author[@ordinal='{replace(@ordinal,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_audit_author>
    </PDBo:pdbx_audit_authorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer">
    <PDBo:pdbx_bufferCategory>
      <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_buffer>
    </PDBo:pdbx_bufferCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_buffer_componentsCategory/PDBx:pdbx_buffer_components">
    <PDBo:pdbx_buffer_componentsCategory>
      <PDBo:pdbx_buffer_components rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_buffer_componentsCategory/PDBx:pdbx_buffer_components[@buffer_id='{replace(@buffer_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(@buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_buffer_components>
    </PDBo:pdbx_buffer_componentsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_chem_comp_atom_editCategory/PDBx:pdbx_chem_comp_atom_edit">
    <PDBo:pdbx_chem_comp_atom_editCategory>
      <PDBo:pdbx_chem_comp_atom_edit rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_atom_editCategory/PDBx:pdbx_chem_comp_atom_edit[@ordinal='{replace(@ordinal,' +','%20')}']">
      <xsl2:if test="PDBx:comp_id!=''">
        <PDBo:reference_to_pdbx_chem_comp_import>
          <PDBo:pdbx_chem_comp_import rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_importCategory/PDBx:pdbx_chem_comp_import[@comp_id='{replace(PDBx:comp_id,' +','%20')}']">
            <rdfs:label>pdbx_chem_comp_importKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_chem_comp_import>
        </PDBo:reference_to_pdbx_chem_comp_import>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_chem_comp_atom_edit>
    </PDBo:pdbx_chem_comp_atom_editCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_chem_comp_auditCategory/PDBx:pdbx_chem_comp_audit">
    <PDBo:pdbx_chem_comp_auditCategory>
      <PDBo:pdbx_chem_comp_audit rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_auditCategory/PDBx:pdbx_chem_comp_audit[@action_type='{replace(@action_type,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@date='{replace(@date,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_7_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_chem_comp_audit>
    </PDBo:pdbx_chem_comp_auditCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_chem_comp_bond_editCategory/PDBx:pdbx_chem_comp_bond_edit">
    <PDBo:pdbx_chem_comp_bond_editCategory>
      <PDBo:pdbx_chem_comp_bond_edit rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_bond_editCategory/PDBx:pdbx_chem_comp_bond_edit[@atom_id_1='{replace(@atom_id_1,' +','%20')}'%20and%20@atom_id_2='{replace(@atom_id_2,' +','%20')}'%20and%20@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@edit_op='{replace(@edit_op,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_pdbx_chem_comp_import>
          <PDBo:pdbx_chem_comp_import rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_importCategory/PDBx:pdbx_chem_comp_import[@comp_id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>pdbx_chem_comp_importKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_chem_comp_import>
        </PDBo:reference_to_pdbx_chem_comp_import>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_chem_comp_bond_edit>
    </PDBo:pdbx_chem_comp_bond_editCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_chem_comp_descriptorCategory/PDBx:pdbx_chem_comp_descriptor">
    <PDBo:pdbx_chem_comp_descriptorCategory>
      <PDBo:pdbx_chem_comp_descriptor rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_descriptorCategory/PDBx:pdbx_chem_comp_descriptor[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@program='{replace(@program,' +','%20')}'%20and%20@program_version='{replace(@program_version,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_8_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_chem_comp_descriptor>
    </PDBo:pdbx_chem_comp_descriptorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_chem_comp_featureCategory/PDBx:pdbx_chem_comp_feature">
    <PDBo:pdbx_chem_comp_featureCategory>
      <PDBo:pdbx_chem_comp_feature rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_featureCategory/PDBx:pdbx_chem_comp_feature[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@source='{replace(@source,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}'%20and%20@value='{replace(@value,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_9_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_chem_comp_feature>
    </PDBo:pdbx_chem_comp_featureCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_chem_comp_identifierCategory/PDBx:pdbx_chem_comp_identifier">
    <PDBo:pdbx_chem_comp_identifierCategory>
      <PDBo:pdbx_chem_comp_identifier rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_identifierCategory/PDBx:pdbx_chem_comp_identifier[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@program='{replace(@program,' +','%20')}'%20and%20@program_version='{replace(@program_version,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_10_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_chem_comp_identifier>
    </PDBo:pdbx_chem_comp_identifierCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_chem_comp_importCategory/PDBx:pdbx_chem_comp_import">
    <PDBo:pdbx_chem_comp_importCategory>
      <PDBo:pdbx_chem_comp_import rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_chem_comp_importCategory/PDBx:pdbx_chem_comp_import[@comp_id='{replace(@comp_id,' +','%20')}']">
      <xsl2:if test="@comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(@comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_11_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_chem_comp_import>
    </PDBo:pdbx_chem_comp_importCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct">
    <PDBo:pdbx_constructCategory>
      <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_10_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="PDBx:entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(PDBx:entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_30_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_construct>
    </PDBo:pdbx_constructCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_construct_featureCategory/PDBx:pdbx_construct_feature">
    <PDBo:pdbx_construct_featureCategory>
      <PDBo:pdbx_construct_feature rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_construct_featureCategory/PDBx:pdbx_construct_feature[@construct_id='{replace(@construct_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(PDBx:entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_31_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="@construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(@construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_construct_feature>
    </PDBo:pdbx_construct_featureCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_contact_authorCategory/PDBx:pdbx_contact_author">
    <PDBo:pdbx_contact_authorCategory>
      <PDBo:pdbx_contact_author rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_contact_authorCategory/PDBx:pdbx_contact_author[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_contact_author>
    </PDBo:pdbx_contact_authorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_coordinate_modelCategory/PDBx:pdbx_coordinate_model">
    <PDBo:pdbx_coordinate_modelCategory>
      <PDBo:pdbx_coordinate_model rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_coordinate_modelCategory/PDBx:pdbx_coordinate_model[@asym_id='{replace(@asym_id,' +','%20')}']">
      <xsl2:if test="@asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(@asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_1_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_coordinate_model>
    </PDBo:pdbx_coordinate_modelCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_database_PDB_obs_sprCategory/PDBx:pdbx_database_PDB_obs_spr">
    <PDBo:pdbx_database_PDB_obs_sprCategory>
      <PDBo:pdbx_database_PDB_obs_spr rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_database_PDB_obs_sprCategory/PDBx:pdbx_database_PDB_obs_spr[@pdb_id='{replace(@pdb_id,' +','%20')}'%20and%20@replace_pdb_id='{replace(@replace_pdb_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_database_PDB_obs_spr>
    </PDBo:pdbx_database_PDB_obs_sprCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_database_messageCategory/PDBx:pdbx_database_message">
    <PDBo:pdbx_database_messageCategory>
      <PDBo:pdbx_database_message rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_database_messageCategory/PDBx:pdbx_database_message[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@message_id='{replace(@message_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_32_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_database_message>
    </PDBo:pdbx_database_messageCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_database_procCategory/PDBx:pdbx_database_proc">
    <PDBo:pdbx_database_procCategory>
      <PDBo:pdbx_database_proc rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_database_procCategory/PDBx:pdbx_database_proc[@cycle_id='{replace(@cycle_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_33_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_database_proc>
    </PDBo:pdbx_database_procCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_database_relatedCategory/PDBx:pdbx_database_related">
    <PDBo:pdbx_database_relatedCategory>
      <PDBo:pdbx_database_related rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_database_relatedCategory/PDBx:pdbx_database_related[@content_type='{replace(@content_type,' +','%20')}'%20and%20@db_id='{replace(@db_id,' +','%20')}'%20and%20@db_name='{replace(@db_name,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_database_related>
    </PDBo:pdbx_database_relatedCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_database_remarkCategory/PDBx:pdbx_database_remark">
    <PDBo:pdbx_database_remarkCategory>
      <PDBo:pdbx_database_remark rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_database_remarkCategory/PDBx:pdbx_database_remark[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_database_remark>
    </PDBo:pdbx_database_remarkCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_database_statusCategory/PDBx:pdbx_database_status">
    <PDBo:pdbx_database_statusCategory>
      <PDBo:pdbx_database_status rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_database_statusCategory/PDBx:pdbx_database_status[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_34_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_database_status>
    </PDBo:pdbx_database_statusCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_diffrn_reflns_shellCategory/PDBx:pdbx_diffrn_reflns_shell">
    <PDBo:pdbx_diffrn_reflns_shellCategory>
      <PDBo:pdbx_diffrn_reflns_shell rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_diffrn_reflns_shellCategory/PDBx:pdbx_diffrn_reflns_shell[@d_res_high='{replace(@d_res_high,' +','%20')}'%20and%20@d_res_low='{replace(@d_res_low,' +','%20')}'%20and%20@diffrn_id='{replace(@diffrn_id,' +','%20')}']">
      <xsl2:if test="@diffrn_id!=''">
        <PDBo:reference_to_diffrn>
          <PDBo:diffrn rdf:about="{$base}/PDBx:datablock/PDBx:diffrnCategory/PDBx:diffrn[@id='{replace(@diffrn_id,' +','%20')}']">
            <rdfs:label>diffrnKeyref_1_10_0</rdfs:label>
          </PDBo:diffrn>
        </PDBo:reference_to_diffrn>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_diffrn_reflns_shell>
    </PDBo:pdbx_diffrn_reflns_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_domainCategory/PDBx:pdbx_domain">
    <PDBo:pdbx_domainCategory>
      <PDBo:pdbx_domain rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_domainCategory/PDBx:pdbx_domain[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_domain>
    </PDBo:pdbx_domainCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_domain_rangeCategory/PDBx:pdbx_domain_range">
    <PDBo:pdbx_domain_rangeCategory>
      <PDBo:pdbx_domain_range rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_domain_rangeCategory/PDBx:pdbx_domain_range[@beg_label_alt_id='{replace(@beg_label_alt_id,' +','%20')}'%20and%20@beg_label_asym_id='{replace(@beg_label_asym_id,' +','%20')}'%20and%20@beg_label_comp_id='{replace(@beg_label_comp_id,' +','%20')}'%20and%20@beg_label_seq_id='{replace(@beg_label_seq_id,' +','%20')}'%20and%20@domain_id='{replace(@domain_id,' +','%20')}'%20and%20@end_label_alt_id='{replace(@end_label_alt_id,' +','%20')}'%20and%20@end_label_asym_id='{replace(@end_label_asym_id,' +','%20')}'%20and%20@end_label_comp_id='{replace(@end_label_comp_id,' +','%20')}'%20and%20@end_label_seq_id='{replace(@end_label_seq_id,' +','%20')}']">
      <xsl2:if test="PDBx:beg_auth_asym_id!='' and PDBx:beg_auth_comp_id!='' and PDBx:beg_auth_seq_id!='' and @beg_label_alt_id!='' and @beg_label_asym_id!='' and @beg_label_comp_id!='' and @beg_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:beg_auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@beg_label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@beg_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@beg_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@beg_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:end_auth_asym_id!='' and PDBx:end_auth_comp_id!='' and PDBx:end_auth_seq_id!='' and @end_label_alt_id!='' and @end_label_asym_id!='' and @end_label_comp_id!='' and @end_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:end_auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@end_label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@end_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@end_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@end_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="@domain_id!=''">
        <PDBo:reference_to_pdbx_domain>
          <PDBo:pdbx_domain rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_domainCategory/PDBx:pdbx_domain[@id='{replace(@domain_id,' +','%20')}']">
            <rdfs:label>pdbx_domainKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_domain>
        </PDBo:reference_to_pdbx_domain>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_domain_range>
    </PDBo:pdbx_domain_rangeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_assemblyCategory/PDBx:pdbx_entity_assembly">
    <PDBo:pdbx_entity_assemblyCategory>
      <PDBo:pdbx_entity_assembly rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_assemblyCategory/PDBx:pdbx_entity_assembly[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_11_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="PDBx:biol_id!=''">
        <PDBo:reference_to_struct_biol>
          <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(PDBx:biol_id,' +','%20')}']">
            <rdfs:label>struct_biolKeyref_1_0_0</rdfs:label>
          </PDBo:struct_biol>
        </PDBo:reference_to_struct_biol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_assembly>
    </PDBo:pdbx_entity_assemblyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_nameCategory/PDBx:pdbx_entity_name">
    <PDBo:pdbx_entity_nameCategory>
      <PDBo:pdbx_entity_name rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_nameCategory/PDBx:pdbx_entity_name[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@name='{replace(@name,' +','%20')}'%20and%20@name_type='{replace(@name_type,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_12_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_name>
    </PDBo:pdbx_entity_nameCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_nonpolyCategory/PDBx:pdbx_entity_nonpoly">
    <PDBo:pdbx_entity_nonpolyCategory>
      <PDBo:pdbx_entity_nonpoly rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_nonpolyCategory/PDBx:pdbx_entity_nonpoly[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="PDBx:comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(PDBx:comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_12_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_13_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_nonpoly>
    </PDBo:pdbx_entity_nonpolyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_prod_protocolCategory/PDBx:pdbx_entity_prod_protocol">
    <PDBo:pdbx_entity_prod_protocolCategory>
      <PDBo:pdbx_entity_prod_protocol rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_prod_protocolCategory/PDBx:pdbx_entity_prod_protocol[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@protocol_type='{replace(@protocol_type,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_14_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_35_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_prod_protocol>
    </PDBo:pdbx_entity_prod_protocolCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_characterCategory/PDBx:pdbx_entity_src_gen_character">
    <PDBo:pdbx_entity_src_gen_characterCategory>
      <PDBo:pdbx_entity_src_gen_character rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_characterCategory/PDBx:pdbx_entity_src_gen_character[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_15_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_36_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_character>
    </PDBo:pdbx_entity_src_gen_characterCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_chromCategory/PDBx:pdbx_entity_src_gen_chrom">
    <PDBo:pdbx_entity_src_gen_chromCategory>
      <PDBo:pdbx_entity_src_gen_chrom rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_chromCategory/PDBx:pdbx_entity_src_gen_chrom[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_16_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_37_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:elution_buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:elution_buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:equilibration_buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:equilibration_buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_1_1</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_2_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_2_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_chrom>
    </PDBo:pdbx_entity_src_gen_chromCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_cloneCategory/PDBx:pdbx_entity_src_gen_clone">
    <PDBo:pdbx_entity_src_gen_cloneCategory>
      <PDBo:pdbx_entity_src_gen_clone rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_cloneCategory/PDBx:pdbx_entity_src_gen_clone[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_17_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_38_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_3_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_3_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_clone>
    </PDBo:pdbx_entity_src_gen_cloneCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_clone_ligationCategory/PDBx:pdbx_entity_src_gen_clone_ligation">
    <PDBo:pdbx_entity_src_gen_clone_ligationCategory>
      <PDBo:pdbx_entity_src_gen_clone_ligation rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_clone_ligationCategory/PDBx:pdbx_entity_src_gen_clone_ligation[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!='' and @entry_id!='' and @step_id!=''">
        <PDBo:reference_to_pdbx_entity_src_gen_clone>
          <PDBo:pdbx_entity_src_gen_clone rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_cloneCategory/PDBx:pdbx_entity_src_gen_clone[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
            <rdfs:label>pdbx_entity_src_gen_cloneKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_entity_src_gen_clone>
        </PDBo:reference_to_pdbx_entity_src_gen_clone>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_clone_ligation>
    </PDBo:pdbx_entity_src_gen_clone_ligationCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_clone_recombinationCategory/PDBx:pdbx_entity_src_gen_clone_recombination">
    <PDBo:pdbx_entity_src_gen_clone_recombinationCategory>
      <PDBo:pdbx_entity_src_gen_clone_recombination rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_clone_recombinationCategory/PDBx:pdbx_entity_src_gen_clone_recombination[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!='' and @entry_id!='' and @step_id!=''">
        <PDBo:reference_to_pdbx_entity_src_gen_clone>
          <PDBo:pdbx_entity_src_gen_clone rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_cloneCategory/PDBx:pdbx_entity_src_gen_clone[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
            <rdfs:label>pdbx_entity_src_gen_cloneKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_entity_src_gen_clone>
        </PDBo:reference_to_pdbx_entity_src_gen_clone>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_clone_recombination>
    </PDBo:pdbx_entity_src_gen_clone_recombinationCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_expressCategory/PDBx:pdbx_entity_src_gen_express">
    <PDBo:pdbx_entity_src_gen_expressCategory>
      <PDBo:pdbx_entity_src_gen_express rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_expressCategory/PDBx:pdbx_entity_src_gen_express[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_18_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_39_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_4_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:plasmid_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:plasmid_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_4_1</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_4_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_express>
    </PDBo:pdbx_entity_src_gen_expressCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_express_timepointCategory/PDBx:pdbx_entity_src_gen_express_timepoint">
    <PDBo:pdbx_entity_src_gen_express_timepointCategory>
      <PDBo:pdbx_entity_src_gen_express_timepoint rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_express_timepointCategory/PDBx:pdbx_entity_src_gen_express_timepoint[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@serial='{replace(@serial,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!='' and @entry_id!='' and @step_id!=''">
        <PDBo:reference_to_pdbx_entity_src_gen_express>
          <PDBo:pdbx_entity_src_gen_express rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_expressCategory/PDBx:pdbx_entity_src_gen_express[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
            <rdfs:label>pdbx_entity_src_gen_expressKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_entity_src_gen_express>
        </PDBo:reference_to_pdbx_entity_src_gen_express>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_express_timepoint>
    </PDBo:pdbx_entity_src_gen_express_timepointCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_fractCategory/PDBx:pdbx_entity_src_gen_fract">
    <PDBo:pdbx_entity_src_gen_fractCategory>
      <PDBo:pdbx_entity_src_gen_fract rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_fractCategory/PDBx:pdbx_entity_src_gen_fract[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_19_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_40_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_5_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_5_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_fract>
    </PDBo:pdbx_entity_src_gen_fractCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_lysisCategory/PDBx:pdbx_entity_src_gen_lysis">
    <PDBo:pdbx_entity_src_gen_lysisCategory>
      <PDBo:pdbx_entity_src_gen_lysis rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_lysisCategory/PDBx:pdbx_entity_src_gen_lysis[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_20_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_41_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_2_0</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_6_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_6_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_lysis>
    </PDBo:pdbx_entity_src_gen_lysisCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_digestCategory/PDBx:pdbx_entity_src_gen_prod_digest">
    <PDBo:pdbx_entity_src_gen_prod_digestCategory>
      <PDBo:pdbx_entity_src_gen_prod_digest rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_digestCategory/PDBx:pdbx_entity_src_gen_prod_digest[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_21_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_42_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_7_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_7_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_prod_digest>
    </PDBo:pdbx_entity_src_gen_prod_digestCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_otherCategory/PDBx:pdbx_entity_src_gen_prod_other">
    <PDBo:pdbx_entity_src_gen_prod_otherCategory>
      <PDBo:pdbx_entity_src_gen_prod_other rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_otherCategory/PDBx:pdbx_entity_src_gen_prod_other[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_22_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_43_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_8_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_8_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_prod_other>
    </PDBo:pdbx_entity_src_gen_prod_otherCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_other_parameterCategory/PDBx:pdbx_entity_src_gen_prod_other_parameter">
    <PDBo:pdbx_entity_src_gen_prod_other_parameterCategory>
      <PDBo:pdbx_entity_src_gen_prod_other_parameter rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_other_parameterCategory/PDBx:pdbx_entity_src_gen_prod_other_parameter[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@parameter='{replace(@parameter,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!='' and @entry_id!='' and @step_id!=''">
        <PDBo:reference_to_pdbx_entity_src_gen_prod_other>
          <PDBo:pdbx_entity_src_gen_prod_other rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_otherCategory/PDBx:pdbx_entity_src_gen_prod_other[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
            <rdfs:label>pdbx_entity_src_gen_prod_otherKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_entity_src_gen_prod_other>
        </PDBo:reference_to_pdbx_entity_src_gen_prod_other>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_prod_other_parameter>
    </PDBo:pdbx_entity_src_gen_prod_other_parameterCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_pcrCategory/PDBx:pdbx_entity_src_gen_prod_pcr">
    <PDBo:pdbx_entity_src_gen_prod_pcrCategory>
      <PDBo:pdbx_entity_src_gen_prod_pcr rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_prod_pcrCategory/PDBx:pdbx_entity_src_gen_prod_pcr[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_23_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_44_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_9_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:forward_primer_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:forward_primer_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_9_1</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:reverse_primer_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:reverse_primer_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_9_2</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_9_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_prod_pcr>
    </PDBo:pdbx_entity_src_gen_prod_pcrCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_proteolysisCategory/PDBx:pdbx_entity_src_gen_proteolysis">
    <PDBo:pdbx_entity_src_gen_proteolysisCategory>
      <PDBo:pdbx_entity_src_gen_proteolysis rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_proteolysisCategory/PDBx:pdbx_entity_src_gen_proteolysis[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_24_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_45_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:cleavage_buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:cleavage_buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_3_0</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_10_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_10_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_proteolysis>
    </PDBo:pdbx_entity_src_gen_proteolysisCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_pureCategory/PDBx:pdbx_entity_src_gen_pure">
    <PDBo:pdbx_entity_src_gen_pureCategory>
      <PDBo:pdbx_entity_src_gen_pure rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_pureCategory/PDBx:pdbx_entity_src_gen_pure[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_25_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_46_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:storage_buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:storage_buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_4_0</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:conc_device_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:conc_device_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_11_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_pure>
    </PDBo:pdbx_entity_src_gen_pureCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_gen_refoldCategory/PDBx:pdbx_entity_src_gen_refold">
    <PDBo:pdbx_entity_src_gen_refoldCategory>
      <PDBo:pdbx_entity_src_gen_refold rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_gen_refoldCategory/PDBx:pdbx_entity_src_gen_refold[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@step_id='{replace(@step_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_26_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_47_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="PDBx:denature_buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:denature_buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_5_0</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:refold_buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:refold_buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_5_1</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:storage_buffer_id!=''">
        <PDBo:reference_to_pdbx_buffer>
          <PDBo:pdbx_buffer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_bufferCategory/PDBx:pdbx_buffer[@id='{replace(PDBx:storage_buffer_id,' +','%20')}']">
            <rdfs:label>pdbx_bufferKeyref_1_5_2</rdfs:label>
          </PDBo:pdbx_buffer>
        </PDBo:reference_to_pdbx_buffer>
      </xsl2:if>
      <xsl2:if test="PDBx:end_construct_id!=''">
        <PDBo:reference_to_pdbx_construct>
          <PDBo:pdbx_construct rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_constructCategory/PDBx:pdbx_construct[@id='{replace(PDBx:end_construct_id,' +','%20')}']">
            <rdfs:label>pdbx_constructKeyref_1_11_0</rdfs:label>
          </PDBo:pdbx_construct>
        </PDBo:reference_to_pdbx_construct>
      </xsl2:if>
      <xsl2:if test="PDBx:robot_id!=''">
        <PDBo:reference_to_pdbx_robot_system>
          <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(PDBx:robot_id,' +','%20')}']">
            <rdfs:label>pdbx_robot_systemKeyref_1_12_0</rdfs:label>
          </PDBo:pdbx_robot_system>
        </PDBo:reference_to_pdbx_robot_system>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_gen_refold>
    </PDBo:pdbx_entity_src_gen_refoldCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entity_src_synCategory/PDBx:pdbx_entity_src_syn">
    <PDBo:pdbx_entity_src_synCategory>
      <PDBo:pdbx_entity_src_syn rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entity_src_synCategory/PDBx:pdbx_entity_src_syn[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_27_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entity_src_syn>
    </PDBo:pdbx_entity_src_synCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_entry_detailsCategory/PDBx:pdbx_entry_details">
    <PDBo:pdbx_entry_detailsCategory>
      <PDBo:pdbx_entry_details rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_entry_detailsCategory/PDBx:pdbx_entry_details[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_48_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_entry_details>
    </PDBo:pdbx_entry_detailsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_exptl_crystal_cryo_treatmentCategory/PDBx:pdbx_exptl_crystal_cryo_treatment">
    <PDBo:pdbx_exptl_crystal_cryo_treatmentCategory>
      <PDBo:pdbx_exptl_crystal_cryo_treatment rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_exptl_crystal_cryo_treatmentCategory/PDBx:pdbx_exptl_crystal_cryo_treatment[@crystal_id='{replace(@crystal_id,' +','%20')}']">
      <xsl2:if test="@crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(@crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_4_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_exptl_crystal_cryo_treatment>
    </PDBo:pdbx_exptl_crystal_cryo_treatmentCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_exptl_crystal_grow_compCategory/PDBx:pdbx_exptl_crystal_grow_comp">
    <PDBo:pdbx_exptl_crystal_grow_compCategory>
      <PDBo:pdbx_exptl_crystal_grow_comp rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_exptl_crystal_grow_compCategory/PDBx:pdbx_exptl_crystal_grow_comp[@comp_id='{replace(@comp_id,' +','%20')}'%20and%20@crystal_id='{replace(@crystal_id,' +','%20')}']">
      <xsl2:if test="@crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(@crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_5_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:if test="PDBx:sol_id!=''">
        <PDBo:reference_to_pdbx_exptl_crystal_grow_sol>
          <PDBo:pdbx_exptl_crystal_grow_sol rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_exptl_crystal_grow_solCategory/PDBx:pdbx_exptl_crystal_grow_sol[@sol_id='{replace(PDBx:sol_id,' +','%20')}']">
            <rdfs:label>pdbx_exptl_crystal_grow_solKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_exptl_crystal_grow_sol>
        </PDBo:reference_to_pdbx_exptl_crystal_grow_sol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_exptl_crystal_grow_comp>
    </PDBo:pdbx_exptl_crystal_grow_compCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_exptl_crystal_grow_solCategory/PDBx:pdbx_exptl_crystal_grow_sol">
    <PDBo:pdbx_exptl_crystal_grow_solCategory>
      <PDBo:pdbx_exptl_crystal_grow_sol rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_exptl_crystal_grow_solCategory/PDBx:pdbx_exptl_crystal_grow_sol[@crystal_id='{replace(@crystal_id,' +','%20')}'%20and%20@sol_id='{replace(@sol_id,' +','%20')}']">
      <xsl2:if test="@sol_id!=''">
        <rdfs:sameAs>
          <PDBo:pdbx_exptl_crystal_grow_sol rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_exptl_crystal_grow_solCategory/PDBx:pdbx_exptl_crystal_grow_sol[@sol_id='{replace(@sol_id,' +','%20')}']">
            <rdfs:label>pdbx_exptl_crystal_grow_solKey_1</rdfs:label>
          </PDBo:pdbx_exptl_crystal_grow_sol>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(@crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_6_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_exptl_crystal_grow_sol>
    </PDBo:pdbx_exptl_crystal_grow_solCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_exptl_pdCategory/PDBx:pdbx_exptl_pd">
    <PDBo:pdbx_exptl_pdCategory>
      <PDBo:pdbx_exptl_pd rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_exptl_pdCategory/PDBx:pdbx_exptl_pd[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_49_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_exptl_pd>
    </PDBo:pdbx_exptl_pdCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_feature_assemblyCategory/PDBx:pdbx_feature_assembly">
    <PDBo:pdbx_feature_assemblyCategory>
      <PDBo:pdbx_feature_assembly rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_feature_assemblyCategory/PDBx:pdbx_feature_assembly[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:feature_citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:feature_citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_9_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:feature_software_id!=''">
        <PDBo:reference_to_software>
          <PDBo:software rdf:about="{$base}/PDBx:datablock/PDBx:softwareCategory/PDBx:software[@name='{replace(PDBx:feature_software_id,' +','%20')}']">
            <rdfs:label>softwareKeyref_1_0_0</rdfs:label>
          </PDBo:software>
        </PDBo:reference_to_software>
      </xsl2:if>
      <xsl2:if test="PDBx:assembly_id!=''">
        <PDBo:reference_to_struct_biol>
          <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(PDBx:assembly_id,' +','%20')}']">
            <rdfs:label>struct_biolKeyref_1_1_0</rdfs:label>
          </PDBo:struct_biol>
        </PDBo:reference_to_struct_biol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_feature_assembly>
    </PDBo:pdbx_feature_assemblyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_feature_domainCategory/PDBx:pdbx_feature_domain">
    <PDBo:pdbx_feature_domainCategory>
      <PDBo:pdbx_feature_domain rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_feature_domainCategory/PDBx:pdbx_feature_domain[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:feature_citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:feature_citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_10_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:domain_id!=''">
        <PDBo:reference_to_pdbx_domain>
          <PDBo:pdbx_domain rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_domainCategory/PDBx:pdbx_domain[@id='{replace(PDBx:domain_id,' +','%20')}']">
            <rdfs:label>pdbx_domainKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_domain>
        </PDBo:reference_to_pdbx_domain>
      </xsl2:if>
      <xsl2:if test="PDBx:feature_software_id!=''">
        <PDBo:reference_to_software>
          <PDBo:software rdf:about="{$base}/PDBx:datablock/PDBx:softwareCategory/PDBx:software[@name='{replace(PDBx:feature_software_id,' +','%20')}']">
            <rdfs:label>softwareKeyref_1_1_0</rdfs:label>
          </PDBo:software>
        </PDBo:reference_to_software>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_feature_domain>
    </PDBo:pdbx_feature_domainCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_feature_entryCategory/PDBx:pdbx_feature_entry">
    <PDBo:pdbx_feature_entryCategory>
      <PDBo:pdbx_feature_entry rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_feature_entryCategory/PDBx:pdbx_feature_entry[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:feature_citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:feature_citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_11_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:feature_software_id!=''">
        <PDBo:reference_to_software>
          <PDBo:software rdf:about="{$base}/PDBx:datablock/PDBx:softwareCategory/PDBx:software[@name='{replace(PDBx:feature_software_id,' +','%20')}']">
            <rdfs:label>softwareKeyref_1_2_0</rdfs:label>
          </PDBo:software>
        </PDBo:reference_to_software>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_feature_entry>
    </PDBo:pdbx_feature_entryCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_feature_monomerCategory/PDBx:pdbx_feature_monomer">
    <PDBo:pdbx_feature_monomerCategory>
      <PDBo:pdbx_feature_monomer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_feature_monomerCategory/PDBx:pdbx_feature_monomer[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and PDBx:label_alt_id!='' and PDBx:label_asym_id!='' and PDBx:label_comp_id!='' and PDBx:label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:feature_citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:feature_citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_12_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:feature_software_id!=''">
        <PDBo:reference_to_software>
          <PDBo:software rdf:about="{$base}/PDBx:datablock/PDBx:softwareCategory/PDBx:software[@name='{replace(PDBx:feature_software_id,' +','%20')}']">
            <rdfs:label>softwareKeyref_1_3_0</rdfs:label>
          </PDBo:software>
        </PDBo:reference_to_software>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_feature_monomer>
    </PDBo:pdbx_feature_monomerCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_feature_sequence_rangeCategory/PDBx:pdbx_feature_sequence_range">
    <PDBo:pdbx_feature_sequence_rangeCategory>
      <PDBo:pdbx_feature_sequence_range rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_feature_sequence_rangeCategory/PDBx:pdbx_feature_sequence_range[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:feature_citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:feature_citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_13_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:if test="PDBx:seq_range_id!=''">
        <PDBo:reference_to_pdbx_sequence_range>
          <PDBo:pdbx_sequence_range rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_sequence_rangeCategory/PDBx:pdbx_sequence_range[@seq_range_id='{replace(PDBx:seq_range_id,' +','%20')}']">
            <rdfs:label>pdbx_sequence_rangeKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_sequence_range>
        </PDBo:reference_to_pdbx_sequence_range>
      </xsl2:if>
      <xsl2:if test="PDBx:feature_software_id!=''">
        <PDBo:reference_to_software>
          <PDBo:software rdf:about="{$base}/PDBx:datablock/PDBx:softwareCategory/PDBx:software[@name='{replace(PDBx:feature_software_id,' +','%20')}']">
            <rdfs:label>softwareKeyref_1_4_0</rdfs:label>
          </PDBo:software>
        </PDBo:reference_to_software>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_feature_sequence_range>
    </PDBo:pdbx_feature_sequence_rangeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_helical_symmetryCategory/PDBx:pdbx_helical_symmetry">
    <PDBo:pdbx_helical_symmetryCategory>
      <PDBo:pdbx_helical_symmetry rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_helical_symmetryCategory/PDBx:pdbx_helical_symmetry[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_50_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_helical_symmetry>
    </PDBo:pdbx_helical_symmetryCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_constraintsCategory/PDBx:pdbx_nmr_constraints">
    <PDBo:pdbx_nmr_constraintsCategory>
      <PDBo:pdbx_nmr_constraints rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_constraintsCategory/PDBx:pdbx_nmr_constraints[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_51_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_constraints>
    </PDBo:pdbx_nmr_constraintsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_detailsCategory/PDBx:pdbx_nmr_details">
    <PDBo:pdbx_nmr_detailsCategory>
      <PDBo:pdbx_nmr_details rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_detailsCategory/PDBx:pdbx_nmr_details[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_52_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_details>
    </PDBo:pdbx_nmr_detailsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_ensembleCategory/PDBx:pdbx_nmr_ensemble">
    <PDBo:pdbx_nmr_ensembleCategory>
      <PDBo:pdbx_nmr_ensemble rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_ensembleCategory/PDBx:pdbx_nmr_ensemble[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_53_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_ensemble>
    </PDBo:pdbx_nmr_ensembleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_ensemble_rmsCategory/PDBx:pdbx_nmr_ensemble_rms">
    <PDBo:pdbx_nmr_ensemble_rmsCategory>
      <PDBo:pdbx_nmr_ensemble_rms rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_ensemble_rmsCategory/PDBx:pdbx_nmr_ensemble_rms[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_54_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_ensemble_rms>
    </PDBo:pdbx_nmr_ensemble_rmsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_exptlCategory/PDBx:pdbx_nmr_exptl">
    <PDBo:pdbx_nmr_exptlCategory>
      <PDBo:pdbx_nmr_exptl rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_exptlCategory/PDBx:pdbx_nmr_exptl[@conditions_id='{replace(@conditions_id,' +','%20')}'%20and%20@experiment_id='{replace(@experiment_id,' +','%20')}'%20and%20@solution_id='{replace(@solution_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_exptl>
    </PDBo:pdbx_nmr_exptlCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_exptl_sampleCategory/PDBx:pdbx_nmr_exptl_sample">
    <PDBo:pdbx_nmr_exptl_sampleCategory>
      <PDBo:pdbx_nmr_exptl_sample rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_exptl_sampleCategory/PDBx:pdbx_nmr_exptl_sample[@component='{replace(@component,' +','%20')}'%20and%20@solution_id='{replace(@solution_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_exptl_sample>
    </PDBo:pdbx_nmr_exptl_sampleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_exptl_sample_conditionsCategory/PDBx:pdbx_nmr_exptl_sample_conditions">
    <PDBo:pdbx_nmr_exptl_sample_conditionsCategory>
      <PDBo:pdbx_nmr_exptl_sample_conditions rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_exptl_sample_conditionsCategory/PDBx:pdbx_nmr_exptl_sample_conditions[@conditions_id='{replace(@conditions_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_exptl_sample_conditions>
    </PDBo:pdbx_nmr_exptl_sample_conditionsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_force_constantsCategory/PDBx:pdbx_nmr_force_constants">
    <PDBo:pdbx_nmr_force_constantsCategory>
      <PDBo:pdbx_nmr_force_constants rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_force_constantsCategory/PDBx:pdbx_nmr_force_constants[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_55_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_force_constants>
    </PDBo:pdbx_nmr_force_constantsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_refineCategory/PDBx:pdbx_nmr_refine">
    <PDBo:pdbx_nmr_refineCategory>
      <PDBo:pdbx_nmr_refine rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_refineCategory/PDBx:pdbx_nmr_refine[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_56_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_refine>
    </PDBo:pdbx_nmr_refineCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_representativeCategory/PDBx:pdbx_nmr_representative">
    <PDBo:pdbx_nmr_representativeCategory>
      <PDBo:pdbx_nmr_representative rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_representativeCategory/PDBx:pdbx_nmr_representative[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_57_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_representative>
    </PDBo:pdbx_nmr_representativeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_sample_detailsCategory/PDBx:pdbx_nmr_sample_details">
    <PDBo:pdbx_nmr_sample_detailsCategory>
      <PDBo:pdbx_nmr_sample_details rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_sample_detailsCategory/PDBx:pdbx_nmr_sample_details[@solution_id='{replace(@solution_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_sample_details>
    </PDBo:pdbx_nmr_sample_detailsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_softwareCategory/PDBx:pdbx_nmr_software">
    <PDBo:pdbx_nmr_softwareCategory>
      <PDBo:pdbx_nmr_software rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_softwareCategory/PDBx:pdbx_nmr_software[@ordinal='{replace(@ordinal,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_software>
    </PDBo:pdbx_nmr_softwareCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nmr_spectrometerCategory/PDBx:pdbx_nmr_spectrometer">
    <PDBo:pdbx_nmr_spectrometerCategory>
      <PDBo:pdbx_nmr_spectrometer rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nmr_spectrometerCategory/PDBx:pdbx_nmr_spectrometer[@spectrometer_id='{replace(@spectrometer_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nmr_spectrometer>
    </PDBo:pdbx_nmr_spectrometerCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_nonpoly_schemeCategory/PDBx:pdbx_nonpoly_scheme">
    <PDBo:pdbx_nonpoly_schemeCategory>
      <PDBo:pdbx_nonpoly_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_nonpoly_schemeCategory/PDBx:pdbx_nonpoly_scheme[@asym_id='{replace(@asym_id,' +','%20')}'%20and%20@ndb_seq_num='{replace(@ndb_seq_num,' +','%20')}']">
      <xsl2:if test="@asym_id!='' and PDBx:entity_id!='' and PDBx:mon_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@label_asym_id='{replace(@asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:entity_id,' +','%20')}'%20and%20@label_entity_id='{replace(PDBx:mon_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_10_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_nonpoly_scheme>
    </PDBo:pdbx_nonpoly_schemeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_phasing_MAD_setCategory/PDBx:pdbx_phasing_MAD_set">
    <PDBo:pdbx_phasing_MAD_setCategory>
      <PDBo:pdbx_phasing_MAD_set rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_phasing_MAD_setCategory/PDBx:pdbx_phasing_MAD_set[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_phasing_MAD_set>
    </PDBo:pdbx_phasing_MAD_setCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_phasing_MAD_set_shellCategory/PDBx:pdbx_phasing_MAD_set_shell">
    <PDBo:pdbx_phasing_MAD_set_shellCategory>
      <PDBo:pdbx_phasing_MAD_set_shell rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_phasing_MAD_set_shellCategory/PDBx:pdbx_phasing_MAD_set_shell[@d_res_high='{replace(@d_res_high,' +','%20')}'%20and%20@d_res_low='{replace(@d_res_low,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_phasing_MAD_set_shell>
    </PDBo:pdbx_phasing_MAD_set_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_phasing_MAD_set_siteCategory/PDBx:pdbx_phasing_MAD_set_site">
    <PDBo:pdbx_phasing_MAD_set_siteCategory>
      <PDBo:pdbx_phasing_MAD_set_site rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_phasing_MAD_set_siteCategory/PDBx:pdbx_phasing_MAD_set_site[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_phasing_MAD_set_site>
    </PDBo:pdbx_phasing_MAD_set_siteCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_phasing_MAD_shellCategory/PDBx:pdbx_phasing_MAD_shell">
    <PDBo:pdbx_phasing_MAD_shellCategory>
      <PDBo:pdbx_phasing_MAD_shell rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_phasing_MAD_shellCategory/PDBx:pdbx_phasing_MAD_shell[@d_res_high='{replace(@d_res_high,' +','%20')}'%20and%20@d_res_low='{replace(@d_res_low,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_phasing_MAD_shell>
    </PDBo:pdbx_phasing_MAD_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_phasing_MRCategory/PDBx:pdbx_phasing_MR">
    <PDBo:pdbx_phasing_MRCategory>
      <PDBo:pdbx_phasing_MR rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_phasing_MRCategory/PDBx:pdbx_phasing_MR[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="PDBx:native_set_id!=''">
        <PDBo:reference_to_phasing_set>
          <PDBo:phasing_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set[@id='{replace(PDBx:native_set_id,' +','%20')}']">
            <rdfs:label>phasing_setKeyref_1_0_0</rdfs:label>
          </PDBo:phasing_set>
        </PDBo:reference_to_phasing_set>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_phasing_MR>
    </PDBo:pdbx_phasing_MRCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_phasing_dmCategory/PDBx:pdbx_phasing_dm">
    <PDBo:pdbx_phasing_dmCategory>
      <PDBo:pdbx_phasing_dm rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_phasing_dmCategory/PDBx:pdbx_phasing_dm[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_phasing_dm>
    </PDBo:pdbx_phasing_dmCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_phasing_dm_shellCategory/PDBx:pdbx_phasing_dm_shell">
    <PDBo:pdbx_phasing_dm_shellCategory>
      <PDBo:pdbx_phasing_dm_shell rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_phasing_dm_shellCategory/PDBx:pdbx_phasing_dm_shell[@d_res_high='{replace(@d_res_high,' +','%20')}'%20and%20@d_res_low='{replace(@d_res_low,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_phasing_dm_shell>
    </PDBo:pdbx_phasing_dm_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_point_symmetryCategory/PDBx:pdbx_point_symmetry">
    <PDBo:pdbx_point_symmetryCategory>
      <PDBo:pdbx_point_symmetry rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_point_symmetryCategory/PDBx:pdbx_point_symmetry[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_58_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_point_symmetry>
    </PDBo:pdbx_point_symmetryCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme">
    <PDBo:pdbx_poly_seq_schemeCategory>
      <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@asym_id='{replace(@asym_id,' +','%20')}'%20and%20@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@mon_id='{replace(@mon_id,' +','%20')}'%20and%20@seq_id='{replace(@seq_id,' +','%20')}']">
      <xsl2:if test="@asym_id!=''">
        <rdfs:sameAs>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@asym_id='{replace(@asym_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKey_1</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@asym_id!='' and @auth_seq_num!='' and @mon_id!='' and @pdb_ins_code!='' and @pdb_strand_id!='' and @seq_id!=''">
        <rdfs:sameAs>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@asym_id='{replace(@asym_id,' +','%20')}'%20and%20@auth_seq_num='{replace(@auth_seq_num,' +','%20')}'%20and%20@mon_id='{replace(@mon_id,' +','%20')}'%20and%20@pdb_ins_code='{replace(@pdb_ins_code,' +','%20')}'%20and%20@pdb_strand_id='{replace(@pdb_strand_id,' +','%20')}'%20and%20@seq_id='{replace(@seq_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKey_2</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@pdb_ins_code!='' and @pdb_seq_num!='' and @pdb_strand_id!=''">
        <rdfs:sameAs>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@pdb_ins_code='{replace(@pdb_ins_code,' +','%20')}'%20and%20@pdb_seq_num='{replace(@pdb_seq_num,' +','%20')}'%20and%20@pdb_strand_id='{replace(@pdb_strand_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKey_3</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entity_id!='' and PDBx:hetero!='' and @mon_id!='' and @seq_id!=''">
        <PDBo:reference_to_entity_poly_seq>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@hetero='{replace(PDBx:hetero,' +','%20')}'%20and%20@mon_id='{replace(@mon_id,' +','%20')}'%20and%20@num='{replace(@seq_id,' +','%20')}']">
            <rdfs:label>entity_poly_seqKeyref_2_0_0</rdfs:label>
          </PDBo:entity_poly_seq>
        </PDBo:reference_to_entity_poly_seq>
      </xsl2:if>
      <xsl2:if test="@asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(@asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_2_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_poly_seq_scheme>
    </PDBo:pdbx_poly_seq_schemeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_prerelease_seqCategory/PDBx:pdbx_prerelease_seq">
    <PDBo:pdbx_prerelease_seqCategory>
      <PDBo:pdbx_prerelease_seq rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_prerelease_seqCategory/PDBx:pdbx_prerelease_seq[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_28_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_prerelease_seq>
    </PDBo:pdbx_prerelease_seqCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_re_refinementCategory/PDBx:pdbx_re_refinement">
    <PDBo:pdbx_re_refinementCategory>
      <PDBo:pdbx_re_refinement rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_re_refinementCategory/PDBx:pdbx_re_refinement[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_re_refinement>
    </PDBo:pdbx_re_refinementCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity">
    <PDBo:pdbx_reference_entityCategory>
      <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity>
    </PDBo:pdbx_reference_entityCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entity_annotationCategory/PDBx:pdbx_reference_entity_annotation">
    <PDBo:pdbx_reference_entity_annotationCategory>
      <PDBo:pdbx_reference_entity_annotation rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entity_annotationCategory/PDBx:pdbx_reference_entity_annotation[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@text='{replace(@text,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_pdbx_reference_entity>
          <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>pdbx_reference_entityKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_reference_entity>
        </PDBo:reference_to_pdbx_reference_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity_annotation>
    </PDBo:pdbx_reference_entity_annotationCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entity_componentsCategory/PDBx:pdbx_reference_entity_components">
    <PDBo:pdbx_reference_entity_componentsCategory>
      <PDBo:pdbx_reference_entity_components rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entity_componentsCategory/PDBx:pdbx_reference_entity_components[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@names='{replace(@names,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_pdbx_reference_entity>
          <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>pdbx_reference_entityKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_reference_entity>
        </PDBo:reference_to_pdbx_reference_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity_components>
    </PDBo:pdbx_reference_entity_componentsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entity_featureCategory/PDBx:pdbx_reference_entity_feature">
    <PDBo:pdbx_reference_entity_featureCategory>
      <PDBo:pdbx_reference_entity_feature rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entity_featureCategory/PDBx:pdbx_reference_entity_feature[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@source='{replace(@source,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}'%20and%20@value='{replace(@value,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_pdbx_reference_entity>
          <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>pdbx_reference_entityKeyref_1_2_0</rdfs:label>
          </PDBo:pdbx_reference_entity>
        </PDBo:reference_to_pdbx_reference_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity_feature>
    </PDBo:pdbx_reference_entity_featureCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entity_polyCategory/PDBx:pdbx_reference_entity_poly">
    <PDBo:pdbx_reference_entity_polyCategory>
      <PDBo:pdbx_reference_entity_poly rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entity_polyCategory/PDBx:pdbx_reference_entity_poly[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_pdbx_reference_entity>
          <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>pdbx_reference_entityKeyref_1_3_0</rdfs:label>
          </PDBo:pdbx_reference_entity>
        </PDBo:reference_to_pdbx_reference_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity_poly>
    </PDBo:pdbx_reference_entity_polyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entity_poly_seqCategory/PDBx:pdbx_reference_entity_poly_seq">
    <PDBo:pdbx_reference_entity_poly_seqCategory>
      <PDBo:pdbx_reference_entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entity_poly_seqCategory/PDBx:pdbx_reference_entity_poly_seq[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@mon_id='{replace(@mon_id,' +','%20')}'%20and%20@num='{replace(@num,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_pdbx_reference_entity>
          <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>pdbx_reference_entityKeyref_1_4_0</rdfs:label>
          </PDBo:pdbx_reference_entity>
        </PDBo:reference_to_pdbx_reference_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity_poly_seq>
    </PDBo:pdbx_reference_entity_poly_seqCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entity_src_natCategory/PDBx:pdbx_reference_entity_src_nat">
    <PDBo:pdbx_reference_entity_src_natCategory>
      <PDBo:pdbx_reference_entity_src_nat rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entity_src_natCategory/PDBx:pdbx_reference_entity_src_nat[@entity_id='{replace(@entity_id,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_pdbx_reference_entity>
          <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>pdbx_reference_entityKeyref_1_5_0</rdfs:label>
          </PDBo:pdbx_reference_entity>
        </PDBo:reference_to_pdbx_reference_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity_src_nat>
    </PDBo:pdbx_reference_entity_src_natCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reference_entity_synonymsCategory/PDBx:pdbx_reference_entity_synonyms">
    <PDBo:pdbx_reference_entity_synonymsCategory>
      <PDBo:pdbx_reference_entity_synonyms rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entity_synonymsCategory/PDBx:pdbx_reference_entity_synonyms[@entity_id='{replace(@entity_id,' +','%20')}'%20and%20@name='{replace(@name,' +','%20')}']">
      <xsl2:if test="@entity_id!=''">
        <PDBo:reference_to_pdbx_reference_entity>
          <PDBo:pdbx_reference_entity rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reference_entityCategory/PDBx:pdbx_reference_entity[@id='{replace(@entity_id,' +','%20')}']">
            <rdfs:label>pdbx_reference_entityKeyref_1_6_0</rdfs:label>
          </PDBo:pdbx_reference_entity>
        </PDBo:reference_to_pdbx_reference_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reference_entity_synonyms>
    </PDBo:pdbx_reference_entity_synonymsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_refineCategory/PDBx:pdbx_refine">
    <PDBo:pdbx_refineCategory>
      <PDBo:pdbx_refine rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refineCategory/PDBx:pdbx_refine[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_59_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_0_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_refine>
    </PDBo:pdbx_refineCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_refine_aux_fileCategory/PDBx:pdbx_refine_aux_file">
    <PDBo:pdbx_refine_aux_fileCategory>
      <PDBo:pdbx_refine_aux_file rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refine_aux_fileCategory/PDBx:pdbx_refine_aux_file[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}'%20and%20@serial_no='{replace(@serial_no,' +','%20')}']">
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_1_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_refine_aux_file>
    </PDBo:pdbx_refine_aux_fileCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_refine_componentCategory/PDBx:pdbx_refine_component">
    <PDBo:pdbx_refine_componentCategory>
      <PDBo:pdbx_refine_component rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refine_componentCategory/PDBx:pdbx_refine_component[@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
      <xsl2:if test="PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_refine_component>
    </PDBo:pdbx_refine_componentCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_refine_tlsCategory/PDBx:pdbx_refine_tls">
    <PDBo:pdbx_refine_tlsCategory>
      <PDBo:pdbx_refine_tls rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refine_tlsCategory/PDBx:pdbx_refine_tls[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(PDBx:pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_2_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_refine_tls>
    </PDBo:pdbx_refine_tlsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_refine_tls_groupCategory/PDBx:pdbx_refine_tls_group">
    <PDBo:pdbx_refine_tls_groupCategory>
      <PDBo:pdbx_refine_tls_group rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refine_tls_groupCategory/PDBx:pdbx_refine_tls_group[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:refine_tls_id!=''">
        <PDBo:reference_to_pdbx_refine_tls>
          <PDBo:pdbx_refine_tls rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_refine_tlsCategory/PDBx:pdbx_refine_tls[@id='{replace(PDBx:refine_tls_id,' +','%20')}']">
            <rdfs:label>pdbx_refine_tlsKeyref_1_2_0</rdfs:label>
          </PDBo:pdbx_refine_tls>
        </PDBo:reference_to_pdbx_refine_tls>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(PDBx:pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_3_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:if test="PDBx:beg_label_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:beg_label_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_3_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:if test="PDBx:end_label_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:end_label_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_3_1</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_refine_tls_group>
    </PDBo:pdbx_refine_tls_groupCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_reflns_twinCategory/PDBx:pdbx_reflns_twin">
    <PDBo:pdbx_reflns_twinCategory>
      <PDBo:pdbx_reflns_twin rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_reflns_twinCategory/PDBx:pdbx_reflns_twin[@crystal_id='{replace(@crystal_id,' +','%20')}'%20and%20@diffrn_id='{replace(@diffrn_id,' +','%20')}'%20and%20@operator='{replace(@operator,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_reflns_twin>
    </PDBo:pdbx_reflns_twinCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_remediation_atom_site_mappingCategory/PDBx:pdbx_remediation_atom_site_mapping">
    <PDBo:pdbx_remediation_atom_site_mappingCategory>
      <PDBo:pdbx_remediation_atom_site_mapping rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_remediation_atom_site_mappingCategory/PDBx:pdbx_remediation_atom_site_mapping[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:label_alt_id!='' and PDBx:label_asym_id!='' and PDBx:label_atom_id!='' and PDBx:label_comp_id!='' and PDBx:label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@label_alt_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:label_alt_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_11_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:auth_alt_id!='' and PDBx:auth_asym_id!='' and PDBx:auth_atom_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_alt_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(PDBx:auth_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_12_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_remediation_atom_site_mapping>
    </PDBo:pdbx_remediation_atom_site_mappingCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system">
    <PDBo:pdbx_robot_systemCategory>
      <PDBo:pdbx_robot_system rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_robot_systemCategory/PDBx:pdbx_robot_system[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_robot_system>
    </PDBo:pdbx_robot_systemCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_sequence_rangeCategory/PDBx:pdbx_sequence_range">
    <PDBo:pdbx_sequence_rangeCategory>
      <PDBo:pdbx_sequence_range rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_sequence_rangeCategory/PDBx:pdbx_sequence_range[@beg_label_alt_id='{replace(@beg_label_alt_id,' +','%20')}'%20and%20@beg_label_asym_id='{replace(@beg_label_asym_id,' +','%20')}'%20and%20@beg_label_comp_id='{replace(@beg_label_comp_id,' +','%20')}'%20and%20@beg_label_seq_id='{replace(@beg_label_seq_id,' +','%20')}'%20and%20@end_label_alt_id='{replace(@end_label_alt_id,' +','%20')}'%20and%20@end_label_asym_id='{replace(@end_label_asym_id,' +','%20')}'%20and%20@end_label_comp_id='{replace(@end_label_comp_id,' +','%20')}'%20and%20@end_label_seq_id='{replace(@end_label_seq_id,' +','%20')}'%20and%20@seq_range_id='{replace(@seq_range_id,' +','%20')}']">
      <xsl2:if test="@seq_range_id!=''">
        <rdfs:sameAs>
          <PDBo:pdbx_sequence_range rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_sequence_rangeCategory/PDBx:pdbx_sequence_range[@seq_range_id='{replace(@seq_range_id,' +','%20')}']">
            <rdfs:label>pdbx_sequence_rangeKey_1</rdfs:label>
          </PDBo:pdbx_sequence_range>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="PDBx:beg_auth_asym_id!='' and PDBx:beg_auth_comp_id!='' and PDBx:beg_auth_seq_id!='' and @beg_label_alt_id!='' and @beg_label_asym_id!='' and @beg_label_comp_id!='' and @beg_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:beg_auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@beg_label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@beg_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@beg_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@beg_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_3_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:end_auth_asym_id!='' and PDBx:end_auth_comp_id!='' and PDBx:end_auth_seq_id!='' and @end_label_alt_id!='' and @end_label_asym_id!='' and @end_label_comp_id!='' and @end_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:end_auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@end_label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@end_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@end_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@end_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_3_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_sequence_range>
    </PDBo:pdbx_sequence_rangeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_soln_scatterCategory/PDBx:pdbx_soln_scatter">
    <PDBo:pdbx_soln_scatterCategory>
      <PDBo:pdbx_soln_scatter rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_soln_scatterCategory/PDBx:pdbx_soln_scatter[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:pdbx_soln_scatter rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_soln_scatterCategory/PDBx:pdbx_soln_scatter[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>pdbx_soln_scatterKey_1</rdfs:label>
          </PDBo:pdbx_soln_scatter>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_60_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_soln_scatter>
    </PDBo:pdbx_soln_scatterCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_soln_scatter_modelCategory/PDBx:pdbx_soln_scatter_model">
    <PDBo:pdbx_soln_scatter_modelCategory>
      <PDBo:pdbx_soln_scatter_model rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_soln_scatter_modelCategory/PDBx:pdbx_soln_scatter_model[@id='{replace(@id,' +','%20')}'%20and%20@scatter_id='{replace(@scatter_id,' +','%20')}']">
      <xsl2:if test="@scatter_id!=''">
        <PDBo:reference_to_pdbx_soln_scatter>
          <PDBo:pdbx_soln_scatter rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_soln_scatterCategory/PDBx:pdbx_soln_scatter[@id='{replace(@scatter_id,' +','%20')}']">
            <rdfs:label>pdbx_soln_scatterKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_soln_scatter>
        </PDBo:reference_to_pdbx_soln_scatter>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_soln_scatter_model>
    </PDBo:pdbx_soln_scatter_modelCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_assemblyCategory/PDBx:pdbx_struct_assembly">
    <PDBo:pdbx_struct_assemblyCategory>
      <PDBo:pdbx_struct_assembly rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_assemblyCategory/PDBx:pdbx_struct_assembly[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_assembly>
    </PDBo:pdbx_struct_assemblyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_assembly_genCategory/PDBx:pdbx_struct_assembly_gen">
    <PDBo:pdbx_struct_assembly_genCategory>
      <PDBo:pdbx_struct_assembly_gen rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_assembly_genCategory/PDBx:pdbx_struct_assembly_gen[@assembly_id='{replace(@assembly_id,' +','%20')}'%20and%20@asym_id_list='{replace(@asym_id_list,' +','%20')}'%20and%20@oper_expression='{replace(@oper_expression,' +','%20')}']">
      <xsl2:if test="@assembly_id!=''">
        <PDBo:reference_to_pdbx_struct_assembly>
          <PDBo:pdbx_struct_assembly rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_assemblyCategory/PDBx:pdbx_struct_assembly[@id='{replace(@assembly_id,' +','%20')}']">
            <rdfs:label>pdbx_struct_assemblyKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_struct_assembly>
        </PDBo:reference_to_pdbx_struct_assembly>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_assembly_gen>
    </PDBo:pdbx_struct_assembly_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_assembly_propCategory/PDBx:pdbx_struct_assembly_prop">
    <PDBo:pdbx_struct_assembly_propCategory>
      <PDBo:pdbx_struct_assembly_prop rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_assembly_propCategory/PDBx:pdbx_struct_assembly_prop[@biol_id='{replace(@biol_id,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_assembly_prop>
    </PDBo:pdbx_struct_assembly_propCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_asym_genCategory/PDBx:pdbx_struct_asym_gen">
    <PDBo:pdbx_struct_asym_genCategory>
      <PDBo:pdbx_struct_asym_gen rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_asym_genCategory/PDBx:pdbx_struct_asym_gen[@entity_inst_id='{replace(@entity_inst_id,' +','%20')}'%20and%20@oper_expression='{replace(@oper_expression,' +','%20')}']">
      <xsl2:if test="@entity_inst_id!=''">
        <PDBo:reference_to_pdbx_struct_entity_inst>
          <PDBo:pdbx_struct_entity_inst rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_entity_instCategory/PDBx:pdbx_struct_entity_inst[@id='{replace(@entity_inst_id,' +','%20')}']">
            <rdfs:label>pdbx_struct_entity_instKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_struct_entity_inst>
        </PDBo:reference_to_pdbx_struct_entity_inst>
      </xsl2:if>
      <xsl2:if test="PDBx:asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_4_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_asym_gen>
    </PDBo:pdbx_struct_asym_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_chem_comp_diagnosticsCategory/PDBx:pdbx_struct_chem_comp_diagnostics">
    <PDBo:pdbx_struct_chem_comp_diagnosticsCategory>
      <PDBo:pdbx_struct_chem_comp_diagnostics rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_chem_comp_diagnosticsCategory/PDBx:pdbx_struct_chem_comp_diagnostics[@ordinal='{replace(@ordinal,' +','%20')}']">
      <xsl2:if test="PDBx:asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and PDBx:pdb_strand_id!='' and PDBx:seq_num!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdb_strand_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:seq_num,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_13_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_chem_comp_diagnostics>
    </PDBo:pdbx_struct_chem_comp_diagnosticsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_chem_comp_featureCategory/PDBx:pdbx_struct_chem_comp_feature">
    <PDBo:pdbx_struct_chem_comp_featureCategory>
      <PDBo:pdbx_struct_chem_comp_feature rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_chem_comp_featureCategory/PDBx:pdbx_struct_chem_comp_feature[@ordinal='{replace(@ordinal,' +','%20')}']">
      <xsl2:if test="PDBx:asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and PDBx:pdb_strand_id!='' and PDBx:seq_num!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdb_strand_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:seq_num,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_13_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_chem_comp_feature>
    </PDBo:pdbx_struct_chem_comp_featureCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_conn_angleCategory/PDBx:pdbx_struct_conn_angle">
    <PDBo:pdbx_struct_conn_angleCategory>
      <PDBo:pdbx_struct_conn_angle rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_conn_angleCategory/PDBx:pdbx_struct_conn_angle[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:ptnr1_PDB_ins_code!='' and PDBx:ptnr1_auth_asym_id!='' and PDBx:ptnr1_auth_atom_id!='' and PDBx:ptnr1_auth_comp_id!='' and PDBx:ptnr1_auth_seq_id!='' and PDBx:ptnr1_label_alt_id!='' and PDBx:ptnr1_label_asym_id!='' and PDBx:ptnr1_label_atom_id!='' and PDBx:ptnr1_label_comp_id!='' and PDBx:ptnr1_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:ptnr1_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:ptnr1_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:ptnr1_auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:ptnr1_auth_comp_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:ptnr1_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:ptnr1_label_alt_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:ptnr1_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:ptnr1_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:ptnr1_label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:ptnr1_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_14_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:ptnr2_PDB_ins_code!='' and PDBx:ptnr2_auth_asym_id!='' and PDBx:ptnr2_auth_atom_id!='' and PDBx:ptnr2_auth_comp_id!='' and PDBx:ptnr2_auth_seq_id!='' and PDBx:ptnr2_label_alt_id!='' and PDBx:ptnr2_label_asym_id!='' and PDBx:ptnr2_label_atom_id!='' and PDBx:ptnr2_label_comp_id!='' and PDBx:ptnr2_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:ptnr2_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:ptnr2_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:ptnr2_auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:ptnr2_auth_comp_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:ptnr2_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:ptnr2_label_alt_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:ptnr2_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:ptnr2_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:ptnr2_label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:ptnr2_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_14_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:ptnr3_PDB_ins_code!='' and PDBx:ptnr3_auth_asym_id!='' and PDBx:ptnr3_auth_atom_id!='' and PDBx:ptnr3_auth_comp_id!='' and PDBx:ptnr3_auth_seq_id!='' and PDBx:ptnr3_label_alt_id!='' and PDBx:ptnr3_label_asym_id!='' and PDBx:ptnr3_label_atom_id!='' and PDBx:ptnr3_label_comp_id!='' and PDBx:ptnr3_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:ptnr3_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:ptnr3_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:ptnr3_auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:ptnr3_auth_comp_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:ptnr3_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:ptnr3_label_alt_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:ptnr3_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:ptnr3_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:ptnr3_label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:ptnr3_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_14_0_2</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_conn_angle>
    </PDBo:pdbx_struct_conn_angleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_entity_instCategory/PDBx:pdbx_struct_entity_inst">
    <PDBo:pdbx_struct_entity_instCategory>
      <PDBo:pdbx_struct_entity_inst rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_entity_instCategory/PDBx:pdbx_struct_entity_inst[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_29_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_entity_inst>
    </PDBo:pdbx_struct_entity_instCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_infoCategory/PDBx:pdbx_struct_info">
    <PDBo:pdbx_struct_infoCategory>
      <PDBo:pdbx_struct_info rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_infoCategory/PDBx:pdbx_struct_info[@type='{replace(@type,' +','%20')}'%20and%20@value='{replace(@value,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_info>
    </PDBo:pdbx_struct_infoCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_legacy_oper_listCategory/PDBx:pdbx_struct_legacy_oper_list">
    <PDBo:pdbx_struct_legacy_oper_listCategory>
      <PDBo:pdbx_struct_legacy_oper_list rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_legacy_oper_listCategory/PDBx:pdbx_struct_legacy_oper_list[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_legacy_oper_list>
    </PDBo:pdbx_struct_legacy_oper_listCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_mod_residueCategory/PDBx:pdbx_struct_mod_residue">
    <PDBo:pdbx_struct_mod_residueCategory>
      <PDBo:pdbx_struct_mod_residue rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_mod_residueCategory/PDBx:pdbx_struct_mod_residue[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and PDBx:label_asym_id!='' and PDBx:label_comp_id!='' and PDBx:label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:label_asym_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_15_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_mod_residue>
    </PDBo:pdbx_struct_mod_residueCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_msym_genCategory/PDBx:pdbx_struct_msym_gen">
    <PDBo:pdbx_struct_msym_genCategory>
      <PDBo:pdbx_struct_msym_gen rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_msym_genCategory/PDBx:pdbx_struct_msym_gen[@entity_inst_id='{replace(@entity_inst_id,' +','%20')}'%20and%20@msym_id='{replace(@msym_id,' +','%20')}'%20and%20@oper_expression='{replace(@oper_expression,' +','%20')}']">
      <xsl2:if test="@entity_inst_id!=''">
        <PDBo:reference_to_pdbx_struct_entity_inst>
          <PDBo:pdbx_struct_entity_inst rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_entity_instCategory/PDBx:pdbx_struct_entity_inst[@id='{replace(@entity_inst_id,' +','%20')}']">
            <rdfs:label>pdbx_struct_entity_instKeyref_1_1_0</rdfs:label>
          </PDBo:pdbx_struct_entity_inst>
        </PDBo:reference_to_pdbx_struct_entity_inst>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_msym_gen>
    </PDBo:pdbx_struct_msym_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_oper_listCategory/PDBx:pdbx_struct_oper_list">
    <PDBo:pdbx_struct_oper_listCategory>
      <PDBo:pdbx_struct_oper_list rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_oper_listCategory/PDBx:pdbx_struct_oper_list[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_oper_list>
    </PDBo:pdbx_struct_oper_listCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_ref_seq_deletionCategory/PDBx:pdbx_struct_ref_seq_deletion">
    <PDBo:pdbx_struct_ref_seq_deletionCategory>
      <PDBo:pdbx_struct_ref_seq_deletion rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_ref_seq_deletionCategory/PDBx:pdbx_struct_ref_seq_deletion[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:asym_id!=''">
        <PDBo:reference_to_pdbx_poly_seq_scheme>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@asym_id='{replace(PDBx:asym_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </PDBo:reference_to_pdbx_poly_seq_scheme>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_ref_seq_deletion>
    </PDBo:pdbx_struct_ref_seq_deletionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_ref_seq_featureCategory/PDBx:pdbx_struct_ref_seq_feature">
    <PDBo:pdbx_struct_ref_seq_featureCategory>
      <PDBo:pdbx_struct_ref_seq_feature rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_ref_seq_featureCategory/PDBx:pdbx_struct_ref_seq_feature[@feature_id='{replace(@feature_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_ref_seq_feature>
    </PDBo:pdbx_struct_ref_seq_featureCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_ref_seq_feature_propCategory/PDBx:pdbx_struct_ref_seq_feature_prop">
    <PDBo:pdbx_struct_ref_seq_feature_propCategory>
      <PDBo:pdbx_struct_ref_seq_feature_prop rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_ref_seq_feature_propCategory/PDBx:pdbx_struct_ref_seq_feature_prop[@feature_id='{replace(@feature_id,' +','%20')}'%20and%20@property_id='{replace(@property_id,' +','%20')}']">
      <xsl2:if test="@feature_id!=''">
        <PDBo:reference_to_pdbx_struct_ref_seq_feature>
          <PDBo:pdbx_struct_ref_seq_feature rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_ref_seq_featureCategory/PDBx:pdbx_struct_ref_seq_feature[@feature_id='{replace(@feature_id,' +','%20')}']">
            <rdfs:label>pdbx_struct_ref_seq_featureKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_struct_ref_seq_feature>
        </PDBo:reference_to_pdbx_struct_ref_seq_feature>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_ref_seq_feature_prop>
    </PDBo:pdbx_struct_ref_seq_feature_propCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_ref_seq_insertionCategory/PDBx:pdbx_struct_ref_seq_insertion">
    <PDBo:pdbx_struct_ref_seq_insertionCategory>
      <PDBo:pdbx_struct_ref_seq_insertion rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_ref_seq_insertionCategory/PDBx:pdbx_struct_ref_seq_insertion[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:asym_id!='' and PDBx:auth_asym_id!='' and PDBx:auth_seq_id!='' and PDBx:comp_id!='' and PDBx:seq_id!=''">
        <PDBo:reference_to_pdbx_poly_seq_scheme>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_seq_num='{replace(PDBx:asym_id,' +','%20')}'%20and%20@mon_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@pdb_ins_code='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@pdb_strand_id='{replace(PDBx:comp_id,' +','%20')}'%20and%20@seq_id='{replace(PDBx:seq_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKeyref_2_0_0</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </PDBo:reference_to_pdbx_poly_seq_scheme>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_ref_seq_insertion>
    </PDBo:pdbx_struct_ref_seq_insertionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_struct_sheet_hbondCategory/PDBx:pdbx_struct_sheet_hbond">
    <PDBo:pdbx_struct_sheet_hbondCategory>
      <PDBo:pdbx_struct_sheet_hbond rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_struct_sheet_hbondCategory/PDBx:pdbx_struct_sheet_hbond[@range_id_1='{replace(@range_id_1,' +','%20')}'%20and%20@range_id_2='{replace(@range_id_2,' +','%20')}'%20and%20@sheet_id='{replace(@sheet_id,' +','%20')}']">
      <xsl2:if test="PDBx:range_1_PDB_ins_code!='' and PDBx:range_1_auth_asym_id!='' and PDBx:range_1_auth_atom_id!='' and PDBx:range_1_auth_comp_id!='' and PDBx:range_1_auth_seq_id!='' and PDBx:range_1_label_asym_id!='' and PDBx:range_1_label_atom_id!='' and PDBx:range_1_label_comp_id!='' and PDBx:range_1_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:range_1_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:range_1_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:range_1_auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:range_1_auth_comp_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:range_1_auth_seq_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_1_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_1_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_1_label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_1_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_16_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:range_2_PDB_ins_code!='' and PDBx:range_2_auth_asym_id!='' and PDBx:range_2_auth_atom_id!='' and PDBx:range_2_auth_comp_id!='' and PDBx:range_2_auth_seq_id!='' and PDBx:range_2_label_asym_id!='' and PDBx:range_2_label_atom_id!='' and PDBx:range_2_label_comp_id!='' and PDBx:range_2_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:range_2_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:range_2_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:range_2_auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:range_2_auth_comp_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:range_2_auth_seq_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_2_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_2_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_2_label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_2_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_16_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:range_1_PDB_ins_code!='' and PDBx:range_1_auth_asym_id!='' and PDBx:range_1_auth_atom_id!='' and PDBx:range_1_auth_comp_id!='' and PDBx:range_1_auth_seq_id!='' and PDBx:range_1_label_asym_id!='' and PDBx:range_1_label_atom_id!='' and PDBx:range_1_label_comp_id!='' and PDBx:range_1_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:range_1_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:range_1_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:range_1_auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:range_1_auth_comp_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:range_1_auth_seq_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_1_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_1_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_1_label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_1_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_30_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:range_2_PDB_ins_code!='' and PDBx:range_2_auth_asym_id!='' and PDBx:range_2_auth_atom_id!='' and PDBx:range_2_auth_comp_id!='' and PDBx:range_2_auth_seq_id!='' and PDBx:range_2_label_asym_id!='' and PDBx:range_2_label_atom_id!='' and PDBx:range_2_label_comp_id!='' and PDBx:range_2_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:range_2_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:range_2_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:range_2_auth_atom_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:range_2_auth_comp_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:range_2_auth_seq_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_2_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_2_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_2_label_comp_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_2_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_30_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="@sheet_id!=''">
        <PDBo:reference_to_struct_sheet>
          <PDBo:struct_sheet rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheetCategory/PDBx:struct_sheet[@id='{replace(@sheet_id,' +','%20')}']">
            <rdfs:label>struct_sheetKeyref_1_0_0</rdfs:label>
          </PDBo:struct_sheet>
        </PDBo:reference_to_struct_sheet>
      </xsl2:if>
      <xsl2:if test="@range_id_1!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_1,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_0_0</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:if test="@range_id_2!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_2,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_0_1</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_struct_sheet_hbond>
    </PDBo:pdbx_struct_sheet_hbondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_unobs_or_zero_occ_atomsCategory/PDBx:pdbx_unobs_or_zero_occ_atoms">
    <PDBo:pdbx_unobs_or_zero_occ_atomsCategory>
      <PDBo:pdbx_unobs_or_zero_occ_atoms rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_unobs_or_zero_occ_atomsCategory/PDBx:pdbx_unobs_or_zero_occ_atoms[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_model_num!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@pdbx_PDB_model_num='{replace(PDBx:PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_17_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:auth_comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(PDBx:auth_comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_13_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:label_comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(PDBx:label_comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_13_1</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:label_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:label_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_5_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_unobs_or_zero_occ_atoms>
    </PDBo:pdbx_unobs_or_zero_occ_atomsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_unobs_or_zero_occ_residuesCategory/PDBx:pdbx_unobs_or_zero_occ_residues">
    <PDBo:pdbx_unobs_or_zero_occ_residuesCategory>
      <PDBo:pdbx_unobs_or_zero_occ_residues rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_unobs_or_zero_occ_residuesCategory/PDBx:pdbx_unobs_or_zero_occ_residues[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_model_num!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@pdbx_PDB_model_num='{replace(PDBx:PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_17_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:auth_comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(PDBx:auth_comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_14_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:label_comp_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(PDBx:label_comp_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_14_1</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:label_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:label_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_6_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_unobs_or_zero_occ_residues>
    </PDBo:pdbx_unobs_or_zero_occ_residuesCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_chiralCategory/PDBx:pdbx_validate_chiral">
    <PDBo:pdbx_validate_chiralCategory>
      <PDBo:pdbx_validate_chiral rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_chiralCategory/PDBx:pdbx_validate_chiral[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:auth_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_18_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_chiral>
    </PDBo:pdbx_validate_chiralCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_close_contactCategory/PDBx:pdbx_validate_close_contact">
    <PDBo:pdbx_validate_close_contactCategory>
      <PDBo:pdbx_validate_close_contact rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_close_contactCategory/PDBx:pdbx_validate_close_contact[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code_1!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id_1!='' and PDBx:auth_atom_id_1!='' and PDBx:auth_comp_id_1!='' and PDBx:auth_seq_id_1!='' and PDBx:label_alt_id_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_asym_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_atom_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_comp_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:label_alt_id_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_19_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:PDB_ins_code_2!='' and PDBx:auth_asym_id_2!='' and PDBx:auth_atom_id_2!='' and PDBx:auth_comp_id_2!='' and PDBx:auth_seq_id_2!='' and PDBx:label_alt_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_asym_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_atom_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_comp_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_alt_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_20_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_close_contact>
    </PDBo:pdbx_validate_close_contactCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_main_chain_planeCategory/PDBx:pdbx_validate_main_chain_plane">
    <PDBo:pdbx_validate_main_chain_planeCategory>
      <PDBo:pdbx_validate_main_chain_plane rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_main_chain_planeCategory/PDBx:pdbx_validate_main_chain_plane[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:auth_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_18_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_main_chain_plane>
    </PDBo:pdbx_validate_main_chain_planeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_peptide_omegaCategory/PDBx:pdbx_validate_peptide_omega">
    <PDBo:pdbx_validate_peptide_omegaCategory>
      <PDBo:pdbx_validate_peptide_omega rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_peptide_omegaCategory/PDBx:pdbx_validate_peptide_omega[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code_1!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id_1!='' and PDBx:auth_comp_id_1!='' and PDBx:auth_seq_id_1!='' and PDBx:label_alt_id_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_1,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_asym_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_comp_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:label_alt_id_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_21_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:PDB_ins_code_2!='' and PDBx:auth_asym_id_2!='' and PDBx:auth_comp_id_2!='' and PDBx:auth_seq_id_2!='' and PDBx:label_alt_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_asym_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_comp_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_alt_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_22_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_peptide_omega>
    </PDBo:pdbx_validate_peptide_omegaCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_planesCategory/PDBx:pdbx_validate_planes">
    <PDBo:pdbx_validate_planesCategory>
      <PDBo:pdbx_validate_planes rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_planesCategory/PDBx:pdbx_validate_planes[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:auth_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_18_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_planes>
    </PDBo:pdbx_validate_planesCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_planes_atomCategory/PDBx:pdbx_validate_planes_atom">
    <PDBo:pdbx_validate_planes_atomCategory>
      <PDBo:pdbx_validate_planes_atom rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_planes_atomCategory/PDBx:pdbx_validate_planes_atom[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id!='' and PDBx:auth_atom_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:auth_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_23_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:plane_id!=''">
        <PDBo:reference_to_pdbx_validate_planes>
          <PDBo:pdbx_validate_planes rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_planesCategory/PDBx:pdbx_validate_planes[@id='{replace(PDBx:plane_id,' +','%20')}']">
            <rdfs:label>pdbx_validate_planesKeyref_1_0_0</rdfs:label>
          </PDBo:pdbx_validate_planes>
        </PDBo:reference_to_pdbx_validate_planes>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_planes_atom>
    </PDBo:pdbx_validate_planes_atomCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_rmsd_angleCategory/PDBx:pdbx_validate_rmsd_angle">
    <PDBo:pdbx_validate_rmsd_angleCategory>
      <PDBo:pdbx_validate_rmsd_angle rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_rmsd_angleCategory/PDBx:pdbx_validate_rmsd_angle[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code_1!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id_1!='' and PDBx:auth_atom_id_1!='' and PDBx:auth_comp_id_1!='' and PDBx:auth_seq_id_1!='' and PDBx:label_alt_id_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_asym_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_atom_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_comp_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:label_alt_id_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_19_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:PDB_ins_code_2!='' and PDBx:auth_asym_id_2!='' and PDBx:auth_atom_id_2!='' and PDBx:auth_comp_id_2!='' and PDBx:auth_seq_id_2!='' and PDBx:label_alt_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_asym_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_atom_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_comp_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_alt_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_20_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:PDB_ins_code_3!='' and PDBx:auth_asym_id_3!='' and PDBx:auth_atom_id_3!='' and PDBx:auth_comp_id_3!='' and PDBx:auth_seq_id_3!='' and PDBx:label_alt_id_3!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_3,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_asym_id_3,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_atom_id_3,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_comp_id_3,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_seq_id_3,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_alt_id_3,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_20_1_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_rmsd_angle>
    </PDBo:pdbx_validate_rmsd_angleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_rmsd_bondCategory/PDBx:pdbx_validate_rmsd_bond">
    <PDBo:pdbx_validate_rmsd_bondCategory>
      <PDBo:pdbx_validate_rmsd_bond rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_rmsd_bondCategory/PDBx:pdbx_validate_rmsd_bond[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code_1!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id_1!='' and PDBx:auth_atom_id_1!='' and PDBx:auth_comp_id_1!='' and PDBx:auth_seq_id_1!='' and PDBx:label_alt_id_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_asym_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_atom_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_comp_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:label_alt_id_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_19_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:PDB_ins_code_2!='' and PDBx:auth_asym_id_2!='' and PDBx:auth_atom_id_2!='' and PDBx:auth_comp_id_2!='' and PDBx:auth_seq_id_2!='' and PDBx:label_alt_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_asym_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_atom_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_comp_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_alt_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_20_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_rmsd_bond>
    </PDBo:pdbx_validate_rmsd_bondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_symm_contactCategory/PDBx:pdbx_validate_symm_contact">
    <PDBo:pdbx_validate_symm_contactCategory>
      <PDBo:pdbx_validate_symm_contact rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_symm_contactCategory/PDBx:pdbx_validate_symm_contact[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code_1!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id_1!='' and PDBx:auth_atom_id_1!='' and PDBx:auth_comp_id_1!='' and PDBx:auth_seq_id_1!='' and PDBx:label_alt_id_1!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_1,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_asym_id_1,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_atom_id_1,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_comp_id_1,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_seq_id_1,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:label_alt_id_1,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_19_3_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:PDB_ins_code_2!='' and PDBx:auth_asym_id_2!='' and PDBx:auth_atom_id_2!='' and PDBx:auth_comp_id_2!='' and PDBx:auth_seq_id_2!='' and PDBx:label_alt_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code_2,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_asym_id_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_atom_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_comp_id_2,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:auth_seq_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:label_alt_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_20_3_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_symm_contact>
    </PDBo:pdbx_validate_symm_contactCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_validate_torsionCategory/PDBx:pdbx_validate_torsion">
    <PDBo:pdbx_validate_torsionCategory>
      <PDBo:pdbx_validate_torsion rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_validate_torsionCategory/PDBx:pdbx_validate_torsion[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:PDB_ins_code!='' and PDBx:PDB_model_num!='' and PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:PDB_ins_code,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:PDB_model_num,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:auth_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_18_3_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_validate_torsion>
    </PDBo:pdbx_validate_torsionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_versionCategory/PDBx:pdbx_version">
    <PDBo:pdbx_versionCategory>
      <PDBo:pdbx_version rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_versionCategory/PDBx:pdbx_version[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@major_version='{replace(@major_version,' +','%20')}'%20and%20@minor_version='{replace(@minor_version,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_61_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_version>
    </PDBo:pdbx_versionCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:pdbx_xplor_fileCategory/PDBx:pdbx_xplor_file">
    <PDBo:pdbx_xplor_fileCategory>
      <PDBo:pdbx_xplor_file rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_xplor_fileCategory/PDBx:pdbx_xplor_file[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}'%20and%20@serial_no='{replace(@serial_no,' +','%20')}']">
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_4_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:pdbx_xplor_file>
    </PDBo:pdbx_xplor_fileCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasingCategory/PDBx:phasing">
    <PDBo:phasingCategory>
      <PDBo:phasing rdf:about="{$base}/PDBx:datablock/PDBx:phasingCategory/PDBx:phasing[@method='{replace(@method,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing>
    </PDBo:phasingCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MADCategory/PDBx:phasing_MAD">
    <PDBo:phasing_MADCategory>
      <PDBo:phasing_MAD rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MADCategory/PDBx:phasing_MAD[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_62_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MAD>
    </PDBo:phasing_MADCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MAD_clustCategory/PDBx:phasing_MAD_clust">
    <PDBo:phasing_MAD_clustCategory>
      <PDBo:phasing_MAD_clust rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_clustCategory/PDBx:phasing_MAD_clust[@expt_id='{replace(@expt_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:phasing_MAD_clust rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_clustCategory/PDBx:phasing_MAD_clust[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>phasing_MAD_clustKey_1</rdfs:label>
          </PDBo:phasing_MAD_clust>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@expt_id!=''">
        <PDBo:reference_to_phasing_MAD_expt>
          <PDBo:phasing_MAD_expt rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_exptCategory/PDBx:phasing_MAD_expt[@id='{replace(@expt_id,' +','%20')}']">
            <rdfs:label>phasing_MAD_exptKeyref_1_0_0</rdfs:label>
          </PDBo:phasing_MAD_expt>
        </PDBo:reference_to_phasing_MAD_expt>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MAD_clust>
    </PDBo:phasing_MAD_clustCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MAD_exptCategory/PDBx:phasing_MAD_expt">
    <PDBo:phasing_MAD_exptCategory>
      <PDBo:phasing_MAD_expt rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_exptCategory/PDBx:phasing_MAD_expt[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MAD_expt>
    </PDBo:phasing_MAD_exptCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MAD_ratioCategory/PDBx:phasing_MAD_ratio">
    <PDBo:phasing_MAD_ratioCategory>
      <PDBo:phasing_MAD_ratio rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_ratioCategory/PDBx:phasing_MAD_ratio[@clust_id='{replace(@clust_id,' +','%20')}'%20and%20@expt_id='{replace(@expt_id,' +','%20')}'%20and%20@wavelength_1='{replace(@wavelength_1,' +','%20')}'%20and%20@wavelength_2='{replace(@wavelength_2,' +','%20')}']">
      <xsl2:if test="@clust_id!=''">
        <PDBo:reference_to_phasing_MAD_clust>
          <PDBo:phasing_MAD_clust rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_clustCategory/PDBx:phasing_MAD_clust[@id='{replace(@clust_id,' +','%20')}']">
            <rdfs:label>phasing_MAD_clustKeyref_1_0_0</rdfs:label>
          </PDBo:phasing_MAD_clust>
        </PDBo:reference_to_phasing_MAD_clust>
      </xsl2:if>
      <xsl2:if test="@expt_id!=''">
        <PDBo:reference_to_phasing_MAD_expt>
          <PDBo:phasing_MAD_expt rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_exptCategory/PDBx:phasing_MAD_expt[@id='{replace(@expt_id,' +','%20')}']">
            <rdfs:label>phasing_MAD_exptKeyref_1_1_0</rdfs:label>
          </PDBo:phasing_MAD_expt>
        </PDBo:reference_to_phasing_MAD_expt>
      </xsl2:if>
      <xsl2:if test="@wavelength_1!=''">
        <PDBo:reference_to_phasing_MAD_set>
          <PDBo:phasing_MAD_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_setCategory/PDBx:phasing_MAD_set[@wavelength='{replace(@wavelength_1,' +','%20')}']">
            <rdfs:label>phasing_MAD_setKeyref_1_0_0</rdfs:label>
          </PDBo:phasing_MAD_set>
        </PDBo:reference_to_phasing_MAD_set>
      </xsl2:if>
      <xsl2:if test="@wavelength_2!=''">
        <PDBo:reference_to_phasing_MAD_set>
          <PDBo:phasing_MAD_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_setCategory/PDBx:phasing_MAD_set[@wavelength='{replace(@wavelength_2,' +','%20')}']">
            <rdfs:label>phasing_MAD_setKeyref_1_0_1</rdfs:label>
          </PDBo:phasing_MAD_set>
        </PDBo:reference_to_phasing_MAD_set>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MAD_ratio>
    </PDBo:phasing_MAD_ratioCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MAD_setCategory/PDBx:phasing_MAD_set">
    <PDBo:phasing_MAD_setCategory>
      <PDBo:phasing_MAD_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_setCategory/PDBx:phasing_MAD_set[@clust_id='{replace(@clust_id,' +','%20')}'%20and%20@expt_id='{replace(@expt_id,' +','%20')}'%20and%20@set_id='{replace(@set_id,' +','%20')}'%20and%20@wavelength='{replace(@wavelength,' +','%20')}']">
      <xsl2:if test="@wavelength!=''">
        <rdfs:sameAs>
          <PDBo:phasing_MAD_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_setCategory/PDBx:phasing_MAD_set[@wavelength='{replace(@wavelength,' +','%20')}']">
            <rdfs:label>phasing_MAD_setKey_1</rdfs:label>
          </PDBo:phasing_MAD_set>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@clust_id!=''">
        <PDBo:reference_to_phasing_MAD_clust>
          <PDBo:phasing_MAD_clust rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_clustCategory/PDBx:phasing_MAD_clust[@id='{replace(@clust_id,' +','%20')}']">
            <rdfs:label>phasing_MAD_clustKeyref_1_1_0</rdfs:label>
          </PDBo:phasing_MAD_clust>
        </PDBo:reference_to_phasing_MAD_clust>
      </xsl2:if>
      <xsl2:if test="@expt_id!=''">
        <PDBo:reference_to_phasing_MAD_expt>
          <PDBo:phasing_MAD_expt rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MAD_exptCategory/PDBx:phasing_MAD_expt[@id='{replace(@expt_id,' +','%20')}']">
            <rdfs:label>phasing_MAD_exptKeyref_1_2_0</rdfs:label>
          </PDBo:phasing_MAD_expt>
        </PDBo:reference_to_phasing_MAD_expt>
      </xsl2:if>
      <xsl2:if test="@set_id!=''">
        <PDBo:reference_to_phasing_set>
          <PDBo:phasing_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set[@id='{replace(@set_id,' +','%20')}']">
            <rdfs:label>phasing_setKeyref_1_1_0</rdfs:label>
          </PDBo:phasing_set>
        </PDBo:reference_to_phasing_set>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MAD_set>
    </PDBo:phasing_MAD_setCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MIRCategory/PDBx:phasing_MIR">
    <PDBo:phasing_MIRCategory>
      <PDBo:phasing_MIR rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIRCategory/PDBx:phasing_MIR[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_63_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MIR>
    </PDBo:phasing_MIRCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MIR_derCategory/PDBx:phasing_MIR_der">
    <PDBo:phasing_MIR_derCategory>
      <PDBo:phasing_MIR_der rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_derCategory/PDBx:phasing_MIR_der[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:der_set_id!=''">
        <PDBo:reference_to_phasing_set>
          <PDBo:phasing_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set[@id='{replace(PDBx:der_set_id,' +','%20')}']">
            <rdfs:label>phasing_setKeyref_1_2_0</rdfs:label>
          </PDBo:phasing_set>
        </PDBo:reference_to_phasing_set>
      </xsl2:if>
      <xsl2:if test="PDBx:native_set_id!=''">
        <PDBo:reference_to_phasing_set>
          <PDBo:phasing_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set[@id='{replace(PDBx:native_set_id,' +','%20')}']">
            <rdfs:label>phasing_setKeyref_1_2_1</rdfs:label>
          </PDBo:phasing_set>
        </PDBo:reference_to_phasing_set>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MIR_der>
    </PDBo:phasing_MIR_derCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MIR_der_reflnCategory/PDBx:phasing_MIR_der_refln">
    <PDBo:phasing_MIR_der_reflnCategory>
      <PDBo:phasing_MIR_der_refln rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_der_reflnCategory/PDBx:phasing_MIR_der_refln[@der_id='{replace(@der_id,' +','%20')}'%20and%20@index_h='{replace(@index_h,' +','%20')}'%20and%20@index_k='{replace(@index_k,' +','%20')}'%20and%20@index_l='{replace(@index_l,' +','%20')}'%20and%20@set_id='{replace(@set_id,' +','%20')}']">
      <xsl2:if test="@der_id!=''">
        <PDBo:reference_to_phasing_MIR_der>
          <PDBo:phasing_MIR_der rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_derCategory/PDBx:phasing_MIR_der[@id='{replace(@der_id,' +','%20')}']">
            <rdfs:label>phasing_MIR_derKeyref_1_0_0</rdfs:label>
          </PDBo:phasing_MIR_der>
        </PDBo:reference_to_phasing_MIR_der>
      </xsl2:if>
      <xsl2:if test="@set_id!=''">
        <PDBo:reference_to_phasing_set>
          <PDBo:phasing_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set[@id='{replace(@set_id,' +','%20')}']">
            <rdfs:label>phasing_setKeyref_1_3_0</rdfs:label>
          </PDBo:phasing_set>
        </PDBo:reference_to_phasing_set>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MIR_der_refln>
    </PDBo:phasing_MIR_der_reflnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MIR_der_shellCategory/PDBx:phasing_MIR_der_shell">
    <PDBo:phasing_MIR_der_shellCategory>
      <PDBo:phasing_MIR_der_shell rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_der_shellCategory/PDBx:phasing_MIR_der_shell[@d_res_high='{replace(@d_res_high,' +','%20')}'%20and%20@d_res_low='{replace(@d_res_low,' +','%20')}'%20and%20@der_id='{replace(@der_id,' +','%20')}']">
      <xsl2:if test="@der_id!=''">
        <PDBo:reference_to_phasing_MIR_der>
          <PDBo:phasing_MIR_der rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_derCategory/PDBx:phasing_MIR_der[@id='{replace(@der_id,' +','%20')}']">
            <rdfs:label>phasing_MIR_derKeyref_1_1_0</rdfs:label>
          </PDBo:phasing_MIR_der>
        </PDBo:reference_to_phasing_MIR_der>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MIR_der_shell>
    </PDBo:phasing_MIR_der_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MIR_der_siteCategory/PDBx:phasing_MIR_der_site">
    <PDBo:phasing_MIR_der_siteCategory>
      <PDBo:phasing_MIR_der_site rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_der_siteCategory/PDBx:phasing_MIR_der_site[@der_id='{replace(@der_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@der_id!=''">
        <PDBo:reference_to_phasing_MIR_der>
          <PDBo:phasing_MIR_der rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_derCategory/PDBx:phasing_MIR_der[@id='{replace(@der_id,' +','%20')}']">
            <rdfs:label>phasing_MIR_derKeyref_1_2_0</rdfs:label>
          </PDBo:phasing_MIR_der>
        </PDBo:reference_to_phasing_MIR_der>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MIR_der_site>
    </PDBo:phasing_MIR_der_siteCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_MIR_shellCategory/PDBx:phasing_MIR_shell">
    <PDBo:phasing_MIR_shellCategory>
      <PDBo:phasing_MIR_shell rdf:about="{$base}/PDBx:datablock/PDBx:phasing_MIR_shellCategory/PDBx:phasing_MIR_shell[@d_res_high='{replace(@d_res_high,' +','%20')}'%20and%20@d_res_low='{replace(@d_res_low,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_MIR_shell>
    </PDBo:phasing_MIR_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_averagingCategory/PDBx:phasing_averaging">
    <PDBo:phasing_averagingCategory>
      <PDBo:phasing_averaging rdf:about="{$base}/PDBx:datablock/PDBx:phasing_averagingCategory/PDBx:phasing_averaging[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_64_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_averaging>
    </PDBo:phasing_averagingCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_isomorphousCategory/PDBx:phasing_isomorphous">
    <PDBo:phasing_isomorphousCategory>
      <PDBo:phasing_isomorphous rdf:about="{$base}/PDBx:datablock/PDBx:phasing_isomorphousCategory/PDBx:phasing_isomorphous[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_65_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_isomorphous>
    </PDBo:phasing_isomorphousCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set">
    <PDBo:phasing_setCategory>
      <PDBo:phasing_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_set>
    </PDBo:phasing_setCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:phasing_set_reflnCategory/PDBx:phasing_set_refln">
    <PDBo:phasing_set_reflnCategory>
      <PDBo:phasing_set_refln rdf:about="{$base}/PDBx:datablock/PDBx:phasing_set_reflnCategory/PDBx:phasing_set_refln[@index_h='{replace(@index_h,' +','%20')}'%20and%20@index_k='{replace(@index_k,' +','%20')}'%20and%20@index_l='{replace(@index_l,' +','%20')}'%20and%20@set_id='{replace(@set_id,' +','%20')}']">
      <xsl2:if test="@set_id!=''">
        <PDBo:reference_to_phasing_set>
          <PDBo:phasing_set rdf:about="{$base}/PDBx:datablock/PDBx:phasing_setCategory/PDBx:phasing_set[@id='{replace(@set_id,' +','%20')}']">
            <rdfs:label>phasing_setKeyref_1_4_0</rdfs:label>
          </PDBo:phasing_set>
        </PDBo:reference_to_phasing_set>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:phasing_set_refln>
    </PDBo:phasing_set_reflnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:publCategory/PDBx:publ">
    <PDBo:publCategory>
      <PDBo:publ rdf:about="{$base}/PDBx:datablock/PDBx:publCategory/PDBx:publ[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_66_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:publ>
    </PDBo:publCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:publ_authorCategory/PDBx:publ_author">
    <PDBo:publ_authorCategory>
      <PDBo:publ_author rdf:about="{$base}/PDBx:datablock/PDBx:publ_authorCategory/PDBx:publ_author[@name='{replace(@name,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:publ_author>
    </PDBo:publ_authorCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:publ_bodyCategory/PDBx:publ_body">
    <PDBo:publ_bodyCategory>
      <PDBo:publ_body rdf:about="{$base}/PDBx:datablock/PDBx:publ_bodyCategory/PDBx:publ_body[@element='{replace(@element,' +','%20')}'%20and%20@label='{replace(@label,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:publ_body>
    </PDBo:publ_bodyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:publ_manuscript_inclCategory/PDBx:publ_manuscript_incl">
    <PDBo:publ_manuscript_inclCategory>
      <PDBo:publ_manuscript_incl rdf:about="{$base}/PDBx:datablock/PDBx:publ_manuscript_inclCategory/PDBx:publ_manuscript_incl[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_67_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:publ_manuscript_incl>
    </PDBo:publ_manuscript_inclCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refineCategory/PDBx:refine">
    <PDBo:refineCategory>
      <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
      <xsl2:if test="@pdbx_refine_id!=''">
        <rdfs:sameAs>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKey_1</rdfs:label>
          </PDBo:refine>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_68_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine>
    </PDBo:refineCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_B_isoCategory/PDBx:refine_B_iso">
    <PDBo:refine_B_isoCategory>
      <PDBo:refine_B_iso rdf:about="{$base}/PDBx:datablock/PDBx:refine_B_isoCategory/PDBx:refine_B_iso[@class='{replace(@class,' +','%20')}'%20and%20@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_5_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_B_iso>
    </PDBo:refine_B_isoCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_analyzeCategory/PDBx:refine_analyze">
    <PDBo:refine_analyzeCategory>
      <PDBo:refine_analyze rdf:about="{$base}/PDBx:datablock/PDBx:refine_analyzeCategory/PDBx:refine_analyze[@entry_id='{replace(@entry_id,' +','%20')}'%20and%20@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_69_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_6_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_analyze>
    </PDBo:refine_analyzeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_funct_minimizedCategory/PDBx:refine_funct_minimized">
    <PDBo:refine_funct_minimizedCategory>
      <PDBo:refine_funct_minimized rdf:about="{$base}/PDBx:datablock/PDBx:refine_funct_minimizedCategory/PDBx:refine_funct_minimized[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}'%20and%20@type='{replace(@type,' +','%20')}']">
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_7_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_funct_minimized>
    </PDBo:refine_funct_minimizedCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_histCategory/PDBx:refine_hist">
    <PDBo:refine_histCategory>
      <PDBo:refine_hist rdf:about="{$base}/PDBx:datablock/PDBx:refine_histCategory/PDBx:refine_hist[@cycle_id='{replace(@cycle_id,' +','%20')}'%20and%20@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_hist>
    </PDBo:refine_histCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_ls_classCategory/PDBx:refine_ls_class">
    <PDBo:refine_ls_classCategory>
      <PDBo:refine_ls_class rdf:about="{$base}/PDBx:datablock/PDBx:refine_ls_classCategory/PDBx:refine_ls_class[@code='{replace(@code,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_ls_class>
    </PDBo:refine_ls_classCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_ls_restrCategory/PDBx:refine_ls_restr">
    <PDBo:refine_ls_restrCategory>
      <PDBo:refine_ls_restr rdf:about="{$base}/PDBx:datablock/PDBx:refine_ls_restrCategory/PDBx:refine_ls_restr[@type='{replace(@type,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(PDBx:pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_8_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_ls_restr>
    </PDBo:refine_ls_restrCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_ls_restr_ncsCategory/PDBx:refine_ls_restr_ncs">
    <PDBo:refine_ls_restr_ncsCategory>
      <PDBo:refine_ls_restr_ncs rdf:about="{$base}/PDBx:datablock/PDBx:refine_ls_restr_ncsCategory/PDBx:refine_ls_restr_ncs[@pdbx_ordinal='{replace(@pdbx_ordinal,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_auth_asym_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_auth_asym_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_24_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(PDBx:pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_9_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:pdbx_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_7_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_ens_id!=''">
        <PDBo:reference_to_struct_ncs_dom>
          <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@pdbx_ens_id='{replace(PDBx:pdbx_ens_id,' +','%20')}']">
            <rdfs:label>struct_ncs_domKeyref_2_0_0</rdfs:label>
          </PDBo:struct_ncs_dom>
        </PDBo:reference_to_struct_ncs_dom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_ls_restr_ncs>
    </PDBo:refine_ls_restr_ncsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_ls_restr_typeCategory/PDBx:refine_ls_restr_type">
    <PDBo:refine_ls_restr_typeCategory>
      <PDBo:refine_ls_restr_type rdf:about="{$base}/PDBx:datablock/PDBx:refine_ls_restr_typeCategory/PDBx:refine_ls_restr_type[@type='{replace(@type,' +','%20')}']">
      <xsl2:if test="@type!=''">
        <PDBo:reference_to_refine_ls_restr>
          <PDBo:refine_ls_restr rdf:about="{$base}/PDBx:datablock/PDBx:refine_ls_restrCategory/PDBx:refine_ls_restr[@type='{replace(@type,' +','%20')}']">
            <rdfs:label>refine_ls_restrKeyref_1_0_0</rdfs:label>
          </PDBo:refine_ls_restr>
        </PDBo:reference_to_refine_ls_restr>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_ls_restr_type>
    </PDBo:refine_ls_restr_typeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_ls_shellCategory/PDBx:refine_ls_shell">
    <PDBo:refine_ls_shellCategory>
      <PDBo:refine_ls_shell rdf:about="{$base}/PDBx:datablock/PDBx:refine_ls_shellCategory/PDBx:refine_ls_shell[@d_res_high='{replace(@d_res_high,' +','%20')}'%20and%20@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_10_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_ls_shell>
    </PDBo:refine_ls_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refine_occupancyCategory/PDBx:refine_occupancy">
    <PDBo:refine_occupancyCategory>
      <PDBo:refine_occupancy rdf:about="{$base}/PDBx:datablock/PDBx:refine_occupancyCategory/PDBx:refine_occupancy[@class='{replace(@class,' +','%20')}'%20and%20@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
      <xsl2:if test="@pdbx_refine_id!=''">
        <PDBo:reference_to_refine>
          <PDBo:refine rdf:about="{$base}/PDBx:datablock/PDBx:refineCategory/PDBx:refine[@pdbx_refine_id='{replace(@pdbx_refine_id,' +','%20')}']">
            <rdfs:label>refineKeyref_1_11_0</rdfs:label>
          </PDBo:refine>
        </PDBo:reference_to_refine>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refine_occupancy>
    </PDBo:refine_occupancyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:reflnCategory/PDBx:refln">
    <PDBo:reflnCategory>
      <PDBo:refln rdf:about="{$base}/PDBx:datablock/PDBx:reflnCategory/PDBx:refln[@index_h='{replace(@index_h,' +','%20')}'%20and%20@index_k='{replace(@index_k,' +','%20')}'%20and%20@index_l='{replace(@index_l,' +','%20')}']">
      <xsl2:if test="PDBx:wavelength_id!=''">
        <PDBo:reference_to_diffrn_radiation_wavelength>
          <PDBo:diffrn_radiation_wavelength rdf:about="{$base}/PDBx:datablock/PDBx:diffrn_radiation_wavelengthCategory/PDBx:diffrn_radiation_wavelength[@id='{replace(PDBx:wavelength_id,' +','%20')}']">
            <rdfs:label>diffrn_radiation_wavelengthKeyref_1_2_0</rdfs:label>
          </PDBo:diffrn_radiation_wavelength>
        </PDBo:reference_to_diffrn_radiation_wavelength>
      </xsl2:if>
      <xsl2:if test="PDBx:crystal_id!=''">
        <PDBo:reference_to_exptl_crystal>
          <PDBo:exptl_crystal rdf:about="{$base}/PDBx:datablock/PDBx:exptl_crystalCategory/PDBx:exptl_crystal[@id='{replace(PDBx:crystal_id,' +','%20')}']">
            <rdfs:label>exptl_crystalKeyref_1_7_0</rdfs:label>
          </PDBo:exptl_crystal>
        </PDBo:reference_to_exptl_crystal>
      </xsl2:if>
      <xsl2:if test="PDBx:scale_group_code!=''">
        <PDBo:reference_to_reflns_scale>
          <PDBo:reflns_scale rdf:about="{$base}/PDBx:datablock/PDBx:reflns_scaleCategory/PDBx:reflns_scale[@group_code='{replace(PDBx:scale_group_code,' +','%20')}']">
            <rdfs:label>reflns_scaleKeyref_1_0_0</rdfs:label>
          </PDBo:reflns_scale>
        </PDBo:reference_to_reflns_scale>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refln>
    </PDBo:reflnCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:refln_sys_absCategory/PDBx:refln_sys_abs">
    <PDBo:refln_sys_absCategory>
      <PDBo:refln_sys_abs rdf:about="{$base}/PDBx:datablock/PDBx:refln_sys_absCategory/PDBx:refln_sys_abs[@index_h='{replace(@index_h,' +','%20')}'%20and%20@index_k='{replace(@index_k,' +','%20')}'%20and%20@index_l='{replace(@index_l,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:refln_sys_abs>
    </PDBo:refln_sys_absCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:reflnsCategory/PDBx:reflns">
    <PDBo:reflnsCategory>
      <PDBo:reflns rdf:about="{$base}/PDBx:datablock/PDBx:reflnsCategory/PDBx:reflns[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_70_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:reflns>
    </PDBo:reflnsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:reflns_classCategory/PDBx:reflns_class">
    <PDBo:reflns_classCategory>
      <PDBo:reflns_class rdf:about="{$base}/PDBx:datablock/PDBx:reflns_classCategory/PDBx:reflns_class[@code='{replace(@code,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:reflns_class>
    </PDBo:reflns_classCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:reflns_scaleCategory/PDBx:reflns_scale">
    <PDBo:reflns_scaleCategory>
      <PDBo:reflns_scale rdf:about="{$base}/PDBx:datablock/PDBx:reflns_scaleCategory/PDBx:reflns_scale[@group_code='{replace(@group_code,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:reflns_scale>
    </PDBo:reflns_scaleCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:reflns_shellCategory/PDBx:reflns_shell">
    <PDBo:reflns_shellCategory>
      <PDBo:reflns_shell rdf:about="{$base}/PDBx:datablock/PDBx:reflns_shellCategory/PDBx:reflns_shell[@d_res_high='{replace(@d_res_high,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:reflns_shell>
    </PDBo:reflns_shellCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:softwareCategory/PDBx:software">
    <PDBo:softwareCategory>
      <PDBo:software rdf:about="{$base}/PDBx:datablock/PDBx:softwareCategory/PDBx:software[@pdbx_ordinal='{replace(@pdbx_ordinal,' +','%20')}']">
      <xsl2:if test="@name!=''">
        <rdfs:sameAs>
          <PDBo:software rdf:about="{$base}/PDBx:datablock/PDBx:softwareCategory/PDBx:software[@name='{replace(@name,' +','%20')}']">
            <rdfs:label>softwareKey_1</rdfs:label>
          </PDBo:software>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="PDBx:citation_id!=''">
        <PDBo:reference_to_citation>
          <PDBo:citation rdf:about="{$base}/PDBx:datablock/PDBx:citationCategory/PDBx:citation[@id='{replace(PDBx:citation_id,' +','%20')}']">
            <rdfs:label>citationKeyref_1_14_0</rdfs:label>
          </PDBo:citation>
        </PDBo:reference_to_citation>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:software>
    </PDBo:softwareCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:space_groupCategory/PDBx:space_group">
    <PDBo:space_groupCategory>
      <PDBo:space_group rdf:about="{$base}/PDBx:datablock/PDBx:space_groupCategory/PDBx:space_group[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:space_group>
    </PDBo:space_groupCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:space_group_symopCategory/PDBx:space_group_symop">
    <PDBo:space_group_symopCategory>
      <PDBo:space_group_symop rdf:about="{$base}/PDBx:datablock/PDBx:space_group_symopCategory/PDBx:space_group_symop[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:space_group_symop>
    </PDBo:space_group_symopCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:structCategory/PDBx:struct">
    <PDBo:structCategory>
      <PDBo:struct rdf:about="{$base}/PDBx:datablock/PDBx:structCategory/PDBx:struct[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_71_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct>
    </PDBo:structCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym">
    <PDBo:struct_asymCategory>
      <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_30_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_asym>
    </PDBo:struct_asymCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol">
    <PDBo:struct_biolCategory>
      <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_parent_biol_id!=''">
        <PDBo:reference_to_struct_biol>
          <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(PDBx:pdbx_parent_biol_id,' +','%20')}']">
            <rdfs:label>struct_biolKeyref_1_2_0</rdfs:label>
          </PDBo:struct_biol>
        </PDBo:reference_to_struct_biol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_biol>
    </PDBo:struct_biolCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_biol_genCategory/PDBx:struct_biol_gen">
    <PDBo:struct_biol_genCategory>
      <PDBo:struct_biol_gen rdf:about="{$base}/PDBx:datablock/PDBx:struct_biol_genCategory/PDBx:struct_biol_gen[@asym_id='{replace(@asym_id,' +','%20')}'%20and%20@biol_id='{replace(@biol_id,' +','%20')}'%20and%20@symmetry='{replace(@symmetry,' +','%20')}']">
      <xsl2:if test="@asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(@asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_8_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:if test="@biol_id!=''">
        <PDBo:reference_to_struct_biol>
          <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(@biol_id,' +','%20')}']">
            <rdfs:label>struct_biolKeyref_1_3_0</rdfs:label>
          </PDBo:struct_biol>
        </PDBo:reference_to_struct_biol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_biol_gen>
    </PDBo:struct_biol_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_biol_keywordsCategory/PDBx:struct_biol_keywords">
    <PDBo:struct_biol_keywordsCategory>
      <PDBo:struct_biol_keywords rdf:about="{$base}/PDBx:datablock/PDBx:struct_biol_keywordsCategory/PDBx:struct_biol_keywords[@biol_id='{replace(@biol_id,' +','%20')}'%20and%20@text='{replace(@text,' +','%20')}']">
      <xsl2:if test="@biol_id!=''">
        <PDBo:reference_to_struct_biol>
          <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(@biol_id,' +','%20')}']">
            <rdfs:label>struct_biolKeyref_1_4_0</rdfs:label>
          </PDBo:struct_biol>
        </PDBo:reference_to_struct_biol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_biol_keywords>
    </PDBo:struct_biol_keywordsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_biol_viewCategory/PDBx:struct_biol_view">
    <PDBo:struct_biol_viewCategory>
      <PDBo:struct_biol_view rdf:about="{$base}/PDBx:datablock/PDBx:struct_biol_viewCategory/PDBx:struct_biol_view[@biol_id='{replace(@biol_id,' +','%20')}'%20and%20@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="@biol_id!=''">
        <PDBo:reference_to_struct_biol>
          <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(@biol_id,' +','%20')}']">
            <rdfs:label>struct_biolKeyref_1_5_0</rdfs:label>
          </PDBo:struct_biol>
        </PDBo:reference_to_struct_biol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_biol_view>
    </PDBo:struct_biol_viewCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_confCategory/PDBx:struct_conf">
    <PDBo:struct_confCategory>
      <PDBo:struct_conf rdf:about="{$base}/PDBx:datablock/PDBx:struct_confCategory/PDBx:struct_conf[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:beg_auth_asym_id!='' and PDBx:beg_auth_comp_id!='' and PDBx:beg_auth_seq_id!='' and PDBx:beg_label_asym_id!='' and PDBx:beg_label_comp_id!='' and PDBx:beg_label_seq_id!='' and PDBx:pdbx_beg_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:beg_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:beg_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:beg_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:beg_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_beg_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_25_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:end_auth_asym_id!='' and PDBx:end_auth_comp_id!='' and PDBx:end_auth_seq_id!='' and PDBx:end_label_asym_id!='' and PDBx:end_label_comp_id!='' and PDBx:end_label_seq_id!='' and PDBx:pdbx_end_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:end_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:end_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:end_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:end_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_end_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_25_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:beg_auth_asym_id!='' and PDBx:beg_auth_comp_id!='' and PDBx:beg_auth_seq_id!='' and PDBx:beg_label_asym_id!='' and PDBx:beg_label_comp_id!='' and PDBx:beg_label_seq_id!='' and PDBx:pdbx_beg_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:beg_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:beg_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:beg_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:beg_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_beg_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_29_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:end_auth_asym_id!='' and PDBx:end_auth_comp_id!='' and PDBx:end_auth_seq_id!='' and PDBx:end_label_asym_id!='' and PDBx:end_label_comp_id!='' and PDBx:end_label_seq_id!='' and PDBx:pdbx_end_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:end_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:end_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:end_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:end_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_end_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_29_0_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:conf_type_id!=''">
        <PDBo:reference_to_struct_conf_type>
          <PDBo:struct_conf_type rdf:about="{$base}/PDBx:datablock/PDBx:struct_conf_typeCategory/PDBx:struct_conf_type[@id='{replace(PDBx:conf_type_id,' +','%20')}']">
            <rdfs:label>struct_conf_typeKeyref_1_0_0</rdfs:label>
          </PDBo:struct_conf_type>
        </PDBo:reference_to_struct_conf_type>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_conf>
    </PDBo:struct_confCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_conf_typeCategory/PDBx:struct_conf_type">
    <PDBo:struct_conf_typeCategory>
      <PDBo:struct_conf_type rdf:about="{$base}/PDBx:datablock/PDBx:struct_conf_typeCategory/PDBx:struct_conf_type[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_conf_type>
    </PDBo:struct_conf_typeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_connCategory/PDBx:struct_conn">
    <PDBo:struct_connCategory>
      <PDBo:struct_conn rdf:about="{$base}/PDBx:datablock/PDBx:struct_connCategory/PDBx:struct_conn[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_ptnr1_PDB_ins_code!='' and PDBx:pdbx_ptnr1_auth_alt_id!='' and PDBx:pdbx_ptnr1_label_alt_id!='' and PDBx:pdbx_ptnr1_label_alt_id!='' and PDBx:ptnr1_auth_asym_id!='' and PDBx:ptnr1_auth_atom_id!='' and PDBx:ptnr1_auth_comp_id!='' and PDBx:ptnr1_auth_seq_id!='' and PDBx:ptnr1_label_asym_id!='' and PDBx:ptnr1_label_atom_id!='' and PDBx:ptnr1_label_comp_id!='' and PDBx:ptnr1_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_ptnr1_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_ptnr1_auth_alt_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_ptnr1_label_alt_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_ptnr1_label_alt_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:ptnr1_auth_asym_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:ptnr1_auth_atom_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:ptnr1_auth_comp_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:ptnr1_auth_seq_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:ptnr1_label_asym_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:ptnr1_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:ptnr1_label_comp_id,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(PDBx:ptnr1_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_26_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_ptnr2_PDB_ins_code!='' and PDBx:pdbx_ptnr2_auth_alt_id!='' and PDBx:pdbx_ptnr2_label_alt_id!='' and PDBx:pdbx_ptnr2_label_alt_id!='' and PDBx:ptnr2_auth_asym_id!='' and PDBx:ptnr2_auth_atom_id!='' and PDBx:ptnr2_auth_comp_id!='' and PDBx:ptnr2_auth_seq_id!='' and PDBx:ptnr2_label_asym_id!='' and PDBx:ptnr2_label_atom_id!='' and PDBx:ptnr2_label_comp_id!='' and PDBx:ptnr2_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_ptnr2_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_ptnr2_auth_alt_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_ptnr2_label_alt_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_ptnr2_label_alt_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:ptnr2_auth_asym_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:ptnr2_auth_atom_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:ptnr2_auth_comp_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:ptnr2_auth_seq_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:ptnr2_label_asym_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:ptnr2_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:ptnr2_label_comp_id,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(PDBx:ptnr2_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_26_1_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_ptnr3_PDB_ins_code!='' and PDBx:pdbx_ptnr3_auth_alt_id!='' and PDBx:pdbx_ptnr3_auth_asym_id!='' and PDBx:pdbx_ptnr3_auth_atom_id!='' and PDBx:pdbx_ptnr3_auth_comp_id!='' and PDBx:pdbx_ptnr3_auth_seq_id!='' and PDBx:pdbx_ptnr3_label_alt_id!='' and PDBx:pdbx_ptnr3_label_asym_id!='' and PDBx:pdbx_ptnr3_label_atom_id!='' and PDBx:pdbx_ptnr3_label_comp_id!='' and PDBx:pdbx_ptnr3_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_ptnr3_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_ptnr3_auth_alt_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_ptnr3_auth_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_ptnr3_auth_atom_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:pdbx_ptnr3_auth_comp_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_ptnr3_auth_seq_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:pdbx_ptnr3_label_alt_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:pdbx_ptnr3_label_asym_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:pdbx_ptnr3_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_ptnr3_label_comp_id,' +','%20')}'%20and%20@pdbx_auth_alt_id='{replace(PDBx:pdbx_ptnr3_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_27_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:conn_type_id!=''">
        <PDBo:reference_to_struct_conn_type>
          <PDBo:struct_conn_type rdf:about="{$base}/PDBx:datablock/PDBx:struct_conn_typeCategory/PDBx:struct_conn_type[@id='{replace(PDBx:conn_type_id,' +','%20')}']">
            <rdfs:label>struct_conn_typeKeyref_1_0_0</rdfs:label>
          </PDBo:struct_conn_type>
        </PDBo:reference_to_struct_conn_type>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_conn>
    </PDBo:struct_connCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_conn_typeCategory/PDBx:struct_conn_type">
    <PDBo:struct_conn_typeCategory>
      <PDBo:struct_conn_type rdf:about="{$base}/PDBx:datablock/PDBx:struct_conn_typeCategory/PDBx:struct_conn_type[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_conn_type>
    </PDBo:struct_conn_typeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_keywordsCategory/PDBx:struct_keywords">
    <PDBo:struct_keywordsCategory>
      <PDBo:struct_keywords rdf:about="{$base}/PDBx:datablock/PDBx:struct_keywordsCategory/PDBx:struct_keywords[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_72_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_keywords>
    </PDBo:struct_keywordsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_mon_detailsCategory/PDBx:struct_mon_details">
    <PDBo:struct_mon_detailsCategory>
      <PDBo:struct_mon_details rdf:about="{$base}/PDBx:datablock/PDBx:struct_mon_detailsCategory/PDBx:struct_mon_details[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_73_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_mon_details>
    </PDBo:struct_mon_detailsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_mon_nuclCategory/PDBx:struct_mon_nucl">
    <PDBo:struct_mon_nuclCategory>
      <PDBo:struct_mon_nucl rdf:about="{$base}/PDBx:datablock/PDBx:struct_mon_nuclCategory/PDBx:struct_mon_nucl[@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
      <xsl2:if test="PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_4_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_mon_nucl>
    </PDBo:struct_mon_nuclCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_mon_protCategory/PDBx:struct_mon_prot">
    <PDBo:struct_mon_protCategory>
      <PDBo:struct_mon_prot rdf:about="{$base}/PDBx:datablock/PDBx:struct_mon_protCategory/PDBx:struct_mon_prot[@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
      <xsl2:if test="PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and @label_alt_id!='' and @label_asym_id!='' and @label_comp_id!='' and @label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(@label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(@label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(@label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(@label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_9_5_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_mon_prot>
    </PDBo:struct_mon_protCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_mon_prot_cisCategory/PDBx:struct_mon_prot_cis">
    <PDBo:struct_mon_prot_cisCategory>
      <PDBo:struct_mon_prot_cis rdf:about="{$base}/PDBx:datablock/PDBx:struct_mon_prot_cisCategory/PDBx:struct_mon_prot_cis[@pdbx_id='{replace(@pdbx_id,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_PDB_ins_code_2!='' and PDBx:pdbx_auth_asym_id_2!='' and PDBx:pdbx_auth_comp_id_2!='' and PDBx:pdbx_auth_seq_id_2!='' and PDBx:pdbx_label_asym_id_2!='' and PDBx:pdbx_label_comp_id_2!='' and PDBx:pdbx_label_seq_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_PDB_ins_code_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_auth_asym_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_auth_comp_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_auth_seq_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:pdbx_label_asym_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:pdbx_label_comp_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_label_seq_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_25_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:auth_asym_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and PDBx:label_alt_id!='' and PDBx:label_asym_id!='' and PDBx:label_comp_id!='' and PDBx:label_seq_id!='' and PDBx:pdbx_PDB_ins_code!='' and PDBx:pdbx_PDB_model_num!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_PDB_ins_code,' +','%20')}'%20and%20@pdbx_PDB_model_num='{replace(PDBx:pdbx_PDB_model_num,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_28_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_PDB_ins_code_2!='' and PDBx:pdbx_auth_asym_id_2!='' and PDBx:pdbx_auth_comp_id_2!='' and PDBx:pdbx_auth_seq_id_2!='' and PDBx:pdbx_label_asym_id_2!='' and PDBx:pdbx_label_comp_id_2!='' and PDBx:pdbx_label_seq_id_2!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_PDB_ins_code_2,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_auth_asym_id_2,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_auth_comp_id_2,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_auth_seq_id_2,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:pdbx_label_asym_id_2,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:pdbx_label_comp_id_2,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_label_seq_id_2,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_29_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_mon_prot_cis>
    </PDBo:struct_mon_prot_cisCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom">
    <PDBo:struct_ncs_domCategory>
      <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@id='{replace(@id,' +','%20')}'%20and%20@pdbx_ens_id='{replace(@pdbx_ens_id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>struct_ncs_domKey_1</rdfs:label>
          </PDBo:struct_ncs_dom>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@pdbx_ens_id!=''">
        <rdfs:sameAs>
          <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@pdbx_ens_id='{replace(@pdbx_ens_id,' +','%20')}']">
            <rdfs:label>struct_ncs_domKey_2</rdfs:label>
          </PDBo:struct_ncs_dom>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="@pdbx_ens_id!=''">
        <PDBo:reference_to_struct_ncs_ens>
          <PDBo:struct_ncs_ens rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_ensCategory/PDBx:struct_ncs_ens[@id='{replace(@pdbx_ens_id,' +','%20')}']">
            <rdfs:label>struct_ncs_ensKeyref_1_0_0</rdfs:label>
          </PDBo:struct_ncs_ens>
        </PDBo:reference_to_struct_ncs_ens>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ncs_dom>
    </PDBo:struct_ncs_domCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_ncs_dom_limCategory/PDBx:struct_ncs_dom_lim">
    <PDBo:struct_ncs_dom_limCategory>
      <PDBo:struct_ncs_dom_lim rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_dom_limCategory/PDBx:struct_ncs_dom_lim[@dom_id='{replace(@dom_id,' +','%20')}'%20and%20@pdbx_component_id='{replace(@pdbx_component_id,' +','%20')}'%20and%20@pdbx_ens_id='{replace(@pdbx_ens_id,' +','%20')}']">
      <xsl2:if test="PDBx:beg_label_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:beg_label_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_9_0</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:if test="PDBx:end_label_asym_id!=''">
        <PDBo:reference_to_struct_asym>
          <PDBo:struct_asym rdf:about="{$base}/PDBx:datablock/PDBx:struct_asymCategory/PDBx:struct_asym[@id='{replace(PDBx:end_label_asym_id,' +','%20')}']">
            <rdfs:label>struct_asymKeyref_1_9_1</rdfs:label>
          </PDBo:struct_asym>
        </PDBo:reference_to_struct_asym>
      </xsl2:if>
      <xsl2:if test="@dom_id!='' and @pdbx_ens_id!=''">
        <PDBo:reference_to_struct_ncs_dom>
          <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@id='{replace(@dom_id,' +','%20')}'%20and%20@pdbx_ens_id='{replace(@pdbx_ens_id,' +','%20')}']">
            <rdfs:label>struct_ncs_domKeyref_3_0_0</rdfs:label>
          </PDBo:struct_ncs_dom>
        </PDBo:reference_to_struct_ncs_dom>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ncs_dom_lim>
    </PDBo:struct_ncs_dom_limCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_ncs_ensCategory/PDBx:struct_ncs_ens">
    <PDBo:struct_ncs_ensCategory>
      <PDBo:struct_ncs_ens rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_ensCategory/PDBx:struct_ncs_ens[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ncs_ens>
    </PDBo:struct_ncs_ensCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_ncs_ens_genCategory/PDBx:struct_ncs_ens_gen">
    <PDBo:struct_ncs_ens_genCategory>
      <PDBo:struct_ncs_ens_gen rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_ens_genCategory/PDBx:struct_ncs_ens_gen[@dom_id_1='{replace(@dom_id_1,' +','%20')}'%20and%20@dom_id_2='{replace(@dom_id_2,' +','%20')}'%20and%20@ens_id='{replace(@ens_id,' +','%20')}'%20and%20@oper_id='{replace(@oper_id,' +','%20')}']">
      <xsl2:if test="@dom_id_1!=''">
        <PDBo:reference_to_struct_ncs_dom>
          <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@id='{replace(@dom_id_1,' +','%20')}']">
            <rdfs:label>struct_ncs_domKeyref_1_1_0</rdfs:label>
          </PDBo:struct_ncs_dom>
        </PDBo:reference_to_struct_ncs_dom>
      </xsl2:if>
      <xsl2:if test="@dom_id_2!=''">
        <PDBo:reference_to_struct_ncs_dom>
          <PDBo:struct_ncs_dom rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_domCategory/PDBx:struct_ncs_dom[@id='{replace(@dom_id_2,' +','%20')}']">
            <rdfs:label>struct_ncs_domKeyref_1_1_1</rdfs:label>
          </PDBo:struct_ncs_dom>
        </PDBo:reference_to_struct_ncs_dom>
      </xsl2:if>
      <xsl2:if test="@ens_id!=''">
        <PDBo:reference_to_struct_ncs_ens>
          <PDBo:struct_ncs_ens rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_ensCategory/PDBx:struct_ncs_ens[@id='{replace(@ens_id,' +','%20')}']">
            <rdfs:label>struct_ncs_ensKeyref_1_1_0</rdfs:label>
          </PDBo:struct_ncs_ens>
        </PDBo:reference_to_struct_ncs_ens>
      </xsl2:if>
      <xsl2:if test="@oper_id!=''">
        <PDBo:reference_to_struct_ncs_oper>
          <PDBo:struct_ncs_oper rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_operCategory/PDBx:struct_ncs_oper[@id='{replace(@oper_id,' +','%20')}']">
            <rdfs:label>struct_ncs_operKeyref_1_0_0</rdfs:label>
          </PDBo:struct_ncs_oper>
        </PDBo:reference_to_struct_ncs_oper>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ncs_ens_gen>
    </PDBo:struct_ncs_ens_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_ncs_operCategory/PDBx:struct_ncs_oper">
    <PDBo:struct_ncs_operCategory>
      <PDBo:struct_ncs_oper rdf:about="{$base}/PDBx:datablock/PDBx:struct_ncs_operCategory/PDBx:struct_ncs_oper[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ncs_oper>
    </PDBo:struct_ncs_operCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_refCategory/PDBx:struct_ref">
    <PDBo:struct_refCategory>
      <PDBo:struct_ref rdf:about="{$base}/PDBx:datablock/PDBx:struct_refCategory/PDBx:struct_ref[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:entity_id!=''">
        <PDBo:reference_to_entity>
          <PDBo:entity rdf:about="{$base}/PDBx:datablock/PDBx:entityCategory/PDBx:entity[@id='{replace(PDBx:entity_id,' +','%20')}']">
            <rdfs:label>entityKeyref_1_31_0</rdfs:label>
          </PDBo:entity>
        </PDBo:reference_to_entity>
      </xsl2:if>
      <xsl2:if test="PDBx:biol_id!=''">
        <PDBo:reference_to_struct_biol>
          <PDBo:struct_biol rdf:about="{$base}/PDBx:datablock/PDBx:struct_biolCategory/PDBx:struct_biol[@id='{replace(PDBx:biol_id,' +','%20')}']">
            <rdfs:label>struct_biolKeyref_1_6_0</rdfs:label>
          </PDBo:struct_biol>
        </PDBo:reference_to_struct_biol>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ref>
    </PDBo:struct_refCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_ref_seqCategory/PDBx:struct_ref_seq">
    <PDBo:struct_ref_seqCategory>
      <PDBo:struct_ref_seq rdf:about="{$base}/PDBx:datablock/PDBx:struct_ref_seqCategory/PDBx:struct_ref_seq[@align_id='{replace(@align_id,' +','%20')}']">
      <xsl2:if test="PDBx:seq_align_beg!=''">
        <PDBo:reference_to_entity_poly_seq>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@num='{replace(PDBx:seq_align_beg,' +','%20')}']">
            <rdfs:label>entity_poly_seqKeyref_1_2_0</rdfs:label>
          </PDBo:entity_poly_seq>
        </PDBo:reference_to_entity_poly_seq>
      </xsl2:if>
      <xsl2:if test="PDBx:seq_align_end!=''">
        <PDBo:reference_to_entity_poly_seq>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@num='{replace(PDBx:seq_align_end,' +','%20')}']">
            <rdfs:label>entity_poly_seqKeyref_1_2_1</rdfs:label>
          </PDBo:entity_poly_seq>
        </PDBo:reference_to_entity_poly_seq>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_auth_seq_align_beg!='' and PDBx:pdbx_seq_align_beg_ins_code!='' and PDBx:pdbx_strand_id!=''">
        <PDBo:reference_to_pdbx_poly_seq_scheme>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@pdb_ins_code='{replace(PDBx:pdbx_auth_seq_align_beg,' +','%20')}'%20and%20@pdb_seq_num='{replace(PDBx:pdbx_seq_align_beg_ins_code,' +','%20')}'%20and%20@pdb_strand_id='{replace(PDBx:pdbx_strand_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKeyref_3_0_0</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </PDBo:reference_to_pdbx_poly_seq_scheme>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_auth_seq_align_end!='' and PDBx:pdbx_seq_align_end_ins_code!='' and PDBx:pdbx_strand_id!=''">
        <PDBo:reference_to_pdbx_poly_seq_scheme>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@pdb_ins_code='{replace(PDBx:pdbx_auth_seq_align_end,' +','%20')}'%20and%20@pdb_seq_num='{replace(PDBx:pdbx_seq_align_end_ins_code,' +','%20')}'%20and%20@pdb_strand_id='{replace(PDBx:pdbx_strand_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKeyref_3_0_1</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </PDBo:reference_to_pdbx_poly_seq_scheme>
      </xsl2:if>
      <xsl2:if test="PDBx:ref_id!=''">
        <PDBo:reference_to_struct_ref>
          <PDBo:struct_ref rdf:about="{$base}/PDBx:datablock/PDBx:struct_refCategory/PDBx:struct_ref[@id='{replace(PDBx:ref_id,' +','%20')}']">
            <rdfs:label>struct_refKeyref_1_0_0</rdfs:label>
          </PDBo:struct_ref>
        </PDBo:reference_to_struct_ref>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ref_seq>
    </PDBo:struct_ref_seqCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_ref_seq_difCategory/PDBx:struct_ref_seq_dif">
    <PDBo:struct_ref_seq_difCategory>
      <PDBo:struct_ref_seq_dif rdf:about="{$base}/PDBx:datablock/PDBx:struct_ref_seq_difCategory/PDBx:struct_ref_seq_dif[@pdbx_ordinal='{replace(@pdbx_ordinal,' +','%20')}']">
      <xsl2:if test="PDBx:db_mon_id!=''">
        <PDBo:reference_to_chem_comp>
          <PDBo:chem_comp rdf:about="{$base}/PDBx:datablock/PDBx:chem_compCategory/PDBx:chem_comp[@id='{replace(PDBx:db_mon_id,' +','%20')}']">
            <rdfs:label>chem_compKeyref_1_15_0</rdfs:label>
          </PDBo:chem_comp>
        </PDBo:reference_to_chem_comp>
      </xsl2:if>
      <xsl2:if test="PDBx:mon_id!='' and PDBx:seq_num!=''">
        <PDBo:reference_to_entity_poly_seq>
          <PDBo:entity_poly_seq rdf:about="{$base}/PDBx:datablock/PDBx:entity_poly_seqCategory/PDBx:entity_poly_seq[@mon_id='{replace(PDBx:mon_id,' +','%20')}'%20and%20@num='{replace(PDBx:seq_num,' +','%20')}']">
            <rdfs:label>entity_poly_seqKeyref_3_0_0</rdfs:label>
          </PDBo:entity_poly_seq>
        </PDBo:reference_to_entity_poly_seq>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_auth_seq_num!='' and PDBx:pdbx_pdb_ins_code!='' and PDBx:pdbx_pdb_strand_id!=''">
        <PDBo:reference_to_pdbx_poly_seq_scheme>
          <PDBo:pdbx_poly_seq_scheme rdf:about="{$base}/PDBx:datablock/PDBx:pdbx_poly_seq_schemeCategory/PDBx:pdbx_poly_seq_scheme[@pdb_ins_code='{replace(PDBx:pdbx_auth_seq_num,' +','%20')}'%20and%20@pdb_seq_num='{replace(PDBx:pdbx_pdb_ins_code,' +','%20')}'%20and%20@pdb_strand_id='{replace(PDBx:pdbx_pdb_strand_id,' +','%20')}']">
            <rdfs:label>pdbx_poly_seq_schemeKeyref_3_1_0</rdfs:label>
          </PDBo:pdbx_poly_seq_scheme>
        </PDBo:reference_to_pdbx_poly_seq_scheme>
      </xsl2:if>
      <xsl2:if test="PDBx:align_id!=''">
        <PDBo:reference_to_struct_ref_seq>
          <PDBo:struct_ref_seq rdf:about="{$base}/PDBx:datablock/PDBx:struct_ref_seqCategory/PDBx:struct_ref_seq[@align_id='{replace(PDBx:align_id,' +','%20')}']">
            <rdfs:label>struct_ref_seqKeyref_1_0_0</rdfs:label>
          </PDBo:struct_ref_seq>
        </PDBo:reference_to_struct_ref_seq>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_ref_seq_dif>
    </PDBo:struct_ref_seq_difCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_sheetCategory/PDBx:struct_sheet">
    <PDBo:struct_sheetCategory>
      <PDBo:struct_sheet rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheetCategory/PDBx:struct_sheet[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_sheet>
    </PDBo:struct_sheetCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_sheet_hbondCategory/PDBx:struct_sheet_hbond">
    <PDBo:struct_sheet_hbondCategory>
      <PDBo:struct_sheet_hbond rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_hbondCategory/PDBx:struct_sheet_hbond[@range_id_1='{replace(@range_id_1,' +','%20')}'%20and%20@range_id_2='{replace(@range_id_2,' +','%20')}'%20and%20@sheet_id='{replace(@sheet_id,' +','%20')}']">
      <xsl2:if test="PDBx:pdbx_range_1_beg_PDB_ins_code!='' and PDBx:pdbx_range_1_beg_auth_asym_id!='' and PDBx:pdbx_range_1_beg_auth_comp_id!='' and PDBx:pdbx_range_1_beg_label_asym_id!='' and PDBx:pdbx_range_1_beg_label_comp_id!='' and PDBx:range_1_beg_auth_atom_id!='' and PDBx:range_1_beg_auth_seq_id!='' and PDBx:range_1_beg_label_atom_id!='' and PDBx:range_1_beg_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_range_1_beg_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_range_1_beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_range_1_beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_range_1_beg_label_asym_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_range_1_beg_label_comp_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_1_beg_auth_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_1_beg_auth_seq_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_1_beg_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_1_beg_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_16_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_range_1_end_PDB_ins_code!='' and PDBx:pdbx_range_1_end_auth_asym_id!='' and PDBx:pdbx_range_1_end_auth_comp_id!='' and PDBx:pdbx_range_1_end_label_asym_id!='' and PDBx:pdbx_range_1_end_label_comp_id!='' and PDBx:range_1_end_auth_atom_id!='' and PDBx:range_1_end_auth_seq_id!='' and PDBx:range_1_end_label_atom_id!='' and PDBx:range_1_end_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_range_1_end_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_range_1_end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_range_1_end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_range_1_end_label_asym_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_range_1_end_label_comp_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_1_end_auth_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_1_end_auth_seq_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_1_end_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_1_end_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_16_1_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_range_1_beg_PDB_ins_code!='' and PDBx:pdbx_range_1_beg_auth_asym_id!='' and PDBx:pdbx_range_1_beg_auth_comp_id!='' and PDBx:pdbx_range_1_beg_label_asym_id!='' and PDBx:pdbx_range_1_beg_label_comp_id!='' and PDBx:range_1_beg_auth_atom_id!='' and PDBx:range_1_beg_auth_seq_id!='' and PDBx:range_1_beg_label_atom_id!='' and PDBx:range_1_beg_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_range_1_beg_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_range_1_beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_range_1_beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_range_1_beg_label_asym_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_range_1_beg_label_comp_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_1_beg_auth_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_1_beg_auth_seq_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_1_beg_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_1_beg_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_30_1_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_range_1_end_PDB_ins_code!='' and PDBx:pdbx_range_1_end_auth_asym_id!='' and PDBx:pdbx_range_1_end_auth_comp_id!='' and PDBx:pdbx_range_1_end_label_asym_id!='' and PDBx:pdbx_range_1_end_label_comp_id!='' and PDBx:range_1_end_auth_atom_id!='' and PDBx:range_1_end_auth_seq_id!='' and PDBx:range_1_end_label_atom_id!='' and PDBx:range_1_end_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:pdbx_range_1_end_PDB_ins_code,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:pdbx_range_1_end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:pdbx_range_1_end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_range_1_end_label_asym_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_range_1_end_label_comp_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_1_end_auth_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_1_end_auth_seq_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_1_end_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_1_end_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_30_1_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_range_2_beg_PDB_ins_code!='' and PDBx:pdbx_range_2_beg_label_asym_id!='' and PDBx:pdbx_range_2_beg_label_comp_id!='' and PDBx:range_2_beg_auth_atom_id!='' and PDBx:range_2_beg_auth_seq_id!='' and PDBx:range_2_beg_label_atom_id!='' and PDBx:range_2_beg_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_atom_id='{replace(PDBx:pdbx_range_2_beg_PDB_ins_code,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_range_2_beg_label_asym_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:pdbx_range_2_beg_label_comp_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_2_beg_auth_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_2_beg_auth_seq_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_2_beg_label_atom_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:range_2_beg_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_31_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:pdbx_range_2_end_label_asym_id!='' and PDBx:pdbx_range_2_end_label_comp_id!='' and PDBx:range_2_end_auth_atom_id!='' and PDBx:range_2_end_auth_seq_id!='' and PDBx:range_2_end_label_atom_id!='' and PDBx:range_2_end_label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_atom_id='{replace(PDBx:pdbx_range_2_end_label_asym_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:pdbx_range_2_end_label_comp_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:range_2_end_auth_atom_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:range_2_end_auth_seq_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:range_2_end_label_atom_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:range_2_end_label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_32_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="@sheet_id!=''">
        <PDBo:reference_to_struct_sheet>
          <PDBo:struct_sheet rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheetCategory/PDBx:struct_sheet[@id='{replace(@sheet_id,' +','%20')}']">
            <rdfs:label>struct_sheetKeyref_1_1_0</rdfs:label>
          </PDBo:struct_sheet>
        </PDBo:reference_to_struct_sheet>
      </xsl2:if>
      <xsl2:if test="@range_id_1!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_1,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_1_0</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:if test="@range_id_2!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_2,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_1_1</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_sheet_hbond>
    </PDBo:struct_sheet_hbondCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_sheet_orderCategory/PDBx:struct_sheet_order">
    <PDBo:struct_sheet_orderCategory>
      <PDBo:struct_sheet_order rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_orderCategory/PDBx:struct_sheet_order[@range_id_1='{replace(@range_id_1,' +','%20')}'%20and%20@range_id_2='{replace(@range_id_2,' +','%20')}'%20and%20@sheet_id='{replace(@sheet_id,' +','%20')}']">
      <xsl2:if test="@sheet_id!=''">
        <PDBo:reference_to_struct_sheet>
          <PDBo:struct_sheet rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheetCategory/PDBx:struct_sheet[@id='{replace(@sheet_id,' +','%20')}']">
            <rdfs:label>struct_sheetKeyref_1_2_0</rdfs:label>
          </PDBo:struct_sheet>
        </PDBo:reference_to_struct_sheet>
      </xsl2:if>
      <xsl2:if test="@range_id_1!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_1,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_2_0</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:if test="@range_id_2!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_2,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_2_1</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_sheet_order>
    </PDBo:struct_sheet_orderCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range">
    <PDBo:struct_sheet_rangeCategory>
      <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@id,' +','%20')}'%20and%20@sheet_id='{replace(@sheet_id,' +','%20')}']">
      <xsl2:if test="@id!=''">
        <rdfs:sameAs>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@id,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKey_1</rdfs:label>
          </PDBo:struct_sheet_range>
        </rdfs:sameAs>
      </xsl2:if>
      <xsl2:if test="PDBx:beg_auth_asym_id!='' and PDBx:beg_auth_comp_id!='' and PDBx:beg_auth_seq_id!='' and PDBx:beg_label_asym_id!='' and PDBx:beg_label_comp_id!='' and PDBx:beg_label_seq_id!='' and PDBx:pdbx_beg_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:beg_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:beg_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:beg_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:beg_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_beg_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_25_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:end_auth_asym_id!='' and PDBx:end_auth_comp_id!='' and PDBx:end_auth_seq_id!='' and PDBx:end_label_asym_id!='' and PDBx:end_label_comp_id!='' and PDBx:end_label_seq_id!='' and PDBx:pdbx_end_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:end_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:end_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:end_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:end_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_end_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_25_2_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:beg_auth_asym_id!='' and PDBx:beg_auth_comp_id!='' and PDBx:beg_auth_seq_id!='' and PDBx:beg_label_asym_id!='' and PDBx:beg_label_comp_id!='' and PDBx:beg_label_seq_id!='' and PDBx:pdbx_beg_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:beg_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:beg_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:beg_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:beg_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:beg_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:beg_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_beg_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_29_2_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="PDBx:end_auth_asym_id!='' and PDBx:end_auth_comp_id!='' and PDBx:end_auth_seq_id!='' and PDBx:end_label_asym_id!='' and PDBx:end_label_comp_id!='' and PDBx:end_label_seq_id!='' and PDBx:pdbx_end_PDB_ins_code!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:end_auth_asym_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:end_auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:end_auth_seq_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:end_label_asym_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:end_label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:end_label_seq_id,' +','%20')}'%20and%20@pdbx_PDB_ins_code='{replace(PDBx:pdbx_end_PDB_ins_code,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_29_2_1</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="@sheet_id!=''">
        <PDBo:reference_to_struct_sheet>
          <PDBo:struct_sheet rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheetCategory/PDBx:struct_sheet[@id='{replace(@sheet_id,' +','%20')}']">
            <rdfs:label>struct_sheetKeyref_1_3_0</rdfs:label>
          </PDBo:struct_sheet>
        </PDBo:reference_to_struct_sheet>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_sheet_range>
    </PDBo:struct_sheet_rangeCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_sheet_topologyCategory/PDBx:struct_sheet_topology">
    <PDBo:struct_sheet_topologyCategory>
      <PDBo:struct_sheet_topology rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_topologyCategory/PDBx:struct_sheet_topology[@range_id_1='{replace(@range_id_1,' +','%20')}'%20and%20@range_id_2='{replace(@range_id_2,' +','%20')}'%20and%20@sheet_id='{replace(@sheet_id,' +','%20')}']">
      <xsl2:if test="@sheet_id!=''">
        <PDBo:reference_to_struct_sheet>
          <PDBo:struct_sheet rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheetCategory/PDBx:struct_sheet[@id='{replace(@sheet_id,' +','%20')}']">
            <rdfs:label>struct_sheetKeyref_1_4_0</rdfs:label>
          </PDBo:struct_sheet>
        </PDBo:reference_to_struct_sheet>
      </xsl2:if>
      <xsl2:if test="@range_id_1!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_1,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_3_0</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:if test="@range_id_2!=''">
        <PDBo:reference_to_struct_sheet_range>
          <PDBo:struct_sheet_range rdf:about="{$base}/PDBx:datablock/PDBx:struct_sheet_rangeCategory/PDBx:struct_sheet_range[@id='{replace(@range_id_2,' +','%20')}']">
            <rdfs:label>struct_sheet_rangeKeyref_1_3_1</rdfs:label>
          </PDBo:struct_sheet_range>
        </PDBo:reference_to_struct_sheet_range>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_sheet_topology>
    </PDBo:struct_sheet_topologyCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_siteCategory/PDBx:struct_site">
    <PDBo:struct_siteCategory>
      <PDBo:struct_site rdf:about="{$base}/PDBx:datablock/PDBx:struct_siteCategory/PDBx:struct_site[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_site>
    </PDBo:struct_siteCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_site_genCategory/PDBx:struct_site_gen">
    <PDBo:struct_site_genCategory>
      <PDBo:struct_site_gen rdf:about="{$base}/PDBx:datablock/PDBx:struct_site_genCategory/PDBx:struct_site_gen[@id='{replace(@id,' +','%20')}'%20and%20@site_id='{replace(@site_id,' +','%20')}']">
      <xsl2:if test="PDBx:auth_asym_id!='' and PDBx:auth_atom_id!='' and PDBx:auth_comp_id!='' and PDBx:auth_seq_id!='' and PDBx:label_alt_id!='' and PDBx:label_asym_id!='' and PDBx:label_atom_id!='' and PDBx:label_comp_id!='' and PDBx:label_seq_id!=''">
        <PDBo:reference_to_atom_site>
          <PDBo:atom_site rdf:about="{$base}/PDBx:datablock/PDBx:atom_siteCategory/PDBx:atom_site[@auth_asym_id='{replace(PDBx:auth_asym_id,' +','%20')}'%20and%20@auth_atom_id='{replace(PDBx:auth_atom_id,' +','%20')}'%20and%20@auth_comp_id='{replace(PDBx:auth_comp_id,' +','%20')}'%20and%20@auth_seq_id='{replace(PDBx:auth_seq_id,' +','%20')}'%20and%20@label_alt_id='{replace(PDBx:label_alt_id,' +','%20')}'%20and%20@label_asym_id='{replace(PDBx:label_asym_id,' +','%20')}'%20and%20@label_atom_id='{replace(PDBx:label_atom_id,' +','%20')}'%20and%20@label_comp_id='{replace(PDBx:label_comp_id,' +','%20')}'%20and%20@label_seq_id='{replace(PDBx:label_seq_id,' +','%20')}']">
            <rdfs:label>atom_siteKeyref_33_0_0</rdfs:label>
          </PDBo:atom_site>
        </PDBo:reference_to_atom_site>
      </xsl2:if>
      <xsl2:if test="@site_id!=''">
        <PDBo:reference_to_struct_site>
          <PDBo:struct_site rdf:about="{$base}/PDBx:datablock/PDBx:struct_siteCategory/PDBx:struct_site[@id='{replace(@site_id,' +','%20')}']">
            <rdfs:label>struct_siteKeyref_1_0_0</rdfs:label>
          </PDBo:struct_site>
        </PDBo:reference_to_struct_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_site_gen>
    </PDBo:struct_site_genCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_site_keywordsCategory/PDBx:struct_site_keywords">
    <PDBo:struct_site_keywordsCategory>
      <PDBo:struct_site_keywords rdf:about="{$base}/PDBx:datablock/PDBx:struct_site_keywordsCategory/PDBx:struct_site_keywords[@site_id='{replace(@site_id,' +','%20')}'%20and%20@text='{replace(@text,' +','%20')}']">
      <xsl2:if test="@site_id!=''">
        <PDBo:reference_to_struct_site>
          <PDBo:struct_site rdf:about="{$base}/PDBx:datablock/PDBx:struct_siteCategory/PDBx:struct_site[@id='{replace(@site_id,' +','%20')}']">
            <rdfs:label>struct_siteKeyref_1_1_0</rdfs:label>
          </PDBo:struct_site>
        </PDBo:reference_to_struct_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_site_keywords>
    </PDBo:struct_site_keywordsCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:struct_site_viewCategory/PDBx:struct_site_view">
    <PDBo:struct_site_viewCategory>
      <PDBo:struct_site_view rdf:about="{$base}/PDBx:datablock/PDBx:struct_site_viewCategory/PDBx:struct_site_view[@id='{replace(@id,' +','%20')}']">
      <xsl2:if test="PDBx:site_id!=''">
        <PDBo:reference_to_struct_site>
          <PDBo:struct_site rdf:about="{$base}/PDBx:datablock/PDBx:struct_siteCategory/PDBx:struct_site[@id='{replace(PDBx:site_id,' +','%20')}']">
            <rdfs:label>struct_siteKeyref_1_2_0</rdfs:label>
          </PDBo:struct_site>
        </PDBo:reference_to_struct_site>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:struct_site_view>
    </PDBo:struct_site_viewCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:symmetryCategory/PDBx:symmetry">
    <PDBo:symmetryCategory>
      <PDBo:symmetry rdf:about="{$base}/PDBx:datablock/PDBx:symmetryCategory/PDBx:symmetry[@entry_id='{replace(@entry_id,' +','%20')}']">
      <xsl2:if test="@entry_id!=''">
        <PDBo:reference_to_entry>
          <PDBo:entry rdf:about="{$base}/PDBx:datablock/PDBx:entryCategory/PDBx:entry[@id='{replace(@entry_id,' +','%20')}']">
            <rdfs:label>entryKeyref_1_74_0</rdfs:label>
          </PDBo:entry>
        </PDBo:reference_to_entry>
      </xsl2:if>
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:symmetry>
    </PDBo:symmetryCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:symmetry_equivCategory/PDBx:symmetry_equiv">
    <PDBo:symmetry_equivCategory>
      <PDBo:symmetry_equiv rdf:about="{$base}/PDBx:datablock/PDBx:symmetry_equivCategory/PDBx:symmetry_equiv[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:symmetry_equiv>
    </PDBo:symmetry_equivCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:valence_paramCategory/PDBx:valence_param">
    <PDBo:valence_paramCategory>
      <PDBo:valence_param rdf:about="{$base}/PDBx:datablock/PDBx:valence_paramCategory/PDBx:valence_param[@atom_1='{replace(@atom_1,' +','%20')}'%20and%20@atom_1_valence='{replace(@atom_1_valence,' +','%20')}'%20and%20@atom_2='{replace(@atom_2,' +','%20')}'%20and%20@atom_2_valence='{replace(@atom_2_valence,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:valence_param>
    </PDBo:valence_paramCategory>
  </xsl2:template>


  <xsl2:template match="PDBx:datablock/PDBx:valence_refCategory/PDBx:valence_ref">
    <PDBo:valence_refCategory>
      <PDBo:valence_ref rdf:about="{$base}/PDBx:datablock/PDBx:valence_refCategory/PDBx:valence_ref[@id='{replace(@id,' +','%20')}']">
      <xsl2:apply-templates select="@*"/>
      <xsl2:apply-templates select="@*" mode="linked"/>
      <xsl2:apply-templates/>
      <xsl2:apply-templates mode="linked"/>
      </PDBo:valence_ref>
    </PDBo:valence_refCategory>
  </xsl2:template>


  <xsl2:template match="*[@xsi:nil='true']"/>
  <xsl2:template match="*|text()|@*"/>
  <xsl2:template match="*|text()|@*" mode="linked"/>
 
</xsl2:stylesheet>