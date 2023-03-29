# Build docker image for running MCRIBS

# Legacy
FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

# update apt
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        ca-certificates \
        g++ \
        gcc \
        cmake \
        curl \
        file \
        git \
        python3-dev \
        libboost-dev \
        libeigen3-dev \
        libflann-dev \
        libgl1-mesa-dev \
        libglu1-mesa-dev \
        libssl-dev \
        libtbb-dev \
        libxt-dev \
        zlib1g-dev \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
# Build MCRIBS + dependencies through their build script
# Installed dependencies: ITK, VTK, MIRTK
RUN git clone https://github.com/AidanWUSTL/MCRIBS_for_MAKEGI.git /opt/MCRIBS \
    && cd MCRIBS \
    && bash build.sh \
    # clean up and reduce size
    && rm -rf ITK/ITK/ ITK/ITK-build/ VTK/VTK/ VTK/VTK-build/ MIRTK/MIRTK/ MIRTK/MIRTK-build/

COPY scripts/fixpy.sh env/setupMCRIBS.sh /opt/
RUN bash fixpy.sh /opt/MCRIBS/ > fixpy.log

WORKDIR /usr/lib/x86_64-linux-gnu
RUN mv libtbb.so.2 libtbbmalloc.so.2 libtbbmalloc_proxy.so.2 /opt/MCRIBS/lib

WORKDIR /work
ENTRYPOINT ["/opt/setupMCRIBS.sh"]
