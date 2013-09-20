#!/bin/bash
IP="$1"
rm LOGbroker.txt
rm LOGmain.txt
rm LOGmonitor.txt
cd ../src/monitor
xterm -l -lf ../../obj/LOGmonitor.txt -T "Monitor" -e "java -cp ../../../yami4/lib/yami4.jar:. Monitor tcp://$IP:12346 tcp://$IP:12347" &
xterm -l -T "Controller" -e "java -cp ../../../yami4/lib/yami4.jar:. Controller tcp://$IP:12347 tcp://$IP:12348" &
cd ../../obj
xterm -l -lf LOGbroker.txt -T "Broker" -e "./broker tcp://$IP:12345 tcp://$IP:12346 tcp://$IP:12347" &
xterm -l -lf LOGmain.txt -T "Main" -e "./main tcp://$IP:12345 tcp://$IP:12348" &
