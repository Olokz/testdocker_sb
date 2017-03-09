#!/bin/bash

rm -rf /tmp/.X*
rm -f /tmp/TS3*

cd /opt/ts3soundboard
/usr/bin/xinit /opt/ts3soundboard/ts3bot -- /usr/bin/Xvfb :1 -screen 0 800x600x16 -ac
