FROM ubuntu:18.04
RUN apt-get update && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl nginx git htop man unzip vim wget autotools-dev automake libevent-dev autoconf automake libpcre3-dev libevent-dev pkg-config zlib1g-dev libssl-dev
WORKDIR /usr/src/memcached
COPY memcached /memcached
RUN cd /memcached && \
    ./autogen.sh && \
    ./configure && \
    make -j && \
    make DESTDIR=/memcached install

WORKDIR /usr/src/redis
COPY redis /redis
RUN cd /redis && \
    make -j && \
    make PREFIX=/redis/usr install


WORKDIR /usr/src/memtier
COPY memtier_benchmark /memtier_benchmark
RUN cd /memtier_benchmark && \
    autoreconf -ivf && \
    ./configure && \
     make -j && \
     make DESTDIR=/memtier install

RUN useradd benchmark

COPY run-benchmark.sh /usr/local/bin/run-benchmark.sh
COPY run-server.sh /usr/local/bin/run-server.sh


RUN \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443