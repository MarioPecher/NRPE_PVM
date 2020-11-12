#!/bin/ksh
#
#Skript zum Status Check der HADR Datenbanken
#v1.0 jfe

db2_instance=$(ps -ef |grep db2sysc |awk {'print $1'}|grep db2)
#echo $db2_instance
#database=$(su - $dbinstance  -c 'db2 list db directory' |grep -p Indirect| grep "Database alias"|awk {'print $4'})
#echo $database

for instance in $db2_instance;
do
#for db in $database;
#do
database=$(su - $instance -c db2 list db directory |grep -p Indirect| grep "Database alias"|awk {'print $4'})
#echo $instance
#echo $database
for db in $database;
do
configured=$(su - $instance -c db2 get db cfg for $db |grep HADR_REMOTE_HOST|awk {'print $7'})
if [ "$configured" != "" ]; then

state=$(su - $instance -c db2pd -db $db -hadr |grep HADR_CONNECT_STATUS |head -1 |awk {'print $3'})
#echo $state

if [ "$state" == "CONNECTED" ];then
status=0
statustxt=OK
elif [ "$state" == "CONGESTED" ]; then
status=1
statustxt=WARNING
elif [ "$state" == "DISCONNECTED" ];then
status=2
statustxt=CRITICAL
else 
status=2
statustxt=CRITICAL
fi
echo "$status ${db}_HADR_STATUS state=$status $state $statustxt"
fi
done
done

