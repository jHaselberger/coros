#!/bin/bash

echo "starting xvfb"
Xvfb :99 -ac -screen 0 "$XVFB_WHD" -nolisten tcp &
Xvfb_pid="$!"

echo "start the x11 vnc server"
x11vnc -display :99 --loop -noxrecord &

echo "checking openGl support"
glxinfo | grep '^direct rendering:'

echo "starting window manager jwm"
jwm &
#openbox &

echo "starting noVNC"
/novnc/noVNC/utils/launch.sh --vnc localhost:5900 &

source /opt/ros/melodic/setup.bash
/code-server/code-server --user-data-dir /workspace --password $PASSWORD --auth password
