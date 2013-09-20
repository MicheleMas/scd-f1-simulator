#!/bin/bash
IP="$1"
rm F1Project/obj/LOGmonitor.txt
cd F1Project/src/monitor
xterm -l -lf ../../obj/LOGmonitor.txt -T "Monitor" -e "java -cp ../../../yami4/lib/yami4.jar:. Monitor tcp://$IP:12346 tcp://$IP:12347" &
xterm -l -T "Controller" -e "java -cp ../../../yami4/lib/yami4.jar:. Controller tcp://$IP:12347 tcp://$IP:12348" &
