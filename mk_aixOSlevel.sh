#!/bin/ksh
# determine OSLevel Match in AIX DB Cluster
# #############################################################################
# HRI IT-Consulting GmbH
# Team PowerVM
# System Management Scripts and Tools
# -----------------------------------------------------------------------------
# COMPONENT:         Monitoring CheckMK
# NAME:              mk_aixOSlevel.sh
# USAGE:             mk_aixOSlevel.sh
# PATH:              /opt/check_mk/lib/local/
# VERSION:           1.0.1
# PLATFORM:          AIX
# CREATED:           2019.11.15 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2019.11.15 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     IBM SpectrumScale (GPFS)
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Version       Date / Time           Name            Remarks
# 1.0.0         2017.12.12 / 10:17    Mpecher (ITC)   initial version
# 1.0.1         2019.11.15 / 10:17    MPecher (ITC)   V1.0.1 WARN=1 because of CheckMK updt
#                                       added header
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# -----------------------------------------------------------------------------

RC=3
PERFTXT=""
STAUSTXT=""
COUNT=2
WARN=1          #CMK Fix
CRIT=2

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

#none

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

oslvls=$(mmdsh oslevel -s|awk '{print $2}')

count=0
prev_oslvl=""
for oslvl in $oslvls;
do
#       echo "OsLevel: "${oslvl}
#       echo "Count 1: "${count}
        if [[ ${count} == 0 ]]; then

                let "count = count + 1"
#               echo "Count 2: "${count}
                prev_oslvl=${oslvl}
#               echo "Prev_OsLvl: "${prev_oslvl}

        else

                if [[ "${prev_oslvl}" -ne "${oslvl}" ]]; then

                        let "count = count + 1"
#                       echo "Count 3: "${count}
                fi
        fi
done

if [[ ${count} != 1 ]]; then
        RC=1
        STATUSTXT=" OSLevels in Cluster do NOT match! "
else
        RC=0
        STATUSTXT=" OSLevels in Cluster match. "
fi


PERFTXT="ClusterOSLevel=${RC};${WARN};${CRIT}"

echo "P aix_OsLevelcheck ${PERFTXT} AIX Cluster OsLevel Check ${STATUSTXT}"

# -----------------------------------------------------------------------------
# end of main
# -----------------------------------------------------------------------------
