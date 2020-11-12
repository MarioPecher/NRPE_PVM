#!/bin/ksh
#
# Author Mario Pecher
# last change 20190227
#

#############
# Parameter
#############
MY_RC=3
PERFTXT=""
STATUSTXT=""
COUNT=2
WARN=1
CRIT=2
MY_RETRY=2
integer MY_I=0

#############
# functions
#############
func_times(){
	times=$(mmdsh date |awk '{print $5}')
	#echo "Times: "$times
	}

offsets=$(mmdsh ntpq -p |grep -v -E "=|re"|awk '{print $10}')
#echo "Offsets: "$offsets

count=0
#echo "Count: "$count

time1=""

func_checktimes(){

	for time in $times;
	do
		if [[ $count -eq 0 ]]; then

			let "count = count + 1"
#			echo "Count: "$count

			time1=${time}
#			echo "Time1: "${time1}
		else
#			echo "Time2: "${time}

			if [[ "${time}" == "${time1}" ]]; then
			
				MY_RC=0
			else
				MY_RC=2
			fi
		fi
	done
	}


func_retry(){
	sleep 1
	func_times
	func_checktimes
	}

########
# main
########

func_times
func_checktimes

### retry to get a synced tome code ###
if [[ $MY_RC != 0 ]]; then
	while MY_I < $MY_RETRY ; do
		func_retry;
		MY_I=$MY_I+1;
	done
fi

if [[ $MY_RC != 0 ]]; then
	STATUSTXT=" GPFS Time is NOT in Sync "
else
	STATUSTXT=" GPFS Time is in Sync "
fi


PERFTXT="TimeSync=${MY_RC};${WARN};${CRIT}"

echo "P aix_GPFSTimeSync ${PERFTXT} AIX GPFS Time Sync Check ${STATUSTXT}"
