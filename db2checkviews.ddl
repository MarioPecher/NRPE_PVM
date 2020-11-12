"select concat(concat(trim(viewschema),'.'),viewname) from syscat.views where valid='X' and viewschema not like '%SYSTOOLS%';"
