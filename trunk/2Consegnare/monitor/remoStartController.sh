#!/bin/bash

IP = $1

java -cp ../../../yami4/lib/yami4.jar:. Controller tcp://$IP:12347 tcp://$IP:12348
