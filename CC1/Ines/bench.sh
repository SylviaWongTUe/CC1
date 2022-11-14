#!/bin/bash


# store epoch time of beginning of tests
start_time=$(date +%s)

#### CPU
cpu_out=$(sysbench cpu --time=60 run | awk '/events per second: / {print $4}')


### memory
memory_out=$(sysbench memory --time=60 --memory-block-size=4K --memory-total-size=100TB run | awk '/transferred / {print $4}')


### random
# prepare file and prevent from printing anything to console
sysbench fileio --file-num=1 --file-total-size=1GB --file-test-mode=rndrd --file-extra-flags=direct prepare &>/dev/null

# run test
random_out=$(sysbench fileio --time=60 --file-num=1 --file-total-size=1GB --file-test-mode=rndrd --file-extra-flags=direct run | awk '/read, MiB/ {print $3}')

# cleanup
sysbench fileio --file-total-size=1G cleanup &>/dev/null


### sequential
# prepare file and prevent from printing anything to console
sysbench fileio --file-num=1 --file-total-size=1GB --file-test-mode=seqrd --file-extra-flags=direct prepare &>/dev/null

# run test
sequential_out=$(sysbench fileio --time=60 --file-num=1 --file-total-size=1GB --file-test-mode=seqrd --file-extra-flags=direct run | awk '/read, MiB/ {print $3}')

#cleanup
sysbench fileio --file-total-size=1G cleanup &>/dev/null


# output results
echo "$start_time,$cpu_out,${memory_out:1},$random_out,$sequential_out"