#!/bin/bash
IP = $1

rm LOGbroker.txt
rm LOGmain.txt
rm LOGmonitor.txt
cd ../src/monitor
xterm -l -lf ../../obj/LOGmonitor.txt -T "Monitor" -e "sh remoStart.sh '$IP' &"
xterm -l -T "Controller" -e "sh remoStartController.sh $IP" &
cd ../../obj
xterm -l -lf LOGbroker.txt -T "Broker" -e "./broker tcp://$IP:12345 tcp://$IP:12346 tcp://$IP:12347" &
xterm -l -lf LOGmain.txt -T "Main" -e "./main tcp://$IP:12345 tcp://$IP:12348" &
