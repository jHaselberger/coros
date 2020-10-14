#!/bin/bash
sudo docker run \
    -e SDL_VIDEODRIVER=x11\
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -p 2000-2002:2000-2002 -it --gpus all carlasim/carla ./CarlaUE4.sh /Game/Maps/Town02 -opengl -quality-level=Epic -windowed -ResX=500 -ResY=500 -benchmark -fps=30