#!/bin/bash

sudo /opt/sysmon/sysmon -u > /dev/null
sudo service auditd stop
sudo service auoms stop
killall execPerSec
sudo auditctl -D > /dev/null

sudo cp audit.rules /etc/audit/
sudo cp audit.rules /etc/audit/rules.d/
sudo cp auditdlaurel.conf /etc/audit/auditd.conf
sudo sh -c 'rm /etc/audisp/plugins.d/*'
sudo cp laurel.conf /etc/audisp/plugins.d/
sudo service auditd start

laurelpid=`ps -ef | grep laurel | grep -v grep | awk '{print $2}'`
journaldpid=`ps -ef | grep systemd-journald | grep -v grep | awk '{print $2}'`
auditdpid=`ps -ef | grep auditd | grep -v kauditd | grep -v grep | awk '{print $2}'`
audispdpid=`ps -ef | grep audispd | grep -v grep | awk '{print $2}'`
kauditdpid=`ps -ef | grep kauditd | grep -v grep | awk '{print $2}'`

for i in 100 200 400 800 1600; do
	execPerSec/execPerSec $i 50 &
	sleep 10
	RES=`pidstat -h -u -p $laurelpid -p $journaldpid -p $auditdpid -p $audispdpid -p $kauditdpid 30 1 | tail -n5 | awk '{print $8}'`
	CPU=`echo $RES | awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c}'`
	echo "laurel,$i,$CPU"
	killall execPerSec
done

sudo service auditd stop
sudo auditctl -D > /dev/null
