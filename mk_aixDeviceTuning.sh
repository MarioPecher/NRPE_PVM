#!/usr/bin/ksh
# Check AIX Tuning Values
# Author: Daniel Rakowski
# Last Change : 20161010
# Version : 1.0
# grep Config File
#tuningparams="num_cmd_elems|max_xfer_size"
tuningparams="num_cmd_elems"
for fc_adapter in $(lsdev| grep -E "^fcs[0-9]"  | cut -f 1 -d " ");
do
echo "P ${fc_adapter}_tuning \c"
grep -E "^[^#]" mk_aixDeviceTuning.conf | grep -E $tuningparams| awk 'BEGIN { FS=":" ;}\
	{ gsub(/_dev_/,"'${fc_adapter}'",$2); cmd=$2 }\
	{ cmd | getline result }\
	{ split(result,value," ")}\
	{ if ( NR>1 ) printf "|" }\
	{ printf $1"="value[2]";"$5":"$6";"$5-1":"$6+11 }\
	END { print " AIX Device Tuning Values"}'
	
done
