rm LOGbroker.txt
rm LOGmain.txt
xterm -l -lf LOGbroker.txt -T "Broker" -e './broker tcp://localhost:12345' &
xterm -l -lf LOGmain.txt -T "Main" -e './main tcp://localhost:12345' &
