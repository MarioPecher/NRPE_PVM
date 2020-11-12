#!/bin/ksh
#
# Script check account with expiring password within the next 10 days
# AUTHOR: Daniel Rakowski
# Last Change: 20170516
db2_instance=db2inst1
E1Release=900
ddlscript=/opt/check_mk/lib/local/90/db2checkExpiringPasswd.ddl
for instance in $db2_instance;
	do
	database=owsh${E1Release}
	for db in $database;
		do
			su - $instance -c "db2 connect to ${db}  1>/dev/null 2>&1 ; db2 -tf ${ddlscript}"| grep -v -E "^1|\-\-\-|hush|MAIL|EXP|DB20" |grep -E "^[^ ]"|awk 'BEGIN { printf "P 'E${E1Release}':'${db}':ExpiringE1Account " } \
			{if (NR>1) printf "|" }\
			{ printf $1 }\
			{ printf "=" }\
			{ printf -1*$6";-10;-3"}\
			END { if (NF>0) print " there are expiring user accounts in E"'${E1Release}' 
			# check if number of lines greater than 0, if so, print the message "views inoperable"
				else print "count="0";"1";"1" there are NO expiring user accounts in E"'${E1Release}' }' 
			# if no records returned print the message "all views in state normal"
	done
done

