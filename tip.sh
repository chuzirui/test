#!/bin/bash
now="$(date +'%Y-%m-%d %H:%M:%S')"
now1="$(date +'%Y%m%d%H%M%S')"
pwd="CMCC123!@#"
user="admin"
for s in $(curl -s -k -u $user:$pwd https://$HOSTNAME:9070/api/tm/3.8/config/active/traffic_ip_groups   | json_pp | egrep -o '/api.*[0-9a-z]' )
do
    id=`echo $s| awk  'BEGIN{FS="/"} {print $8}'`
    #if grep -q  "raised" <<<$url; then
    for s1 in $(curl -s -k -u $user:$pwd https://$HOSTNAME:9070$s | json_pp)
    do
        for j1 in $(echo $s1 | egrep -o '[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}')
        do
            for host in $(curl -s -k -u $user:$pwd https://$HOSTNAME:9070/api/tm/3.8/status/ | json_pp | egrep -o 'api.*/')
            do
                if [[ $host =~ ^.*local.* ]]
                then
                foo=$host
                else
                    statistic=`curl -s -k -u $user:$pwd https://$HOSTNAME:9070/"$host"statistics/listen_ips/$j1`
                    bytes_in=`echo $statistic | sed -ne 's/.*\"bytes_in\":\([0-9]\{1,\}\).*/\1/g;p'`
                    bytes_out=`echo $statistic | sed -ne 's/.*\"bytes_out\":\([0-9]\{1,\}\).*/\1/g;p'`
                    if [[ $bytes_in =~ ^[0-9]+$ ]]
                    then
                    	r=`echo $statistic | sed -ne 's/.*\"total_requests\":\([0-9]\{1,\}\).*/\1/g;p'`
                    	max_conn=`echo $statistic | sed -ne 's/.*\"max_conn\":\([0-9]\{1,\}\).*/\1/g;p'`
                    	curr_conn=`echo $statistic | sed -ne 's/.*\"current_conn\":\([0-9]\{1,\}\).*/\1/g;p'`
                        let bytes_sum_in=bytes_sum_in+bytes_in;
                        let bytes_sum_out=bytes_sum_out+bytes_out; 
                        let r_sum=r_sum+r; 
                        let r_curr=r_curr+curr_conn; 
                        let r_max=r_max+max_conn; 
                    fi
                fi
            done
        done
    done
    let bit_in=bytes_sum_in*8
    let bit_out=bytes_sum_out*8
    if  [[ $bytes_sum_in =~ ^[0-9]+$ ]]
    then
	rm -f *.txt
        echo $now";"$id";1;"$bit_in";"$bit_out";"$r_sum";"$r_curr";"$r_max";0;0" >> EXP_PM_VLB_"$now1"".txt"; \
	cat *.txt
	let bytes_sum_in=0; let bytes_sum_out=0; let r_sum=0; let r_curr=0;let r_max=0
    fi
    #fi
done

