rm LOGbroker.txt
rm LOGmain.txt
rm LOGmonitor.txt
cd ../src/monitor
xterm -l -lf ../../obj/LOGmonitor.txt -T "Monitor" -e 'sh start.sh' &
xterm -l -T "Controller" -e 'sh startController.sh' &
cd ../../obj
xterm -l -lf LOGbroker.txt -T "Broker" -e './broker tcp://localhost:12345' &
xterm -l -lf LOGmain.txt -T "Main" -e './main tcp://localhost:12345' &
