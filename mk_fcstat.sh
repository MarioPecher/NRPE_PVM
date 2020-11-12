#!/usr/bin/ksh
# Check AIX fc stats 
# Author: Daniel Rakowski
# Last Change : 20190725
# Version : 1.0
for dev in $(lsdev |grep fcs |awk {'print $1'}); 
do 
#fcstat $dev |grep -i -E "count|requests|dumped|[^^]frames|bytes" |sed 's/\ //g'| awk 'BEGIN { FS=":"; printf "P '${dev}'_fcstat "}\
fcstat $dev |grep -i -E "count" |sed 's/\ //g'| awk 'BEGIN { FS=":"; printf "P '${dev}'_fcstat "}\
	{ if ( NR>1 ) printf "|" }\
	{ printf $1"="$2}\
	END { print " AIX fcstat Values"}'
done	
