#!/usr/bin/ksh
# Check AIX Pagingspace Availability 
# Author: Daniel Rakowski
# Last Change : 20170228
# Version : 1.0
# grep Config File
if [ `lsps -a | grep -v Active | wc -l` -lt 1 ]; then
echo "2 AIX_PGSPC_AVAIL count=0 No Pagingspace defined"
else
lsps -a | grep -v Active| awk 'BEGIN { printf "P AIX_PGSPC_AVAIL "}\
	{ if ( NR > 1 ) printf "|" }\
	{ avail=2; auto=2 }\
	{ if ( $6 ~ "yes" ) avail=0 }\
	{ if ( $7 ~ "yes" ) auto=0 }\
	{ printf $1"_active="avail";1;1|"$1"_auto="auto";1;1" }\
	END { print " AIX Pagingspace Availability"}'
	
fi
