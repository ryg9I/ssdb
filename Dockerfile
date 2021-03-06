FROM debian:latest

MAINTAINER Pavel E. Dedkov <pavel.dedkov@gmail.com>

# install 
RUN apt-get update && \
	apt-get install -y --force-yes git make gcc g++ autoconf libjemalloc-dev && \ 
	git clone --recursive https://github.com/ideawu/ssdb.git ssdb && \
	cd ssdb && make && make install && cp ssdb-server /usr/bin && cp ssdb.conf /etc && cd .. && rm -rf ssdb

# configure
RUN mkdir -p /var/lib/ssdb && \
  sed \
    -e 's@home.*@home /var/lib@' \
    -e 's/loglevel.*/loglevel info/' \
    -e 's@work_dir = .*@work_dir = /var/lib/ssdb@' \
    -e 's@pidfile = .*@pidfile = /run/ssdb.pid@' \
    -e 's@level:.*@level: info@' \
    -e 's@ip:.*@ip: 0.0.0.0@' \
    -i /etc/ssdb.conf

# clear
RUN apt-get remove --purge -y --force-yes git make gcc g++ autoconf libjemalloc-dev && \
apt-get autoremove -y && apt-get autoclean && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
ENV TZ Europe/Moscow
EXPOSE 8888
VOLUME /var/lib/ssdb
ENTRYPOINT /usr/bin/ssdb-server /etc/ssdb.conf
