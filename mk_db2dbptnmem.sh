# # # # # #
# checks the db2 database partition mem util
# Author: Daniel Rakowski / Johannes Fehr
# Last change: 20160126
db2_home=$(cat /etc/passwd | grep db2ins | awk -F":" {'print $6'} | sort | head -1)

lparmem=$(expr `lparstat | grep mem |awk -F"=" {'print $6'} | sed -e 's/MB\ psize//g'` \* 1024)
CUWARN=$(echo $lparmem | awk '{printf("%8.2f\n", $1*0.92)}')
CUCRIT=$(echo $lparmem | awk '{printf("%8.2f\n", $1*0.95)}')
# determine db2 instances
db2_instances=$(ps -ef |grep db2sysc |grep -v grep| awk {'print $1'})
# check db2 dbptn mem for each instance
for instance in $db2_instances; 
do
su - $instance -c ' db2pd -dbptnmem ' | grep -E "Memory Limit|Current usage|HWM usage|Cached memory"|sed 's/KB//g' |sed 's/\ //g' | awk -F":" 'BEGIN \
	{ printf "P DB2_DBPTN_'${instance}' "}\
	{ if (NR >1) printf "|" }\
	{ printf $1"=" $2";'${CUWARN}';'${CUCRIT}'"}\
	END {print " DB2 Database Partition Memory Utilization Header for instance '${instance}' "}' 

done
