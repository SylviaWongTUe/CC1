#!/bin/bash

end=$((SECONDS+60))

forkResTotal=0
numIterations=0

while [ $SECONDS -lt $end ]; do
    currentForkRes=$(./forkbench 1 5000 2> /dev/null)
    forkResTotal=$(echo "$forkResTotal + $currentForkRes" | bc)
    numIterations=$(($numIterations + 1))
done

#calculate average
forkBench=$(echo "$forkResTotal/$numIterations" | bc -l)

echo $forkBench