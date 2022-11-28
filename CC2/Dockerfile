FROM ubuntu:18.04

COPY benchmark.sh /
RUN chmod +x /benchmark.sh

RUN apt-get update
RUN apt install iperf3 -y
RUN apt install sysbench -y

ENTRYPOINT ["/benchmark.sh"]