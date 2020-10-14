<img src="https://raw.githubusercontent.com/gismo07/coros/master/assets/coros.png" />



![ROS distro](https://img.shields.io/badge/ROS-melodic-lightgrey?style=flat-square) ![Python version](https://img.shields.io/badge/Python-v2.7-lightgrey?style=flat-square) ![Docker Automated build](https://img.shields.io/docker/automated/johannhaselberger/coros?style=flat-square) ![Docker Build Status](https://img.shields.io/docker/cloud/build/johannhaselberger/coros?style=flat-square) ![Docker Pulls](https://img.shields.io/docker/pulls/johannhaselberger/coros?style=flat-square) ![MicroBadger Size](https://img.shields.io/microbadger/image-size/johannhaselberger/coros?style=flat-square)

Jumpstart ROS developent with no headache! Full browser support. OpenGL support with no need of a physically atachted GPU.

## 📦 Included

### ROS
 - full ros distro (**currently melodic**)
 - rqt and all plugins
 - rviz

### IDE (accessible  through the browser)
 - full python (2.7) environment
 - visual studio code server

 ___

## 🏃 Start the service
There are two provided start and stop scripts - one for windows, the other one for unix systems.
First pull the github project to get these scripts with `git clone https://github.com/gismo07/coros.git`.

### windows
 1. `cd utils-windows`
 2. `.\start-windows.cmd`

### unix
 1. `cd utils`
 2. `sudo chmod +x ./start.sh`
 2. `./start.sh`

___

 ## 💻 Access the environment
  - to open the IDE, simply open the browser and go to [localhost:80]()
  - The password is currently set to `dev@ros`
  - to see rviz or some other gui stuff, open another browser tab [localhost:6080/vnc.html]() and click connect

___

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
___
## 🚘 Carla integration
Since version `1.1` COROS comes with a preinstalled version of the [Carla PythonAPI](https://carla.readthedocs.io/en/latest/python_api/) and [ROS bridge](https://github.com/carla-simulator/ros-bridge). Currently we use Carla version `0.9.10.1`.

> The Carla simulation itself is not part of COROS to maintain platform independence

### Start Carla
To use the Carla-Ros bridge, make sure that Carla is running and accessible over the network.

#### Linux users with NVIDIA GPU
1. Get the right carla docker image:
    ```bash
    sudo docker pull carlasim/carla:0.9.10.1
    ```
2. start carla while forwarding the x context:
    ```bash
    sudo docker run \
      -e SDL_VIDEODRIVER=x11 \
      -e DISPLAY=:99 \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -p 2000-2002:2000-2002 \
      -it \
      --gpus all \
      carlasim/carla:0.9.10.1 ./CarlaUE4.sh -opengl
    ```

3. alternatively, carla can also be started without graphical output:
    ```bash
    sudo docker run \
      -e SDL_VIDEODRIVER=offscreen \
      -e DISPLAY=:99 \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -p 2000-2002:2000-2002 \
      -it \
      --gpus all \
      carlasim/carla:0.9.10.1 ./CarlaUE4.sh -opengl
    ```

#### Windows users
1. Download the `0.9.10.1` version from the offical [carla releases](https://github.com/carla-simulator/carla/releases/tag/0.9.10.1).

2. Start the carla exe located under `CARLA_0.9.10.1\WindowsNoEditor\CarlaUE4.exe`:
     ```bash
     ./CarlaUE4.exe -Carla-server -windowed
     ```

### Start the ROS bridge
Within COROS everything is allready setup to communicate with carla.

Open a new terminal and start the ros bridge example:
```bash
roslaunch carla_ros_bridge carla_ros_bridge_with_example_ego_vehicle.launch
```
___

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

____
## 😱 Known issues

### Mounting errors on windows
 1. start docker with admin rights
 2. right click on the docker system tray icon -> Settings
 3. Under `Shared Drives` set the checkbox for the C drive
 
### Access denied errors
Try to start the service with sudo rights. On windows open our shell with admin rights.

### Operating system linux cannot be used on this platform error
This is mainly a windows error. Right klick on the docker tray icon and select switch to linux containers.

### I can see some remote topics, however no data can be received
That's a very common ROS network issue:
 1. make sure you can ping the remote machine
 2. add all remote host names and your own host name to `\etc\hosts` on all machines
 3. restart the ROS master

### Timeout from Carla ROS bridge
Depending on your specific setup, make sure you enter the correct IPs within the Carla launch files. These can be found at: `/carla_rb_ws/src/carla_ros_bridge/launch/`. Also there is a configuration file at `/carla_rb_ws/src/carla_ros_bridge/config/settings.yaml`.
