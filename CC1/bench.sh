
touch bench.csv

echo -n $'time,cpu,mem,diskRand,diskSeq\n' > bench.csv

i=0

until [ $i -gt 95 ]
do

    
    timestamp=$(date +%s)
    echo -n $timestamp, >> bench.csv

    cpu_bench=$(sysbench --test=cpu --time=60 run | awk '/second:/{print $4}')
    echo -n $cpu_bench, >> bench.csv

    memory_bench=$(sysbench --test=memory --time=60 --memory-block-size=4K --memory-total-size=100TB run | awk '/MiB/{print substr($4,2);}')
    echo -n $memory_bench, >> bench.csv

    sysbench --test=fileio --file-test-mode=rndrd --file-total-size=1G --file-fsync-freq=1 prepare 
    rndrd_bench=$(sysbench --test=fileio --time=60 --file-test-mode=rndrd --file-total-size=1G run --file-fsync-freq=1 | awk '/read, MiB\/s:/{print $3}')
    echo -n $rndrd_bench, >> bench.csv 
    sysbench --test=fileio --file-test-mode=rndrd --file-total-size=1G --file-fsync-freq=1 cleanup

    sysbench --test=fileio --file-test-mode=seqrd --file-total-size=1G --file-fsync-freq=1 prepare 
    seqrd_bench=$(sysbench --test=fileio --time=60 --file-test-mode=seqrd --file-total-size=1G run --file-fsync-freq=1 | awk '/read, MiB\/s:/{print $3}')
    echo $seqrd_bench >> bench.csv 
    sysbench --test=fileio --file-test-mode=seqrd --file-total-size=1G --file-fsync-freq=1 cleanup

    sleep 1800
    ((i=i+1))
done



