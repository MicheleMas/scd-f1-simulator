#!/bin/bash

gnatmake -Pf1 -XOS=POSIX
cd src/monitor
ant
