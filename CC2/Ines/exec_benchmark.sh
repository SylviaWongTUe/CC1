#!/bin/bash

# create 4 csv files with correct header
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> native-results.csv
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> docker-results.csv
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> kvm-results.csv
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" >> qemu-results.csv

# native benchmark
for i in {1..10}
do
   ./benchmark.sh localhost >> native-results.csv
done

# docker
docker build . -t dockerbench &>/dev/null
for i in {1..10}
do
   docker run dockerbench >> $PWD/docker-results.csv
done

# KVM
# copy benchmark file to kvm
scp $PWD/benchmark.sh ubuntu@192.168.122.241: &>/dev/null
scp $PWD/forkbench.c ubuntu@192.168.122.241: &>/dev/null
for i in {1..10}
do
   ssh ubuntu@192.168.122.241 "./benchmark.sh 192.168.122.1" >> $PWD/kvm-results.csv
done

# QEMU
# copy benchmark file to qemu
scp $PWD/benchmark.sh ubuntu@192.168.122.118: &>/dev/null
# copy forkbench
scp $PWD/forkbench.c ubuntu@192.168.122.118: &>/dev/null
for i in {1..10}
do
   ssh ubuntu@192.168.122.118 "./benchmark.sh 192.168.122.1" >> $PWD/qemu-results.csv
done
