#!/bin/bash -e

echo user:x:$(id -u):0:USER:/opt/jboss:/bin/bash >> /etc/passwd
echo group:x:$(id -G | awk '{print $2}'):user >> /etc/group

/opt/jboss/brms/jboss-eap-7.0/bin/standalone.sh -c standalone.xml -b 0.0.0.0 -bmanagement 0.0.0.0

exec "$@"
