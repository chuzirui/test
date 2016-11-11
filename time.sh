#!/bin/bash
source /root/openrc-lbaas.sh
now1="$(date +'%Y%m%d%H%M%S')"
FILE='EXP_PM_VLB_'$now1.txt

for lb in $(nova list | egrep -o '172.16.254.[0-9]{1,3}'); do cat tip.sh|sshpass -p 'CMCC123!@#' ssh -o StrictHostKeyChecking=no -p 2222 root@$lb; done 1>test.txt 
grep '20[0-9][0-9]-' test.txt >> $FILE 
HOST='172.16.203.251'
USER='ftpuser'
PASSWD='clm123!@#'
echo $FILE

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
cd /apps/data/cmagent/loadbalancer/input
put $FILE
quit
END_SCRIPT
exit 0

