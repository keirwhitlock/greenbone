#!/bin/bash

echo "Re-syncing nvt vulnerabilities"
greenbone-nvt-sync
/usr/local/sbin/greenbone-scapdata-sync

echo "Start the redis server"
/usr/bin/redis-server /openvas-scanner/build/doc/redis_config_examples/redis_3_2.conf & 

echo "Start Openvas Scanner Daemon"
openvassd

echo "Start the HTTP/S GUI interface"
gsad -v --ssl-private-key=/gsa/gsad/server.key --ssl-certificate=/gsa/gsad/server.crt

echo "Start the management deamon in foreground mode"
gvmd -f
