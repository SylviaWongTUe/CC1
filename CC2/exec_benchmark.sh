#!/bin/bash

touch native-results.csv 
touch docker-results.csv 
touch kvm-results.csv 
touch qemu-results.csv 

echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> native-results.csv
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> docker-results.csv 
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> kvm-results.csv 
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> qemu-results.csv


#native
for i in {1..10}
do
    bash benchmark.sh >> native-results.csv
done

#docker
for i in {1..10}
do
    docker run test >> docker-results.csv
done

#kvm
scp benchmark.sh  pdcnguyen@192.168.122.19:~

for i in {1..10}
do
    ssh pdcnguyen@192.168.122.19 'bash benchmark.sh' >> kvm-results.csv
done

#qemu
scp -P 5555 benchmark.sh pdcnguyen@localhost:~

for i in {1..10}
do
    ssh -p 5555 pdcnguyen@localhost 'bash benchmark.sh' >> qemu-results.csv
done

echo "All done"
