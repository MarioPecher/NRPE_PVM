#!/bin/ksh
#
# This script generates a Monitoring Output for Check_MK.
# Its purpos is to check if are undesired states in the rpdomain
#
# Author Mario Pecher
# last change 20170606
#

# Parameter
RC=0
PERFTXT=""
STAUSTXT=""
COUNT=2

WARN=800
CRIT=900

echo `su - db2inst1 -c 'db2 list applications |grep LOCAL|wc -l'|grep -vE "login|MAIL"` > $PWD/DB2CONCOUNT.txt
typeset - i CONCOUNT=$(cat $PWD/DB2CONCOUNT.txt)
#echo $CONCOUNT

if [[ $CONCOUNT -gt $WARN ]]; then
	if [[ $CONCOUNT -gt $CRIT ]]; then
		RC=2
	else
		RC=1
	fi
else
	RC=0
fi
	

PERFTXT="CONCOUNT=$RC;1;2"
STATUSTXT="CONCOUNT= $CONCOUNT STatus Txt "



echo "P DB2_ConnectionCount ${PERFTXT} DB2 Connection Count Check ${STATUSTXT}"
