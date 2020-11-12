#!/usr/bin/ksh
# determine e1 app server state
rg_srv="sdacind501"
rg_host=$(ssh root@$rg_srv hostname)
node=$(hostname)
if [ $rg_host == $node ];
then
        /usr/local/bin/db2inst3d status
        state=$?
        if [ $state != "1" ] ;
         then

                STATUS=2
                echo $STATUS ${rg_srv}_home HOME=$rg_host CRITICAL - Resource Group $rg_srv.rg should be running, but does not!
        else
                STATUS=0
                echo "$STATUS ${rg_srv}_home HOME=$rg_host OK - Resource Group $rg_srv.rg is running on node $node"
        fi;
else
        STATUS=3
	echo "$STATUS ${rg_srv}_home HOME=$rg_host OK - Node $node is not Resource Group Home"
fi;
