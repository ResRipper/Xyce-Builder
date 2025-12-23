#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Build Trilinos
# Options:
#       - TRILINOS_VER (str): Trilinos version (e.g. 14-4-0), recommended by the official build guide
#       - PARALLEL (boolen): Compiled for parallel

PARALLEL=${PARALLEL:-true}

SRC_DIR=$HOME/Trilinos
BIN_PATH=$HOME/Trilinos_bin
XYCE_SRC=$HOME/Xyce

LIB_PATH=/usr/lib64
SUITESPARSE_INCLUDE=/usr/include/suitesparse

FLAGS="-O3 -fPIC"

# Build config
BUILD_CONFIG=(
    "-D AMD_LIBRARY_DIRS=${LIB_PATH}"
    "-D TPL_AMD_INCLUDE_DIRS=${SUITESPARSE_INCLUDE}"
)

# Specify compilers and cmake file
if [ "$PARALLEL" = true ]; then
    BUILD_CONFIG+=(
        '-DCMAKE_C_COMPILER=mpicc'
        '-DCMAKE_CXX_COMPILER=mpic++'
        '-DCMAKE_Fortran_COMPILER=mpif77'
        "-C ${XYCE_SRC}/cmake/trilinos/trilinos-MPI-base.cmake"
    )

else
    BUILD_CONFIG+=(
        '-DCMAKE_C_COMPILER=gcc'
        '-DCMAKE_CXX_COMPILER=g++'
        '-DCMAKE_Fortran_COMPILER=gfortran'
        "-C ${XYCE_SRC}/cmake/trilinos/trilinos-base.cmake"
    )
fi

mkdir -p "$BIN_PATH"
mkdir -p "$SRC_DIR"/build && cd "$SRC_DIR"/build || exit

# Build
cmake \
    -D CMAKE_INSTALL_PREFIX="${BIN_PATH}" \
    -D CMAKE_C_FLAGS="$FLAGS" \
    -D CMAKE_CXX_FLAGS="$FLAGS" \
    -D CMAKE_Fortran_FLAGS="$FLAGS" \
    ${BUILD_CONFIG[*]} "$SRC_DIR"

cmake --build . -j "$(nproc)" -t install
