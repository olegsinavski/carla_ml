FROM carlasim/carla:0.9.14
ARG VNC_PORT=8080
ARG JUPYTER_PORT=8894

USER root
RUN echo 'root:1234' | chpasswd

ENV DEBIAN_FRONTEND noninteractive
ENV APT_INSTALL "apt-get install -y --no-install-recommends"

RUN rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update

# ==================================================================
# tools
# ------------------------------------------------------------------
RUN $APT_INSTALL \
        build-essential \
        apt-utils \
        ca-certificates \
        wget \
        git \
        vim \
        libssl-dev \
        curl \
        unzip \
        unrar \
        zlib1g-dev \
        libjpeg8-dev \
        freeglut3-dev \
        iputils-ping

RUN $APT_INSTALL \
    cmake  \
    protobuf-compiler

# ==================================================================
# SSH
# ------------------------------------------------------------------
RUN apt-get update && $APT_INSTALL openssh-server
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# ==================================================================
# GUI
# ------------------------------------------------------------------
RUN $APT_INSTALL libsm6 libxext6 libxrender-dev mesa-utils

# Setup demo environment variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768

RUN apt-get update; \
    $APT_INSTALL \
      fluxbox \
      net-tools \
      novnc \
      supervisor \
      x11vnc \
      xterm \
      xvfb \
      python3-tk \
      libgtk2.0-dev

COPY docker_mlgl/dep/vnc /vnc
EXPOSE $VNC_PORT

## ==================================================================
## More tools for Carla
## ------------------------------------------------------------------
RUN apt-get update && $APT_INSTALL mesa-vulkan-drivers vulkan-utils xdg-user-dirs xdg-utils
# Make flyby window work with touchpad
RUN sed -i 's/bUseMouseForTouch=False/bUseMouseForTouch=True/' "/home/carla/CarlaUE4/Config/DefaultInput.ini"


# ==================================================================
# python
# ------------------------------------------------------------------
ENV PYTHON_VERSION 3.8
RUN $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    $APT_INSTALL \
        python$PYTHON_VERSION \
        python$PYTHON_VERSION-dev \
        python3-distutils-extra \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python$PYTHON_VERSION ~/get-pip.py pip setuptools wheel pip-tools && \
    ln -s /usr/bin/python$PYTHON_VERSION /usr/local/bin/python3 && \
    ln -s /usr/bin/python$PYTHON_VERSION /usr/local/bin/python

COPY requirements.txt.lock requirements.txt.lock
RUN python -m pip --no-cache-dir install --no-deps -r requirements.txt.lock

# ==================================================================
# jupyterlab
# ------------------------------------------------------------------
EXPOSE $JUPYTER_PORT
COPY docker_mlgl/scripts/jupyter_notebook_config.py /etc/jupyter/
RUN echo "c.NotebookApp.port = $JUPYTER_PORT" >> /etc/jupyter/jupyter_notebook_config.py

## ==================================================================
## Startup
## ------------------------------------------------------------------
COPY on_docker_start.sh /on_docker_start.sh
RUN chmod +x /on_docker_start.sh

# RUN echo 'su - carla -c "./CarlaUE4.sh -RenderOffScreen -nosound -opengl"' > /home/carla/mycarla.sh
# Unreal command line commands: https://docs.unrealengine.com/5.1/en-US/command-line-arguments-in-unreal-engine/
RUN echo "./CarlaUE4.sh -nosound -carla-server -benchmark -fps=10 -quality-level=Epic -RenderOffScreen" > /home/carla/no_screen.sh
RUN chmod +x /home/carla/no_screen.sh

RUN echo "./CarlaUE4.sh -nosound -carla-server -benchmark -fps=10 -quality-level=Epic" > /home/carla/mycarla.sh
RUN chmod +x /home/carla/mycarla.sh

# make bash a default shell for carla user
RUN usermod -s /bin/bash carla

#USER carla
#WORKDIR /home/carla


# check that drawing works
# RUN $APT_INSTALL tuxpaint


ENTRYPOINT ["/on_docker_start.sh"]