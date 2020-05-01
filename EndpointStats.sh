#!/bin/bash
#This script collects some various information about the OS and the Endpoint Service
#It will output it all ot a file in /tmp called endpointstats
#A potentential cron to have this run hourly and tar at night could be:
#0 * * * * /root/EndpointStats.sh
#0 0 * * * tar -czf /tmp/EndpointStats-`date +%m%d%Y`.tar.gz /tmp/endpointstats -v

DESTINATION_FOLDER="/tmp/endpointstats"

mkdir -p $DESTINATION_FOLDER

#Netstat and process information
echo `date` >> $DESTINATION_FOLDER/netstat.out
netstat -anp >> $DESTINATION_FOLDER/netstat.out
echo `date` >> $DESTINATION_FOLDER/ss-n.out
/usr/sbin/ss -n >> $DESTINATION_FOLDER/ss-n.out
echo `date` >> $DESTINATION_FOLDER/ps-aux.out
ps aux >> $DESTINATION_FOLDER/ps-aux.out

#Collect service status
echo `date` >> $DESTINATION_FOLDER/systemctl-status-endpoint-server-l.out
/usr/bin/systemctl status rsa-nw-endpoint-server -l >> $DESTINATION_FOLDER/systemctl-status-endpoint-server-l.out
echo `date` >> $DESTINATION_FOLDER/systemctl-status-nginx-l.out
/usr/bin/systemctl status nginx >> $DESTINATION_FOLDER/systemctl-status-nginx-l.out
echo `date` >> $DESTINATION_FOLDER/systemctl-status.out
/usr/bin/systemctl status >> $DESTINATION_FOLDER/systemctl-status.out

#lsof output
echo `date` >> $DESTINATION_FOLDER/lsof-u-netwitness.out
/usr/sbin/lsof -u netwitness >> $DESTINATION_FOLDER/lsof-u-netwitness.out

#User File limits
ulimit -a > $DESTINATION_FOLDER/ulimit-a.out
cat /etc/security/limits.conf > $DESTINATION_FOLDER/security-limits.conf

#This will create a list that will allow us to iterate and look in the /proc folder for each item. Endpoint Server is being ran by the netwitness user
for pid in `pgrep -u netwitness`;
    do
    #echo "checking /proc folder of $pid"
    mkdir -p $DESTINATION_FOLDER/$pid
    cat /proc/$pid/limits > $DESTINATION_FOLDER/$pid/limits.out
    echo `date` >> $DESTINATION_FOLDER/$pid/fdinfo-ls-alh.out
    ls -alh /proc/$pid/fd* >> $DESTINATION_FOLDER/$pid/fdinfo-ls-alh.out
done;

for pid in `pgrep -u nginx`;
    do
    #echo "checking /proc folder of $pid"
    mkdir -p $DESTINATION_FOLDER/$pid
    cat /proc/$pid/limits > $DESTINATION_FOLDER/$pid/limits.out
    echo `date` >> $DESTINATION_FOLDER/$pid/fdinfo-ls-alh.out
    ls -alh /proc/$pid/fd* >> $DESTINATION_FOLDER/$pid/fdinfo-ls-alh.out
done;

#A potentential cron to have this run hourly and tar at night could be:
#0 * * * * /root/EndpointStats.sh
