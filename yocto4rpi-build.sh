#!/bin/bash

export BRANCH=kirkstone

docker build -t yocto_rpi - <<EOF
FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y gawk wget git diffstat unzip texinfo \
    gcc build-essential chrpath socat \
    cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm python3-subunit mesa-common-dev lz4

RUN apt install -y locales zstd && locale-gen en_US.UTF-8
# Set the LC_ALL environment variable
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

RUN adduser --disabled-password --gecos '' $USER
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $USER

WORKDIR /work

EOF

docker run -it --rm -v $PWD:/work -v /dev/net:/dev/net --net=host --privileged \
  -e BRANCH=kirkstone yocto_rpi /bin/bash -c "\
  source poky/oe-init-build-env build-rpi && \
  bitbake core-image-full-cmdline"
