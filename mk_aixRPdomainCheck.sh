#!/bin/ksh
#
# This script generates a Monitoring Output for Check_MK.
# Its purpos is to check if are undesired states in the rpdomain
#
# Author Mario Pecher
# last change 20170526
#

# Parameter
RPDname=""
RPDstate="offline"
RC=3
#LSSAMstate="$('lssam |grep -v Online|grep -v Offline|awk "{print $2}"')"
LSSAMstates="$(lsrsrc -ab -D ";" -s "ResourceType=0" IBM.Application | awk 'FS=";" {print $32":"$1":"$33}'|tail +3)"
StatusTXT=""
PerfTXT=""

### get rpdomain name
RPDname=$(lsrpdomain|awk '{print $1}'|grep -v "Name")

### check rpdomain state offline online else
RPDstate="$(lsrpdomain|awk '{print $2}'|grep -v Op)"

if [[ "${RPDstate}" != "Online" ]]; then # WARN
	RC=1
	#StatusTXT="RPDomain ${RPDname} is ${RPDstate}!"
else
	for LSSAMstate in ${LSSAMstates}; do 
		if [[ "${PerfTXT}" != "" ]]; then
			PerfTXT="${PerfTXT}""|""<br>"
		fi
		#echo $LSSAMstate
		host=$(echo $LSSAMstate|awk 'FS=":" {print $1}')
		#echo $host
		res=$(echo ${LSSAMstate}|awk 'FS=":" {print $2}')
		#echo $res
		state=$(echo ${LSSAMstate}|awk 'FS=":" {print $3}')
		#echo $state
		if [[ "${state}" -eq "1" ]]; then 	
			RC=0
			#StatusTXT="RPDomain is Online."
		else
			RC=2
			#StatusTXT=" but Member $res on $host is in ProblemState!"
		fi
		PerfTXT="${PerfTXT}""${res}on${host}=${RC};1;1"
	done
fi

StatusTXT="RPDomain ${RPDname} is ${RPDstate}!"

echo "P aixRPDomainCheck ${PerfTXT} ${StatusTXT}"
