#!/bin/bash
sudo docker build --compress -f Dockerfile.carla --force-rm --rm -t coros:carla .