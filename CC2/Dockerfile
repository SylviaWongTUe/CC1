FROM ubuntu:18.04

COPY benchmark.sh /
COPY forkbench.c /

RUN chmod +x /benchmark.sh
RUN chmod +x /forkbench.c


RUN apt-get update
RUN apt install bc -y
RUN apt install build-essential -y
RUN apt install iperf3 -y
RUN apt install sysbench -y

RUN make forkbench

ENTRYPOINT ["/benchmark.sh"]