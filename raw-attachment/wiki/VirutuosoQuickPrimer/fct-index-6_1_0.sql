-- fct-index.sql
-- isql 11018 < fct-index.sql > fct.log & 

RDF_OBJ_FT_RULE_ADD (null, null, 'All');
VT_INC_INDEX_DB_DBA_RDF_OBJ ();
urilbl_ac_init_db();
s_rank();
VT_INC_INDEX_DB_DBA_RDF_OBJ();
