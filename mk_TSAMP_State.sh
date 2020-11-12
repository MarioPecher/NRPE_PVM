#!/bin/ksh
# determine RSCT state
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
# CREATED:           2019.11.08 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2019.11.08 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     IBM SpectrumScale (GPFS)
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Date / Time           Name            Remarks
# 2019.11.08 / 10:17    DRakowski       initial version
# 2019.11.08 / 10:17    MPecher         V1.0.1 WARN=1 because of CheckMK updt
#                                       added header
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# -----------------------------------------------------------------------------

MY_NODE=`cat /var/ct/cfg/ctsec.nodeinfo | grep $( cat /var/ct/cfg/ct_node_id | head -n 1)| grep NAME | awk {'print $3'}`
MY_PATTERN="IBM.RecoveryRMd IBM.GblResRMd IBM.TestRMd IBM.StorageRMd"
#MY_PATTERN="IBM.GblResRMd"
MY_WF=/opt/check_mk/mk_TSAMP_state.wf

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

#none

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

for MY_PATTERN_LOOP in $MY_PATTERN;
do
        /usr/bin/pidmon */rsct/bin/$MY_PATTERN_LOOP
        MY_STATE=$?
        if [ $MY_STATE -eq 1 ]; then
        MY_STATE=0
        case $MY_PATTERN_LOOP in
                "IBM.RecoveryRMd" )
                lsrg -Ab |grep -E "Resource Group 1|lsrg" >$MY_WF

                ;;
                "IBM.GblResRMd" )
                lsrsrc -t -s "ResourceType=0" IBM.Application Name OpState | grep IBM.Application >$MY_WF
                ;;
                "IBM.TestRMd" )
                lsrsrc IBM.Test Name OpState | grep IBM >$MY_WF
                ;;
                "IBM.StorageRMd" )
                lsrsrc IBM.AgFileSystem Name MountPoint DeviceName NodeNameList| grep IBM >$MY_WF
                ;;
        esac
        if [ -z $( cat ${MY_WF}) ]; then
                MY_STATE=2
        fi
        else
        MY_STATE=2
        fi
        printf ${MY_PATTERN_LOOP}=${MY_STATE}";1;2" #20191108 bug fix State falsch übergeben
        printf "|"
done | sed 's/|$//g;s/^/P RSCT:State:'${MY_NODE}' /g;s/$/ RSCT Env Status on node '${MY_NODE}' /g'
echo ""

# -----------------------------------------------------------------------------
# end of main
# -----------------------------------------------------------------------------
