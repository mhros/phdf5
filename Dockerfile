FROM fedora:latest

MAINTAINER Martin Rosgaard <mhros (at) protonmail.com>

## Specify install paths for HDF5 and dependencies
ENV LIBPATH /Libraries 
ENV MPICH=$LIBPATH/mpich-3.2 ZLIB=$LIBPATH/zlib-1.2.11 HDF5=$LIBPATH/hdf5-1.10.1

## Make application aware of HDF5 library at runtime and put HDF5 utils in PATH
ENV LD_LIBRARY_PATH=$MPICH/lib:$HDF5/lib PATH=$MPICH/bin:$HDF5/bin:$PATH

## Create temporary path for downloaded source files and cd into it
WORKDIR ${LIBPATH}_SRC

## Copy {fetch,build}.phdf5 scripts into the temporary path
COPY *.phdf5 ./
## The scripts use environment variables defined above, software URLs 
## and build configs may need adjustment for other software versions

## Install necessary packages, run fetch- and build scripts, remove temporary path
RUN dnf install -y wget bzip2 openssh gcc-gfortran gcc-c++ && \
dnf groupinstall -y "Development Tools" && dnf clean all && \
bash fetch.phdf5 && bash build.phdf5 && rm -r ${LIBPATH}_SRC

WORKDIR /Application

## Fetch parallel-HDF5 examples
RUN mkdir examples && \
wget -r -nd -np -A "*.f90" -A "*.c" -P examples -e robots=off https://support.hdfgroup.org/ftp/HDF5/examples/parallel/
