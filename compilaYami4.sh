cd yami4
cd src
cd core
make
cd ..
cd cpp
make
cd ..
cd ada
# Edit std_cpp.gpr: "x86_64-linux-gnu/4.6" --> "i686-linux-gnu/4.6"
gnatmake -Pyami
cd ..
cd java
ant
cd ..
cd ada-ravenscar
# Edit std_cpp.gpr: "x86_64" --> "i686"
gnatmake -Pyami
cd ..
cd services/names
gnatmake -Pnames
cd ..
cd broker
gnatmake -Pbroker
cd ..
cd queue
gnatmake -Pqueue
cd ..
cd cache
gnatmake -Pcache
cd ..
cd ..
cd tools/yami4idl/src
gnatmake yami4idl
