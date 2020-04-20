# OPENGL SUPPORT ------------------------------------------------------------------------------
# start with plain ros as base image for testing
FROM ros:melodic AS builder

RUN /bin/bash -c "source /opt/ros/melodic/setup.bash"

# install some needed packages and set gcc-8 as default compiler
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    llvm-7 \
    llvm-dev \
    autoconf \
    automake \
    bison \
    flex \
    gettext \
    libtool \
    python-dev\
    git \
    pkgconf \
    python-mako \
    zlib1g-dev \
    x11proto-gl-dev \
    libxext-dev \
    xcb \
    libx11-xcb-dev \
    libxcb-dri2-0-dev \
    libxcb-xfixes0-dev \
    libdrm-dev \
    g++ \
    make \
    xvfb \
    x11vnc \
    g++-8 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8 && \
    rm -rf /var/lib/apt/lists/*
    
# get mesa (using 19.0.2 as later versions dont use the configure script)
WORKDIR /mesa
RUN git clone https://gitlab.freedesktop.org/mesa/mesa.git
WORKDIR /mesa/mesa
RUN git checkout mesa-19.0.2
#RUN git checkout mesa-18.2.2

# build and install mesa
RUN libtoolize && \
    autoreconf --install && \
    ./configure \
        --enable-glx=gallium-xlib \
        --with-gallium-drivers=swrast,swr \
        --disable-dri \
        --disable-gbm \
        --disable-egl \
        --enable-gallium-osmesa \
        --enable-autotools \
        --enable-llvm \
        --with-llvm-prefix=/usr/lib/llvm-7/ \
        --enable-gles1 \
        --enable-gles2 \
        --prefix=/usr/local && \
    make -j 4 && \
    make install && \
    rm -rf /mesa



# UBUNTU WITH MESA GL -----------------------------------------------------------------------
FROM ros:melodic
COPY --from=builder /usr/local /usr/local

RUN /bin/bash -c "source /opt/ros/melodic/setup.bash"

# update ubuntu and install all dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xterm \
        #freeglut3 \
        openssh-server \
        synaptic \
        nfs-common \
        mesa-utils \
        xfonts-75dpi \
        libusb-0.1-4 \
        python \
        libglu1-mesa \
        libqtgui4 \
        gedit \
        xvfb \
        x11vnc \
        llvm-7-dev \
        expat \
        nano \
        dos2unix \
        ros-melodic-image-transport \
        ros-melodic-cv-bridge \
        python-pip \
        libxkbfile-dev \
        libsecret-1-dev \
        dos2unix \
        wget \
        ros-melodic-rqt \
        ros-melodic-rqt* \
        jwm \
        ros-melodic-rviz \
        ros-melodic-desktop-full &&\
        rm -rf /var/lib/apt/lists/*

# copy some needed libs
COPY ./libs libs/

# insatll libpng12
RUN dpkg -i /libs/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb

# install all needed python packages
RUN pip install \
        jupyterlab \
        matplotlib \
        tqdm \
        pymongo \
        h5py

# get vs code server
RUN mkdir /code-server &&\ 
    wget -qO- https://github.com/cdr/code-server/releases/download/2.1523-vsc1.38.1/code-server2.1523-vsc1.38.1-linux-x86_64.tar.gz \
    | tar xvz --strip-components=1 -C /code-server


# get and setup novnc
WORKDIR /novnc
RUN git clone https://github.com/novnc/noVNC.git

# fix for offline mode -> prefatch websockify
RUN cd ./noVNC/utils && git clone https://github.com/novnc/websockify

# set the environment variables (display -> 99 and LIBGL_ALWAYS_SOFTWARE)
ENV DISPLAY=":99" \
    GALLIUM_DRIVER="llvmpipe" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    LP_DEBUG="" \
    LP_NO_RAST="false" \
    LP_NUM_THREADS="" \
    LP_PERF="" \
    MESA_VERSION="19.0.2" \
    XVFB_WHD="1920x1080x24" \
    MESA_GLSL="errors" \
    PASSWORD="dev@ros"

# setup the entrypoint script (starts the xvfb and vnc session)
COPY ./entrypoint_code.sh /entry/
RUN dos2unix /entry/entrypoint_code.sh && chmod +x /entry/entrypoint_code.sh
ENTRYPOINT ["/entry/entrypoint_code.sh"]

# set the default shell
SHELL ["/bin/bash", "-c"]

# source ros for every new terminal session
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

# set our workdir
WORKDIR /workspace

# expose the vnc, novnc and code-server ports
#EXPOSE 5900
EXPOSE 6080
EXPOSE 8080
