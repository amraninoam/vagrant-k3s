#!/bin/bash
[ -d "temp" ] || mkdir -p temp
vagrant ssh --no-tty -c "sudo cat /var/lib/rancher/k3s/server/node-token" control > temp/node-token
