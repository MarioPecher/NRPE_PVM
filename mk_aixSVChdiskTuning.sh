#!/usr/bin/ksh
# Check AIX Tuning Values
# Author: Daniel Rakowski
# Last Change : 20161010
# Version : 1.0
# grep Config File
for device in $(lspv -u |grep IBMfcp| grep -E "^hdisk[0-9]"  | cut -f 1 -d " ");
do
echo "P ${device}_tuning \c"
grep -E "^[^#]" mk_aixhdiskTuning.conf | awk 'BEGIN { FS=":" ;}\
	{ gsub(/_dev_/,"'${device}'",$2); cmd=$2 }\
	{ cmd | getline result }\
	{ split(result,value," ")}\
	{ if ( NR>1 ) printf "|" }\
	{ printf $1"="value[2]";"$5":"$6";"$5-1":"$6+11 }\
	END { print " AIX hdisk Device Tuning Values"}'
	
done
