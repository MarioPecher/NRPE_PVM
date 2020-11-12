#!/bin/ksh
#
# Check available filesystem space for DB backups
# Author:		Mario Pecher
# Last Change:	20170130
# Version:	1.1

# Warngrenze in Prozent
percent=5.0
#echo "percent: "$percent

#let "percent = $percent + 100.0"
#echo "percent: "$percent

percent=$(print "scale=2;$percent + 100.0"|bc)
#echo "percent2: "$percent

warn=$(print "scale=2;$percent / 100.0"|bc)
#echo "warn: "$warn

# get log and backup Filesystems
logfslist=$(mount |grep -E "logfs|backupfs"| sed 's/         \//server \//g' |awk '{print $3}')
# echo $logfslist
for logfs in $logfslist;
do
	# determine required space for DB backups
	
	backups=$(find /${logfs}/backups/ -name "*.db2inst*.*" -mtime -1 -print)
	if [[ $backups != "" ]]; then
		backupspace=$(find /${logfs}/backups/ -name "*.db2inst*.*" -mtime -1 -print|xargs -I {} istat {}|grep Length|awk '{print $5}'|sort -nr|head -1|awk '{ gbytes= $1/1024/1024/1024 }{sum +=gbytes}END{print sum}')
	#	echo $backupspace
	else
		backupspace=0
	fi

	# determine available FS space
	freespace=$(df -gv ${logfs}| awk '{ if (NR>1) print $4}')
	#echo "freespace: "$freespace

	spacewarn=$(print "scale=2;$backupspace * $warn"|bc)
	#echo "spacewarn: "$spacewarn

	if [[ "${freespace}" -ge "${spacewarn}" ]]; then
        	status=0
        	statustxt=OK
	elif [[ "${freespace}" -gt "${backupspace}" ]] && [[ "${freespace}" -le "${spacewarn}" ]]; then
        	status=1
        	statustxt=WARNING
	elif [[ "${freespace}" -le "${backupspace}" ]]; then
        	status=2
        	statustxt=CRITICAL
	fi

	echo "$status DB_Backupspace$logfs state=$status|Freespace=$freespace|Backupspace=$backupspace $logfs Freespace=$freespace GB needed Backupspace=$backupspace GB $statustxt"

done
