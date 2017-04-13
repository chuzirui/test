#!/bin/bash
source /root/*lbaas*.sh
now1="$(date +'%Y%m%d%H%M%S')"
FILE='EXP_PM_VLB_'$now1.txt

for lb in $(nova list | egrep -o '172.20.10[4-7].[0-9]{1,3}'); do cat tip.sh|sshpass -p 'CMCC123!@#' ssh -o StrictHostKeyChecking=no -p 2222 root@$lb; done 1>test.txt 
now2="$(date +'%Y%m%d %H:%M:%S')" ;sed -i "s/20[0-9][0-9][^;]*/$now2/1" test.txt 
grep '20[1-2][0-9]' test.txt | sort | uniq >> $FILE 
cat $FILE | cut -f 2 -d ";" > vtm-lb.list
neutron lbaas-loadbalancer-list | grep ACTIVE | cut -f 2 -d "|" > lb.list
for a in $(cat vtm-lb.list | sort | uniq) ; do sed -i "/$a/d" lb.list; done
for a in $(cat vtm-lb.list); do echo "$now2;$a;1;0;0;0;0;0;0;0" >>$FILE; done 
HOST='172.20.41.3'
USER='ftpuser'
PASSWD='e#Vg_1B7ln'
echo $FILE
yum -y install ftp 
ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
cd /var/lib/cmagent/loadbalancer/input/
put $FILE
quit
END_SCRIPT
#rm -rf $FILE
exit 0

