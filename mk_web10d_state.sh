#!/usr/bin/ksh
# determine e1 app server state
rg_srv="sdacweb10d"
rg_host=$(ssh root@$rg_srv hostname)
node=$(hostname)
if [ $rg_host == $node ];
then

                STATUS=0
                echo "$STATUS ${rg_srv}_home HOME=$rg_host OK - Resource Group $rg_srv.rg is running on node $node"
else
        STATUS=3
	echo "$STATUS ${rg_srv}_home HOME=$rg_host OK - Node $node is not Resource Group home" 
fi;
