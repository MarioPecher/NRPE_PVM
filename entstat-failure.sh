#!/bin/ksh
#
# script checks if entstat devices has failures
# script is provided 'as-is' without any kind of warranty
#
# parameter:
# ----------
# no parameters
#
# configuration:
# --------------
# no configuration

# script itself
# -----------------------------------------

function Checkentstat 
{ 
  en=$1
  checktext=$2
  col=$3
  valueexpected=$4

  value=$(entstat -d $en|grep "$checktext"|cut -f $col -d " ")
  for iv in $value
  do
    if [[ $iv -ne $valueexpected ]]
    then
      echo "$S_ERROR Adapter $en shows $checktext: $value (entstat -d $en)"
	RC=$value
     else 
	RC=0
	fi

  done
if [ -z "$RC" ] ; then
	RC=0
fi 
  return $RC
}


# get all ethernet interfaces
allifs=$(lsdev -Ct en|awk '{ printf $1" " }')

# go through ethernet devices and check them
for en in $allifs
do
  active=$(netstat -in|grep $en|cut -f 1 -d " ")
  if [[ $active != "" ]]
  then
#    echo "$S_INFO Checking $en"
    	Checkentstat $en "Transmit Errors" 3 0
	TransErr=$?
    	Checkentstat $en "Receive Errors" 6 0
    	ReceiveErr=$?
	Checkentstat $en "Packets Dropped" 3 0
    	DroppedPackTX=$?                                           
	Checkentstat $en "Packets Dropped" 6 0
    	DroppedPackRX=$?                                            
    	Checkentstat $en "CRC Errors" 7 0
    	CRCErr=$?                                    
	Checkentstat $en "Timeout Errors" 3 0
    	TimeoutsErr=$?                                          
	Checkentstat $en "Single Collision Count" 4 0
    	SingleColCount=$?                                              
	Checkentstat $en "Multiple Collision Count" 4 0
    	MultiColCount=$?                                                        

  fi
echo "P ${en}_entstat TransferErrors=${TransErr};1;2|ReceiveErrors=${ReceiveErr};1;2|DroppedPacketsTX=${DroppedPackTX};1;2|DroppedPacketsRX=${DroppedPackRX};1;2|CRCErrors=${CRCErr};1;2|TimeoutErrors=${TimeoutsErr};1;2|SingleCollisionCount=${SingleColCount};1;2|MultiCollisionCount=${MultiColCount};1;2 Ethernet Statistics for ${en}"
done

# exit
exit 0

