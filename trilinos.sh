#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Build Trilinos
# Options:
#       - PARALLEL (boolen): Compile for MPI parallelism

PARALLEL=${PARALLEL:-false}

SRC_DIR=$HOME/Trilinos
BIN_PATH=/usr
XYCE_SRC=$HOME/Xyce

LIB_PATH=/usr/lib64
SUITESPARSE_INCLUDE=/usr/include/suitesparse

FLAGS="-O3 -fPIC"

# Build config
BUILD_CONFIG=(
    # AMD
    "-D AMD_LIBRARY_DIRS=${LIB_PATH}"
    "-D TPL_AMD_INCLUDE_DIRS=${SUITESPARSE_INCLUDE}"

    # ROL
    "-D Trilinos_ENABLE_ROL=ON"

    # OpenMP
    '-D Trilinos_ENABLE_OpenMP=ON'

    # METIS
    '-D TPL_ENABLE_METIS=ON'
)

# Specify compilers and cmake file
if [ "$PARALLEL" = true ]; then
    BUILD_CONFIG+=(
        '-D CMAKE_C_COMPILER=mpicc'
        '-D CMAKE_CXX_COMPILER=mpic++'
        '-D CMAKE_Fortran_COMPILER=mpif77'
        "-C ${XYCE_SRC}/cmake/trilinos/trilinos-MPI-base.cmake"

        # ShyLU require MPI
        '-D Trilinos_ENABLE_ShyLU=ON'
        '-D Trilinos_ENABLE_ShyLU_NodeBasker=ON' # Xyce support Basker solver

        # parMETIS
        '-D TPL_ENABLE_ParMETIS=ON'
    )
else
    BUILD_CONFIG+=(
        '-D CMAKE_C_COMPILER=gcc'
        '-D CMAKE_CXX_COMPILER=g++'
        '-D CMAKE_Fortran_COMPILER=gfortran'
        "-C ${XYCE_SRC}/cmake/trilinos/trilinos-base.cmake"
    )
fi

mkdir -p "$BIN_PATH" "$SRC_DIR"/build
cd "$SRC_DIR"/build || exit

# Build
cmake \
    -D CMAKE_INSTALL_PREFIX="${BIN_PATH}" \
    -D CMAKE_C_FLAGS="$FLAGS" \
    -D CMAKE_CXX_FLAGS="$FLAGS" \
    -D CMAKE_Fortran_FLAGS="$FLAGS" \
    ${BUILD_CONFIG[*]} "$SRC_DIR"

sudo cmake --build . -j "$(nproc)" -t install
