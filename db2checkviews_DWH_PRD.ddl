"select concat(concat(trim(viewschema),'.'),viewname) from syscat.views where valid='X' and exists (select tabname from syscat.columns where tabname=viewname and remarks like '%Check_MK%');"
