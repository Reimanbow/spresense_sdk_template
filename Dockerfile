FROM ubuntu:22.04

RUN apt update && apt install -y \
    git \
    python3 \
    make \
    gcc-arm-none-eabi \
    flex \
    bison \
    gperf \
    libncurses-dev \
    pkg-config \
    autoconf \
    automake \
    curl \
    unzip \
    genromfs \
    kconfig-frontends

ENV CROSSDEV=arm-none-eabi-

WORKDIR /work