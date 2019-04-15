FROM debian:stretch

ENV LD_LIBRARY_PATH /usr/local/lib/

# Install required sources and packages
RUN apt-get update; apt-get install curl gnupg apt-transport-https -y
RUN curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg |  apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" |  tee /etc/apt/sources.list.d/yarn.list
RUN curl --silent --show-error https://deb.nodesource.com/gpgkey/nodesource.gpg.key |  apt-key add -
RUN echo "deb https://deb.nodesource.com/node_8.x stretch main" |  tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get clean; apt-get update; apt-get install git cmake gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev \
libpcap-dev libhiredis-dev libhiredis0.13 uuid-dev libhiredis0.13 libgpgme-dev bison libksba-dev libsnmp-dev \
libgcrypt20-dev clang-format nodejs yarn libmicrohttpd-dev libxml2-dev redis-server apt-utils wget curl rsync \
texlive-fonts-recommended htop libsqlite3-dev libical-dev python3-pip xsltproc nmap -y
RUN apt-get install texlive-latex-extra --no-install-recommends -y

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
RUN yarn add caniuse-lite browserslist
RUN git clone https://github.com/greenbone/gsa.git /gsa
WORKDIR /gsa
RUN mkdir build
WORKDIR /gsa/build
RUN cmake ..
RUN make install ..
RUN openssl req -x509 \
            -nodes \
            -days 3650 \
            -newkey rsa:4096 \
            -subj '/CN=OpenVAS/O=OpenVAS./C=GB' \
            -keyout /gsa/gsad/server.key \
            -out /gsa/gsad/server.crt

# OpenVas Greenbone Vulnerability Manager
RUN git clone https://github.com/greenbone/gvmd.git /gvmd
WORKDIR /gvmd
RUN mkdir build
WORKDIR /gvmd/build
RUN cmake ..
RUN make install ..

# Create Default User
RUN gvmd --create-user=administrator --password=greenbone

# GVM-Tools
RUN git clone https://github.com/greenbone/gvm-tools.git /gvm-tools
WORKDIR /gvm-tools
RUN pip3 install .

# Sync latest threats
RUN greenbone-nvt-sync
RUN /usr/local/sbin/greenbone-scapdata-sync

EXPOSE 80
EXPOSE 443

COPY startup.sh /startup.sh

CMD ["bash", "/startup.sh"]
