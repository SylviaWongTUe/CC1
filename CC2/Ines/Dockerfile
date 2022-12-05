FROM ubuntu:18.04

COPY benchmark.sh /
COPY forkbench.c /
RUN chmod +x /benchmark.sh

RUN apt-get update
RUN apt install iperf3 -y
RUN apt install sysbench -y
RUN apt install bc -y
RUN apt install make -y
RUN apt install build-essential -y

ENTRYPOINT ["/benchmark.sh", "172.17.0.1"]