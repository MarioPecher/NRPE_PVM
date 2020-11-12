#!/bin/ksh
#
# Check if known Filesystems are mounted and available
# #############################################################################
# HRI IT-Consulting GmbH
# Team PowerVM
# System Management Scripts and Tools
# -----------------------------------------------------------------------------
# COMPONENT:         Monitoring CheckMK
# NAME:              mk_TSAMP_State.sh
# USAGE:             mk_TSAMP_State.sh
# PATH:              /opt/check_mk/lib/local/
# VERSION:           1.0.1
# PLATFORM:          AIX
# CREATED:           2017.05.24 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2019.11.14 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Date / Time           Name            Remarks
# 2017.05.24 / 10:17    DRakowski       initial version
# 2019.11.14 / 10:17    MPecher         V1.0.1 WARN=1 because of CheckMK updt
#                                       added header
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# -----------------------------------------------------------------------------

MY_WARN=1
MY_CRIT=2

MY_EXCLUDEFS=proALPHA

# get Filesystem Types
FS_TYPs=$(cat /etc/filesystems |grep -viEp "${MY_EXCLUDEFS}"|grep -v "*"|grep -v "procfs"|grep -e "vfs"|awk '{print $3}'|sort|uniq)

# get known Filesystems with Types
set -A KNOWN_FSs $(cat /etc/filesystems |grep -viEp "${MY_EXCLUDEFS}"|awk '{print $1}'|grep /|sed s/://)
set -A KNOWN_FS_TYPs $(cat /etc/filesystems  |grep -viEp "${MY_EXCLUDEFS}"|grep -v "*"|grep -e "vfs"|awk '{print $3}')


# get mounted Filesystems
MOUNTED_FSs=$(mount |grep -viE "${MY_EXCLUDEFS}"|grep -v -E "node|---"| sed 's/^         \//server \//g' |awk '{print $3}')

COUNT=0
FSstate=""
RC=null


# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

#none

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

### fuer sortierung nach FS-Typen
for FS_TYP in ${FS_TYPs}; do
        COUNT=0
        FSstate=""

        ### Fuer jeden KNOWN_FS_TYP in KNOWN_FS_TYPs
        for KNOWN_FS_TYP in ${KNOWN_FS_TYPs[*]}; do

                ### Pruefe ob KNOWN_FS_TYP gleich FS_TYP
                if [[ "${KNOWN_FS_TYP}" == "$FS_TYP" ]]; then

                mounted=no

                ### pruefe ob das aktuellen knownFS gemounted ist
                for MOUNTED_FS in ${MOUNTED_FSs}; do
                        if [[ "${KNOWN_FSs[$COUNT]}" == "$MOUNTED_FS" ]]; then
                                mounted=yes
                        fi
                done

                if [[ "$mounted" == "yes" ]]; then
                        RC=0
                else
                        RC=1
                fi
                        if [[ "${FSstate}" != "" ]]; then
                                FSstate="${FSstate}""|"
                        fi
                FSstate="${FSstate}${KNOWN_FSs[$COUNT]}=${RC};$MY_WARN;$MY_CRIT"        #cmk fix
                fi
                COUNT=$COUNT+1
        done

        echo "P aix_FSmountCheck_$FS_TYP ${FSstate} AIX FileSystem MountCheck"

done

#echo "P aix_FSmountCheck ${FSstate} AIX FileSystem MountCheck"

# -----------------------------------------------------------------------------
# end of main
# -----------------------------------------------------------------------------
