<img src="https://raw.githubusercontent.com/gismo07/coros/master/assets/coros.png" />



![ROS distro](https://img.shields.io/badge/ROS-melodic-lightgrey?style=flat-square) ![Python version](https://img.shields.io/badge/Python-v2.7-lightgrey?style=flat-square) ![Docker Automated build](https://img.shields.io/docker/automated/johannhaselberger/coros?style=flat-square) ![Docker Build Status](https://img.shields.io/docker/cloud/build/johannhaselberger/coros?style=flat-square) ![Docker Pulls](https://img.shields.io/docker/pulls/johannhaselberger/coros?style=flat-square) ![MicroBadger Size](https://img.shields.io/microbadger/image-size/johannhaselberger/coros?style=flat-square)

Jumpstart ROS developent with no headache! Full browser support. OpenGL support with no need of a physically atachted GPU.

>>Attention: the project is still under development. There may be gaps in the manual. Don't forget to mount the appropriate volumes to prevent data loss!

## 📦 Included

### ROS
 - full ros distro (**currently melodic**)
 - rqt and all plugins
 - rviz

### IDE (accessible  through the browser)
 - full python (2.7) environment
 - visual studio code server

## 🏃 Start the service
There are two provided start and stop scripts - one for windows, the other one for unix systems.
First pull the github project to get these scripts with `git clone https://github.com/gismo07/coros.git`.

### windows
 1. `cd utils-windows`
 2. `.\start-windows.cmd`

### unix
 1. `cd utils`
 2. `.\start.sh`


 ## 💻 Access the environment
  - to open the IDE, simply open the browser and go to [localhost:80]()
  - The password is currently set to `dev@ros`
  - to see rviz or some other gui stuff, open another browser tab [localhost:6080/vnc.html]() and click connect

## 💾 Data storage
Per default all perisistent data is located at the host pc (assuming windows for now) under `C:/ros-persistent-data`. Create this folder **before** starting the container.

### How to bind to a local folder
If you want to bind a existing folder of the host to the docker container, the `docker-compose.yaml` file is used for that. For each folder, a new `volume` section has to be added:

```yaml
        volumes:
            - type: bind
              source: /<PATH_TO_FOLDER_ON_HOST>
              target: /<TARGET_DESTINATION_ON_THE_CONTAINER>
              volume:
                nocopy: true  # just keep that
```

## 🔧 Configuration
The environment comes shipped with a `docker-compose.yaml` to start the service and manage some parameters:

```yaml
version: '3.7'
services:
    headless-ros-vnc:
        ports:
            - '80:8080'
            #- '5900:5900'
            - '6080:6080'
        volumes:
            - type: bind
              source: C:/ros-persistent-data
              target: /my_ros_data
              volume:
                nocopy: true
        image: johannhaselberger/coros
```

coros makes use of three open ports:
 - `8080`: access to visual studio code server
 - `5900`: the default vnc port (could be theoretically accessed with any vnc client, however, as the port is forwarded via noVNC that's not intended)
 - `6080`: access to the novnc web interface

 **Important:** for each instance of coros these ports have to be assigned to available host-ports!


## 😱 Known issues

### VNC not working
If the noVNC server is not accessable through the web interface, the virtual network has to be reseted:
```
docker-compose stop
docker container prune -f
docker network prune -f
```
After that you can start the service again.

### Mounting errors on windows
 1. start docker with admin rights
 2. right click on the docker system tray icon -> Settings
 3. Under `Shared Drives` set the checkbox for the C drive
