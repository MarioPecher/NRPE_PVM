#!/bin/ksh
#
# checking errpt for entries
# script is provided 'as-is' without any kind of warranty
#
# Maik Haehnel, IBM, mhaehnel@de.ibm.com
#               Fritz & Macziol GmbH, mhaehnel@fum.de
# modified by Daniel Rakowski, IGEPA IT-SERVICE GmbH
# parameter:
# ----------
# no parameters
#
# configuration:
# --------------
# see errpt.new.exclude.cfg file


# script itself
# -----------------------------------------

# get working directory
WDIR=$(dirname $0) 

if [ -f $WDIR/errpt-new-lastrun.cfg ]; then

. $WDIR/errpt-new-lastrun.cfg

fi 
EXCLUDE_ERRPT=$(cat $WDIR/errpt-new-exclude.cfg|grep -v "#")
# get current time, read last check time and save new one 
LASTCHECK="0101000005"
# check if the script variable LASTRUN is not empty
if [[ $LASTRUN != "" ]]
then
	# Set LASTCHECK to LASTRUN Value 
  	LASTCHECK=$LASTRUN
fi

# set LASTRUN to the current Timestamp and write this to file
LASTRUN=$(date +%m%d%H%M%y)
echo "LASTRUN=${LASTRUN}" > $WDIR/errpt-new-lastrun.cfg 

# print logwatch start pattern
#echo $LASTCHECK
echo "<<<logwatch>>>"
echo "[[[errorlog]]]"

# get sequence numbers of errpt entries since LASTCHECK 
SEQNUMBERS=$(errpt -as $LASTCHECK|grep "Sequence Number"|awk '{printf $3" "}')
#echo $SEQNUMBERS
if [[ -z $SEQNUMBERS ]]
then
  # no error entries, just return
  exit 0
fi

# no select only those for report
SEQREPORT=""

for i in $SEQNUMBERS
do
  # get entry identifier
  ENTRYIDENTIFIER=$(errpt -al $i|grep IDENTIFIER|awk '{ printf $2 }')
  # go through exclude list and check if entry should be excluded
  EXCL=0
  for excludestring in $EXCLUDE_ERRPT
  do
    if [[ $excludestring = $ENTRYIDENTIFIER ]]
    then
	EXCL=1
    fi 
  done
  if [[ $EXCL -eq 0 ]]
  then
    SEQREPORT="$SEQREPORT $i"
  fi
done

#if no entries exit
if [[ -z $SEQREPORT ]]
then
  #Nothing to do
  exit 0 
fi

# generate lines for each sequence number
#echo "$S_INFO Seq.Number  "$(errpt|grep DESCRIPTION)
for i in $SEQREPORT
do
  ERRPTLINE=$(errpt -l $i|grep -v DESCRIPTION)
  TYPE=$(echo $ERRPTLINE|awk '{ printf $3}')
  CLASS=$(echo $ERRPTLINE|awk '{ printf $4 }')
  errptlinetype="$S_ERROR"
  if [ $TYPE = "I" ]
  then
    errptlinetype="$S_INFO"
  fi

  if [ $TYPE = "T" ]
  then
    errptlinetype="$S_WARNING"
  fi

  echo "C $errptlinetype $i $ERRPTLINE"
done
#exit
exit 0
