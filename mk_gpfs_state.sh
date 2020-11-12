#!/usr/bin/ksh
# determine GPFS state
# #############################################################################
# HRI IT-Consulting GmbH
# Team PowerVM
# System Management Scripts and Tools
# -----------------------------------------------------------------------------
# COMPONENT:         Monitoring CheckMK
# NAME:              mk_gpfs_state.sh
# USAGE:             mk_gpfs_state.sh
# PATH:              /opt/check_mk/lib/local/
# VERSION:           1.1.0
# PLATFORM:          AIX
# CREATED:           2019.11.07 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2019.11.07 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     IBM SpectrumScale (GPFS)
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Date / Time           Name            Remarks
# 2019.11.07 / 10:17    unknown         initial version
# 2019.11.07 / 10:17    MPecher         V1.1.0 WARN=1 because of CheckMK updt
#                                       added header
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# -----------------------------------------------------------------------------

MY_NODE=$(hostname)
MY_WARN=1       #changed from 2 to 1 because of CheckMK update
MY_CRIT=1

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

#none

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

mmgetstate | awk 'BEGIN {state=0;  printf "P GPFS:State:"}\
        { if ( $2 ~ /'sdacdbn'/ ) {
                 printf $2" "$2"=";
                 if ( $3 !~ /'active'/ ) state=2;
                 print state";"'${MY_WARN}'";"'${MY_CRIT}'" GPFS Status on Node "$2;
                } }\
        END { }'

# -----------------------------------------------------------------------------
# end of main
# -----------------------------------------------------------------------------
