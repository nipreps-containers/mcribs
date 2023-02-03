# MIRTK
Medical Image Registration ToolKit (MIRTK)


This builds the MCRIBS version of MIRTK (latest commit: https://github.com/DevelopmentalImagingMCRI/MCRIBS/commit/bb57350a88c35487ae1ad2d33975ec83eaa15a45) and its dependencies (ITK, VTK) from source.
Additionally, a modified version of VTK 9.2.2 is used, following https://github.com/DevelopmentalImagingMCRI/MCRIBS/commit/e0daec6d0798659c54eeea6c2bb2e440ca3de089


### Portability
To use `mirtk` tools in another Dockerfile, you will need to:
1. COPY /opt/mirtk <dest> and add its `bin/` to `$PATH`
1. COPY /opt/vtk/lib <shared libraries>
1. COPY /opt/itk/lib <shared libraries> (Optional)
1. Install the following libraries (jammy):
    - libarpack2-dev
    - libcgal-dev
    - libeigen3-dev
    - libpng-dev
    - libsuitesparse-dev
    - libtbb-dev

