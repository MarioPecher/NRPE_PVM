#!/bin/ksh
#
#Skript zum Status Check der Processor Threads
#v1.0 jfe

state=$(smtctl |grep "proc0 has" |cut -c 11)

if [ "$state" -ge 8 ]; then
	status=0
	statustxt=OK
elif [ "$state" -lt 8 ]; then
	status=1
	statustxt=WARNING
elif [ "$state" -lt 4 ]; then
	status=2
	statustxt=CRITICAL
fi

echo "$status SMT_Threads state=$status $state $statustxt"
