FROM debian:stretch

RUN apt-get update; apt-get install curl gnupg -y

RUN curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg |  apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" |  tee /etc/apt/sources.list.d/yarn.list
RUN curl --silent --show-error https://deb.nodesource.com/gpgkey/nodesource.gpg.key |  apt-key add -
RUN echo "deb https://deb.nodesource.com/node_8.x stretch main" |  tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update; apt-get install git cmake gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev \
libpcap-dev libhiredis-dev libhiredis0.13 uuid-dev libhiredis0.13 libgpgme-dev bison libksba-dev libsnmp-dev \
libgcrypt20-dev clang-format apt-transport-https nodejs yarn libmicrohttpd-dev libxml2-dev redis-server apt-utils wget curl rsync -y

# Required OpenVas Libs
RUN git clone https://github.com/greenbone/gvm-libs.git /gvm-libs
WORKDIR /gvm-libs
RUN mkdir build
WORKDIR /gvm-libs/build
RUN cmake ..
RUN make install ..

# OpenVas Scanner
RUN git clone https://github.com/greenbone/openvas-scanner.git /openvas-scanner
WORKDIR /openvas-scanner
RUN mkdir build
WORKDIR /openvas-scanner/build
RUN cmake ..
RUN make install ..

# OpenVas HTTPS/GUI Assistant
RUN git clone https://github.com/greenbone/gsa.git /gsa
WORKDIR /gsa
RUN mkdir build
WORKDIR /gsa/build
RUN cmake ..
RUN make install ..

EXPOSE 80
EXPOSE 443

# Sync latest threats (always last)
RUN greenbone-nvt-sync

# ENTRYPOINT [ "/usr/bin/redis-server" "/openvas-scanner/build/doc/redis_config_examples/redis_2_6.conf" "&" ]
# CMD [ "openvassd" ]
CMD [ "bash" ]
