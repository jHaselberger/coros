#!/bin/sh

echo "starting xvfb"
Xvfb :99 -ac -screen 0 "$XVFB_WHD" -nolisten tcp &
Xvfb_pid="$!"

echo "start the x11 vnc server"
x11vnc -display :99 &

echo "checking openGl support"
glxinfo | grep '^direct rendering:'
