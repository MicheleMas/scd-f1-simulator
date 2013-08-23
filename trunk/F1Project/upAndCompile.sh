#!/bin/bash

svn up
gnatmake -Pf1 -XOS=POSIX
cd src/monitor
ant
