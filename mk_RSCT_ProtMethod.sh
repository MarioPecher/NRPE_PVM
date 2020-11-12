#!/bin/ksh
# determine RSCT ProtMethod setting
# #############################################################################
# HRI IT-Consulting GmbH
# Team PowerVM
# System Management Scripts and Tools
# -----------------------------------------------------------------------------
# COMPONENT:         Monitoring CheckMK
# NAME:              mk_RSCT_ProtMethod.sh
# USAGE:             mk_RSCT_ProtMethod.sh
# PATH:              /opt/check_mk/lib/local/
# VERSION:           1.0.0
# PLATFORM:          AIX
# CREATED:           2019.15.16 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# LAST CHANGE:       2019.12.16 / 15:21 by PowerVM / Mario Pecher (HRI-ITC)
# PERMISSIONS:       rwxr-xr-x (755)
# OWNER:             root.system
# PREREQUISITES:     IBM DB2
# -----------------------------------------------------------------------------
# CHANGE HISTORY
# Version       Date / Time           Name              Remarks
# 1.0.0         2019.12.16 / 10:17    DRakowski         initial version
#
# #############################################################################

# -----------------------------------------------------------------------------
# declarations
# ----------------------------------------------------------------------------

MY_LOWWARN=3
MY_UPWARN=4
MY_LOWCRIT=2
MY_UPCRIT=6

MY_PROTMETH=7
MY_PROTMEHTstate=""

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

######
#func_getProtMeth
######
func_getProtMeth(){
        MY_PROTMETH=$(lsrsrc -c IBM.PeerNode CritRsrcProtMethod|grep =|awk '{print $3}')
        }

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

func_getProtMeth

### check for desired state = 3

MY_PROTMEHTstate="CritRsrcProtMethod=${MY_PROTMETH};$MY_LOWWARN:$MY_UPWARN;$MY_LOWCRIT:$MY_UPCRIT"

echo "P RSCT_CritRsrcProtMethod ${MY_PROTMEHTstate} AIX RSCT PeerNode CritRsrcProtMethod Check"

# -----------------------------------------------------------------------------
# end of main
# -----------------------------------------------------------------------------
