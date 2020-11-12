#!/bin/ksh
# determine dbb diaglevel value
# #############################################################################
# HRI IT-Consulting GmbH
# Team PowerVM
# System Management Scripts and Tools
# -----------------------------------------------------------------------------
# COMPONENT:         Monitoring CheckMK
# NAME:              mk_db2diaglvlcheck.sh
# USAGE:             mk_db2diaglvlcheck.sh
# PATH:              /opt/check_mk/lib/local/
# VERSION:           1.0.0
# PLATFORM:          AIX
# CREATED:           2020.02.26 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2020.02.26 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     IBM DB2
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Version       Date / Time           Name              Remarks
# 1.0.0         2020.02.26 / 10:17    MPecher (ITC)     initial version
#                                                     
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# ----------------------------------------------------------------------------

MY_DB2_INSTANCE=NULL

MY_HWARN=4
MY_HCRIT=5

MY_LWARN=2
MY_LCRIT=1

MY_DIAGSTATE=9

MY_SERVICE="DB2_diagLevel"
MY_PERFTXT=""
MY_STATUSTXT=" DB2 LOG Level for db2diag.log"

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

#function instance running
#ps -ef|grep db2sysc|grep -v root
func_checkInstRun(){
        ps -ef|grep db2sysc|grep -v root|awk '{print $1}'
        # delivers all running instances
        }

#function get dbm cfg value
#su - db2inst2 -c "db2 get dbm cfg "|grep DIAGLEVEL|awk '{print $7}'
func_getDBMcfg(){
        su - ${MY_INSTANCE} -c "db2 get dbm cfg "|grep DIAGLEVEL|awk '{print $7}'
        }

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

for MY_INSTANCE in $(func_checkInstRun);
        do
#        echo "Instance is: $MY_INSTANCE";
        MY_DIAGSTATE=$(func_getDBMcfg);
#        echo "DIAGSTATE is: $MY_DIAGSTATE";
        
        if [[ "$MY_DIAGSTATE" != "9" ]]; then
        
          MY_PERFTXT="DIAGLEVEL=$MY_DIAGSTATE;$MY_LWARN:$MY_HWARN;$MY_LCRIT:$MY_HCRIT"
        
        else
        
          MY_PERFTXT="NO_DIAGLEVEL_readable=3;$MY_LWARN:$MY_HWARN;$MY_LCRIT:$MY_HCRIT"
          MY_STATUSTXT=${MY_STATUSTXT}" could NOT be read from dbm cfg of ${MY_INSTANCE}"
        
        fi
        echo "P ${MY_SERVICE}:${MY_INSTANCE} ${MY_PERFTXT} ${MY_STATUSTXT}"
done
# -----------------------------------------------------------------------------
# end of main
# -----------------------------------------------------------------------------
