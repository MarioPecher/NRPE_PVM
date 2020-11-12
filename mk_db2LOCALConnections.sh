# # # # # #
# checks the db2 database LOCAL a√pplication count 
# Author: Daniel Rakowski and Mario Pecher 
# Last change: 20171116

db2_home=$(cat /etc/passwd | grep db2ins | awk -F":" {'print $6'} | sort | head -1)

WARN=500
CRIT=800

# determine db2 instances
db2_instances=$(ps -ef |grep db2sysc |grep -v grep| awk {'print $1'})

# check db2 dbptn mem for each instance
for instance in $db2_instances; 
do
su - $instance -c ' db2 list applications | grep LOCAL '  | awk -F":" 'BEGIN \
	{ printf "P DB2_LOCALCONN_'${instance}' "}\
	END {print "count="FNR";"'${WARN}'";"'${CRIT}'" DB2 Database LOOPBACK Connections '${instance}' "}' 

done

### IPC Connections
typeset -i IPCcount=`ipcs -s|wc -l`
echo "P DB2_IpcConnections IPCconnections=${IPCcount};${WARN};${CRIT} DB2 IPC Connections "
