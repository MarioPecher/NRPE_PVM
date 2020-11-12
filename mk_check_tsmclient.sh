#!/bin/ksh
# Author: Daniel Rakowski
# last change: 20161222
# checks that the tsm client is running
# init
tsmclientroot=/usr/tivoli/tsm/client/ba/bin64/
optrgex=dsm_*.opt 
process=dsmcad
# get dsm opt files

optfiles=$(find ${tsmclientroot} -name ${optrgex})

for optfile in $optfiles;
do
	if [ $(ps -ef | grep ${process}|grep ${optfile}| grep -v grep | wc -l) -eq 1 ]; then
		echo "0 ${optfile} count=1 TSM Client Process using optfile ${optfile} is running"
	else
		echo "2 ${optfile} count=0 TSM Client Process using optfile ${optfile} is NOT running" 
	fi
done
