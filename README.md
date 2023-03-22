# MCRIBS

## Description
This builds a legacy version of the MCRIBS pipeline and its dependencies (ITK, VTK) from source.
Note: this installation does not include all pieces required to run `MCRIBReconAll`, you will need to have:
- FreeSurfer
- FSL

## Portability
To use MCRIBS in another Dockerfile, you will need to:
1. COPY `/opt/MCRIBS/` and `/opt/setupMCRIBS.sh`
1. Install the following libraries (jammy):
    libboost-dev
    libeigen3-dev
    libflann-dev
    libgl1-mesa-dev
    libglu1-mesa-dev
    libssl-dev
    libtbb-dev
    libxt-dev
    zlib1g-dev
