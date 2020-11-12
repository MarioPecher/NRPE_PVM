#!/usr/bin/ksh
# Check AIX Tuning Values
# Author: Daniel Rakowski
# Last Change : 20161010
# Version : 1.0
# grep Config File
grep -E "^[^#]" mk_aixTuning.conf | awk 'BEGIN { FS=":" ; printf "P AIX_Tuning "}\
	{ cmd=$2 }\
	{ cmd"|tr -d [[:space:]]" |  getline result}\
	{ split(result,value,"=")}\
	{ if ( NR>1 ) printf "|" }\
	{ printf $1"="value[2]";"$5":"$6";"$5-2":"$6+10 }\
	END { print " AIX Device Tuning Values"}'
	
