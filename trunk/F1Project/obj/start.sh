rm LOGbroker.txt
rm LOGmain.txt
rm LOGmonitor.txt
cd ../src/monitor
xterm -l -lf LOGmonitor.txt -T "Monitor" -e 'sh start.sh' &
cd ../../obj
xterm -l -lf LOGbroker.txt -T "Broker" -e './broker tcp://localhost:12345' &
xterm -l -lf LOGmain.txt -T "Main" -e './main tcp://localhost:12345' &
