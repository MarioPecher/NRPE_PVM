#!/bin/ksh
# determine LOCKWAIT on JDE NextNumbering
# #############################################################################
# HRI IT-Consulting GmbH
# Team PowerVM
# System Management Scripts and Tools
# -----------------------------------------------------------------------------
# COMPONENT:         Monitoring CheckMK
# NAME:              mk_db2lockwaitNN.sh
# USAGE:             mk_db2lockwaitNN.sh
# PATH:              /opt/check_mk/lib/local/
# VERSION:           1.0.0
# PLATFORM:          AIX
# CREATED:           2020.02.06 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2020.02.06 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     DB2 & JDE
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Version       Date / Time           Name            Remarks
# 1.0.0         2020.02.06 / 10:17    MPecher (ITC)   initial version
#                                                     added header
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# -----------------------------------------------------------------------------
# Parameter

MY_DB2_INSTANCE=""
MY_INSTANCE=""
MY_DATABASE=""
MY_DB=""
MY_NN_LOCKWAITS=""

MY_SERVICE="DB2_lockwait_JDE_NN"

MY_RC=3 #UNKNOWN
MY_PERFTXT=""
MY_STATUSTXT=" DB2 LOCKWAITS on JDE NextNumbering "
MY_COUNT=2

MY_WARN=1  
MY_CRIT=2  

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

# get db2 instances
MY_DB2_INSTANCE=$(ps -ef |grep db2sysc | grep -v -E "root|hush|MAIL"|awk {'print $1'}|grep db2)
# echo "Insatnces: $MY_DB2_INSTANCE"

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

for MY_INSTANCE in $MY_DB2_INSTANCE;
  do
  MY_PERFTXT="";
#  echo "Insatnces: $MY_INSTANCE" ;
  MY_DATABASE=$(su - $MY_INSTANCE -c 'db2 list db directory' |grep -p Indirect|grep "Database alias"|awk {'print $4'}) ;

  for MY_DB in $MY_DATABASE;
    do
    MY_COUNT=0 ;

    if [[ $MY_DB == "" ]]; then
      MY_PERFTXT="NO_JDE_DB=${MY_COUNT};${MY_WARN};${MY_CRIT}" 
    else

     if [[ $MY_DB == "OW_PROD" || $MY_DB == "OW_CRP" ||$MY_DB == "OW_DEV" ]]; then

      MY_NN_LOCKWAITS=$(su - $MY_INSTANCE -c "db2pd -wlocks detail -db $MY_DB|awk '{print $13}'|grep -i F0002 "|grep -vE "Database|MAIL|hushlogin")

      for MY_LOCKWAIT in $MY_NN_LOCKWAITS;
        do
          MY_COUNT=$(print "$MY_COUNT + 1"|bc)
        done
      
      if [[ "${MY_PERFTXT}" != "" ]]; then
	MY_PERFTXT="${MY_PERFTXT}""|"
      fi

      MY_PERFTXT=${MY_PERFTXT}"${MY_DB}=${MY_COUNT};${MY_WARN};${MY_CRIT}" ;
 #     echo "P ${MY_SERVICE}:${MY_INSTANCE} ${MY_PERFTXT} ${MY_STATUSTXT}" 
     fi
    fi
    done
  if [[ "${MY_PERFTXT}" == "" ]]; then
    MY_PERFTXT="NO_JDE_DB=${MY_COUNT};${MY_WARN};${MY_CRIT}"
  fi
  echo "P ${MY_SERVICE}:${MY_INSTANCE} ${MY_PERFTXT} ${MY_STATUSTXT}"
  done

# -----------------------------------------------------------------------------
# end main
# -----------------------------------------------------------------------------
