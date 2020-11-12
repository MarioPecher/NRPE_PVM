#!/bin/ksh
#
# Script checking views, which are in state=X 
# AUTHOR: Daniel Rakowski
# Last Change: 20170516
db2_instance=$(ps -ef |grep db2sysc | grep -v -E "root|hush|MAIL"|awk {'print $1'}|grep db2)
for instance in $db2_instance;
	do
	database=$(su - $instance -c db2 list db directory |grep -p Indirect| grep "Database alias"|awk {'print $4'})
	for db in $database;
		do
		if [ "${db}" == "DWH_PRD" ]; then
			ddlscript=/opt/check_mk/lib/local/db2checkviews_${db}.ddl
		else
			ddlscript=/opt/check_mk/lib/local/db2checkviews.ddl
		fi
		su - $instance -c "db2 connect to ${db}  1>/dev/null 2>&1 ; cat ${ddlscript} | xargs db2 -ot " | grep -v -E "^1|\-\-\-|hush|MAIL" |grep -E "^[^ ]"|awk 'BEGIN { printf "P '${instance}':'${db}':View_State " } \
			{if (NR>1) printf "|" }\
			{ printf $1"="2";"1";"1 }\
			# print the viewschema and name as performance parameter and set its value to 1 (=CRIT)
			END { if (NF>0) print " there are views in state inoperable" 
			# check if number of lines greater than 0, if so, print the message "views inoperable"
				else print "count="0";"1";"1" all views in state normal" }' 
			# if no records returned print the message "all views in state normal"
	done
done

