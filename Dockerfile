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
        -DCMAKE_INSTALL_PREFIX=/opt/itk \
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
        -DCMAKE_INSTALL_PREFIX=/opt/vtk \
    /tmp/VTK && \
    make -j $(nproc) install && \
    cd /tmp && rm -rf /tmp/VTK /tmp/vtk-build


# MIRTK (built with FLANN=OFF)
# library: libflann-dev (1.9.3-2build2)
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_resetStreamHC'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_setStreamDecode'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_decompress_safe'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_decompress_safe_continue'
# /usr/bin/ld: ../../lib/libMIRTKPointSet.so.0.0.0: undefined reference to `LZ4_compress_HC_continue'
COPY patch/FindTBB.patch patch/Parallel.patch /tmp/patches/
RUN git clone --depth 1 https://github.com/DevelopmentalImagingMCRI/MCRIBS.git && \
    cd MCRIBS && git checkout bb57350a88c35487ae1ad2d33975ec83eaa15a45 && \
    mv MIRTK/MIRTK /tmp/MIRTK && \
    patch /tmp/MIRTK/Modules/Common/src/Parallel.cc /tmp/patches/Parallel.patch && \
    patch /tmp/MIRTK/CMake/Modules/FindTBB.cmake /tmp/patches/FindTBB.patch && \
    mkdir /tmp/mirtk-build && cd /tmp/mirtk-build && \
    ITK_DIR=/opt/itk && VTK_DIR=/opt/vtk && \
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
    cd /tmp && rm -rf /tmp/*

# Avoid hardcoding Python paths
RUN sed -i '1 c#! /usr/bin/env python' /opt/mirtk/bin/mirtk && \
    for TOOL in $(find /opt/mirtk/lib/tools/ -exec file {} \; | grep text | cut -d: -f1); do \
        echo $TOOL \
        if [[ $(head -n1 $tool) == *"python" ]]; then \
            sed -i '1 c#! /usr/bin/env python' $TOOL \
        fi \
    done

ENV PATH="/opt/mirtk/bin:$PATH" \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/opt/vtk/lib:/opt/itk/lib:${LD_LIBRARY_PATH}"
