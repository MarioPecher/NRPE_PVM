#!/bin/ksh
# determine DNS config state
# #############################################################################
# HRI IT-Consulting GmbH
# Team PowerVM
# System Management Scripts and Tools
# -----------------------------------------------------------------------------
# COMPONENT:         Monitoring CheckMK
# NAME:              mk_TSAMP_State.sh
# USAGE:             mk_TSAMP_State.sh
# PATH:              /opt/check_mk/lib/local/
# VERSION:           1.1.1
# PLATFORM:          AIX
# CREATED:           2019.11.14 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2019.11.14 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Version       Date / Time           Name            Remarks
# 1.0.0         2019.11.14 / 10:17    MPecher         initial version
# 1.1.0         2019.11.14 / 10:17    MPecher         force bind4 check
# 1.1.1         2019.11.14 / 10:17    MPecher         WARN=1 because of CheckMK updt
#                                                     added header
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# -----------------------------------------------------------------------------
# Parameter
RC=0
PERFTXT=""
STAUSTXT=""
COUNT=2

MY_WARN=1       #enhancement & CMK Fix
MY_CRIT=2       #enhancement & CMK Fix

netsvc=$(cat /etc/netsvc.conf|grep -v "\#"|grep hosts)
#echo ${netsvc}

### netsvc.conf

#if [[ "${netsvc}" == "hosts=local4,bind4" || "${netsvc}" == "hosts=local,bind" ]]; then
if [[ "${netsvc}" == "hosts=local4,bind4" ]]; then
        RC=0
else
        RC=1
fi

PERFTXT="netsvc=$RC;$MY_WARN;$MY_CRIT"  #CMK Fix
STATUSTXT="netsvc is ${netsvc}"

### resolv.conf

### check if file exists

if [[ -e "/etc/resolv.conf" ]]; then
        #echo " resolv.conf exists "
        set -A nameserver $(cat /etc/resolv.conf|grep nameserver|awk '{print $2}')
        for server in 0 1
                do

                if [[ "${nameserver[$server]}" != "" ]]; then
                        RC=0
                else
                        if [[ "${RC}" == "1" ]]; then
                                RC=2
                        else
                                RC=1
                        fi
                        nameserver[$server]="! MISSING !"
                fi

        PERFTXT="nameserver=${RC};${MY_WARN};${MY_CRIT}|"${PERFTXT}     #CMK Fix
        STATUSTXT=" nameserver is ${nameserver[$server]} "${STATUSTXT}
        done

else
        #echo " resolv.conf does not exist "
        RC=0
        PERFTXT=""${PERFTXT}
        STATUSTXT=" resolv.conf does not exist "${STATUSTXT}
fi

echo "P aix_DNScheck ${PERFTXT} AIX DNS configuration Check ${STATUSTXT}"
