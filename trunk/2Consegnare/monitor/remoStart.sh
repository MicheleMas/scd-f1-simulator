#!/bin/bash
IP = $1

java -cp ../../../yami4/lib/yami4.jar:. Monitor tcp://$IP:12346 tcp://$IP:12347 
