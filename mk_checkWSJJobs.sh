#!/bin/ksh
#
# Script check e1 batch execution times
# AUTHOR: Daniel Rakowski (IGEPA-ITS)
# Last Change: 20191219
# Changed by:   Mario Pecher (HRI-ITC)
#
##############################
db2_instance=db2inst1
E1Release=920
TWARN=1500
TCRIT=150000
#TCRIT=150000
JWARN=35
JCRIT=210
ddlscript=/opt/check_mk/lib/local/db2checkWSJCTL.ddl
for instance in $db2_instance;
        do
        database=owsh${E1Release}
        for db in $database;
                do
                        su - $instance -c "db2 connect to ${db}  1>/dev/null 2>&1 ; db2 -tf ${ddlscript}"| grep -v -E "^1 |\-\-\-|hush|MAIL|EXP|DB20" |grep -E "^[^ ]" |awk 'BEGIN { printf "P 'E${E1Release}':'${db}':WSJCTL " } \
                        { if ( NR > 1 ) printf "|" }\
                        { printf $3"_"$4"_"$1"_"$6"="$NF";"'$TWARN'";"'$TCRIT' }\
                        END { if ( NR>0 ) print "|JOBS="NR";"'${JWARN}'";"'$JCRIT'" there are "NR" jobs running in E"'${E1Release}'
                        # check if number of lines greater than 0, if so, print the message "views inoperable"
                                else print "JOBS="NR";"'${JWARN}'";"'$JCRIT'" there are NO Jobs Executions in Warning State in E"'${E1Release}' }'
                        # if no records returned print the message "all views in state normal"
        done
done

