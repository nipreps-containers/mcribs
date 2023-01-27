FROM ubuntu:jammy

RUN apt-get update && apt-get install -y --no-install-recommends \
                                        build-essential \
                                        ca-certificates \
                                        cmake \
                                        gcc \
                                        git \
                                        make \
                                        python3 \
                                        wget \
                                        # vtk
                                        freeglut3-dev \
                                        # mirtk
                                        libarpack2-dev \
                                        libcgal-dev \
                                        libeigen3-dev \
                                        libpng-dev \
                                        libsuitesparse-dev \
                                        libtbb-dev && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# ITK
WORKDIR /tmp
RUN git clone --depth 1 --branch v5.3.0 https://github.com/InsightSoftwareConsortium/ITK.git && \
    mkdir /tmp/itk-build && cd /tmp/itk-build && \
    cmake \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/ITK \
    /tmp/ITK && \
    make -j $(nproc) install && \
    cd /tmp && rm -rf /tmp/ITK /tmp/itk-build

# VTK
RUN git clone --depth 1 --branch v9.2.2 https://github.com/Kitware/VTK.git
# Parallelized vtkPolyDataToImageStencil speeds up WM surface step.
COPY patch/vtkPolyDataToImageStencil.cxx patch/vtkPolyDataToImageStencil.h VTK/Imaging/Stencil/
RUN mkdir /tmp/vtk-build && cd /tmp/vtk-build && \
    cmake \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/VTK \
    /tmp/VTK && \
    make -j $(nproc) install && \
    cd /tmp && rm -rf /tmp/VTK /tmp/vtk-build

# Ensure MIRTK dependencies can be found
ENV ITK_DIR=/opt/itk \
    DEPENDS_VTK_DIR=/opt/vtk

# MIRTK (built with FLANN=OFF)
# library: libflann-dev (1.9.3-2build2)
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_resetStreamHC'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_setStreamDecode'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_decompress_safe'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_decompress_safe_continue'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_compress_HC_continue'
RUN git clone --depth 1 https://github.com/BioMedIA/MIRTK.git && \
    cd MIRTK && git submodule update --init -- Packages && \
    mkdir /tmp/mirtk-build && cd /tmp/mirtk-build && \
    cmake  \
        -D CMAKE_INSTALL_PREFIX=/opt/mirtk \
        -D CMAKE_BUILD_TYPE=Release \
        -D BUILD_SHARED_LIBS=ON \
        -D BUILD_APPLICATIONS=ON \
        -D BUILD_TESTING=OFF \
        -D BUILD_DOCUMENTATION=OFF \
        -D BUILD_CHANGELOG=OFF \
        -D MODULE_Common=ON \
        -D MODULE_Numerics=ON \
        -D MODULE_Image=ON \
        -D MODULE_IO=ON \
        -D MODULE_PointSet=ON \
        -D MODULE_Transformation=ON \
        -D MODULE_Registration=ON \
        -D MODULE_Deformable=ON \
        -D MODULE_DrawEM=ON \
        -D MODULE_Mapping=ON \
        -D MODULE_Scripting=ON \
        -D MODULE_Viewer=OFF \
        -D WITH_ARPACK=ON \
        -D WITH_FLANN=OFF \
        -D WITH_MATLAB=OFF \
        -D WITH_NiftiCLib=ON \
        -D WITH_PNG=ON \
        -D WITH_PROFILING=ON \
        -D WITH_TBB=ON \
        -D WITH_UMFPACK=ON \
        -D WITH_ITK=ON \
        -D WITH_VTK=ON \
        -D WITH_ZLIB=ON \
    /tmp/MIRTK && \
    make -j $(nproc) install && \
    ldconfig && \
    cd /tmp && rm -rf /tmp/MIRTK /tmp/mirtk-build

# Avoid hardcoding python path
RUN echo '#! /usr/bin/env python' 1<> /opt/mirtk/bin/mirtk
ENV PATH="/opt/mirtk/bin:$PATH"
