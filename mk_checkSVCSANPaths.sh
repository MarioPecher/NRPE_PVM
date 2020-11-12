#!/bin/ksh
# Author Daniel Rakowski
# last change 20170407


# get hdisks
devices=$(lspv -u |grep IBMfcp | grep -v None | awk {'print $1'})
# loop over device list
for device in $devices; do
# get sddpcm device id 
dev=$(pcmpath query device | grep -E "${device} " | awk {'print $2'})
# get count closed paths
closed_paths=$(pcmpath query device $dev | grep -E "^   " | \
	awk 'BEGIN {closed_paths=0}\
	{
	if (  $3 !~ '/OPEN/' ) closed_paths=closed_paths+1;
	}
	END { print closed_paths }')
# get svc node ids and counts
lspath -l $device -H -F"name parent path_id connection status" | sed '1,2d'| sort -nk2,3 | awk 'BEGIN\
	{ printf "P '${device}'_Path_Registration "; 
		node="";
		nodes="";
		nodecount=0; 
		pair=0;
		count=0;
		count_enabled=0; 
		pairs=0} \
	{ ### MAIN LOOP ###
		node=substr($4,match($4,",")-2,2)
 		fcs=$2 
		hdd=$1 
		count=count+1
		pairs=pairs+1
		if ( $5 ~ '/Enabled/' ) count_enabled=count_enabled+1
		if (fcs ~ fcsbefore) {
			### Addition ###
			if (node ~ nodebefore) {
			if ((count/pairs) % 2==0) pair=pair+1
			}
		}
		pairs=0
		#print "fcs="fcs";Pairs="pairs"; Pair="pair"; Count="count";node= "node";" 
		nodebefore=node
		#print " "
		if ( ! match(nodes,node)){
			nodecount=nodecount+1 
		#	print nodecount
			nodes=nodes";"node
			} 
	}
	# continue check_mk output
#	END{print "count="count*-1";-4;-2|count_enabled="count_enabled*-1";-7;-4|pairs="pair*-1";-3;-2|closed_paths='$closed_paths';1;4|nodes="nodecount*-1";-1;-1 Harddisk '$device' is registered on "nodecount" nodes"
	END{print "count="count*-1";-4;-2|count_enabled="count_enabled*-1";-7;-4|closed_paths='$closed_paths';1;4|nodes="nodecount*-1";-1;-1 Harddisk '$device' is registered on "nodecount" nodes"
}' 2>/dev/null	
done

