  drop index RDF_QUAD_OPGS;
  drop index RDF_QUAD_POGS;
  drop index RDF_QUAD_GPOS;
  drop index RDF_QUAD_OGPS;

  checkpoint;

  create table R2 (G iri_id_8, S iri_id_8, P iri_id_8, O any, primary key (S, P, O, G));
  alter index R2 on R2 partition (S int (0hexffff00));

  log_enable (2);

  insert into R2 (G, S, P, O) select G, S, P, O from rdf_quad;

  drop table RDF_QUAD;
  alter table r2 rename RDF_QUAD;

  checkpoint;

  create bitmap index RDF_QUAD_OPGS on RDF_QUAD (O, P, G, S) partition (O varchar (-1, 0hexffff));
  create bitmap index RDF_QUAD_POGS on RDF_QUAD (P, O, G, S) partition (O varchar (-1, 0hexffff));
  create bitmap index RDF_QUAD_GPOS on RDF_QUAD (G, P, O, S) partition (O varchar (-1, 0hexffff));
  create bitmap index RDF_QUAD_OGPS on RDF_QUAD (O, G, P, S) partition (O varchar (-1, 0hexffff));

  checkpoint;

grant select on DB.DBA.RDF_QUAD to "SPARQL";

RDF_OBJ_FT_RULE_ADD (null, null, 'All');
DB.DBA.VT_INC_INDEX_DB_DBA_RDF_OBJ ();

  checkpoint;

grant EXECUTE ON DB.DBA.SPARQL_INSERT_DICT_CONTENT to "SPARQL";
grant EXECUTE ON DB.DBA.SPARQL_DELETE_DICT_CONTENT to "SPARQL";

  checkpoint;

