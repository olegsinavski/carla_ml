FROM mlgl_sandbox

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1AF1527DE64CB8D9  && \
    add-apt-repository "deb [arch=amd64] http://dist.carla.org/carla $(lsb_release -sc) main" && \
    apt-get update && \
    APT_INSTALL="apt-get install -y --no-install-recommends" && \
    $APT_INSTALL carla-simulator=0.9.13
