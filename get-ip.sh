#!/bin/bash
[ -d "temp" ] || mkdir -p temp
vagrant ssh --no-tty -c "ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'" control > temp/control-ip