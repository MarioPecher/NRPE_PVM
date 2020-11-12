#!/bin/ksh
#
#Skript zum lock Chain 
# AUTHOR: Daniel Rakowski
# Last Change: 20170808 
WARN=1
CRIT=2
db2_instance=$(ps -ef |grep db2sysc | grep -v -E "root|hush|MAIL"|awk {'print $1'}|grep db2)
#echo $db2_instance
#database=$(su - $dbinstance  -c 'db2 list db directory' |grep -p Indirect| grep "Database alias"|awk {'print $4'})
#echo $database

for instance in $db2_instance;
do
database=$(su - $instance -c db2 list db directory |grep -p Indirect| grep "Database alias"|awk {'print $4'})
for db in $database;
do
su - $instance -c "db2 connect to ${db} 1>/dev/null 2>&1 ; cat /opt/check_mk/lib/local/db2checklogchain.ddl| xargs db2 -o " | grep -v -E "\-\-\-|hush|MAIL" |grep -E "^[^ ]"|awk 'BEGIN { } \
			{ table=table$0"<br>" }\
			END { if ( NR <2 ){ table="" } ; print "P DB2_Lockchain_'${instance}':'${db}' count="NR-1";'${WARN}';'${CRIT}' "NR-1" Lockwaits Lockchain Output: <br>"table }'  
done
done

