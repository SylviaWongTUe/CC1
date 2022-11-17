#!/bin/bash

timestamp=$(date +%s)
echo -n $timestamp, 

cpu_bench=$(sysbench cpu --time=60 run | awk '/second:/{print $4}')
echo -n $cpu_bench, 

memory_bench=$(sysbench memory --time=60 --memory-block-size=4K --memory-total-size=100TB run | awk '/MiB/{print substr($4,2);}')
echo -n $memory_bench, 

sysbench fileio --file-test-mode=rndrd --file-total-size=1G --file-extra-flags=direct --file-num=1 prepare > /dev/null
rndrd_bench=$(sysbench fileio --time=60 --file-test-mode=rndrd --file-total-size=1G run --file-extra-flags=direct --file-num=1 | awk '/read, MiB\/s:/{print $3}')
echo -n $rndrd_bench,  
sysbench fileio --file-test-mode=rndrd --file-total-size=1G --file-extra-flags=direct cleanup > /dev/null

sysbench fileio --file-test-mode=seqrd --file-total-size=1G --file-extra-flags=direct --file-num=1 prepare > /dev/null
seqrd_bench=$(sysbench fileio --time=60 --file-test-mode=seqrd --file-total-size=1G run --file-extra-flags=direct --file-num=1 | awk '/read, MiB\/s:/{print $3}')
echo $seqrd_bench  
sysbench fileio --file-test-mode=seqrd --file-total-size=1G --file-extra-flags=direct cleanup > /dev/null

