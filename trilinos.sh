#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Build Trilinos
# Options:
#       - TRILINOS_VER (str): Trilinos version (e.g. 12-12-1), recommended by the official build guide 
#       - PARALLEL (boolen): Compiled for parallel

TRILINOS_VER=${TRILINOS_VER:-12-12-1}
PARALLEL=${PARALLEL:-true}

SRC_DIR=$HOME/Trilinos
BUILD_PATH=$HOME/Trilinos_bin

LIB_PATH=/usr/lib64
SUITESPARSE_INCLUDE=/usr/include/suitesparse

FLAGS="-O3 -fPIC"

# Build config
BUILD_CONFIG=(
    '-DCMAKE_MAKE_PROGRAM=make'
    '-DTrilinos_ENABLE_NOX=ON'
        '-DNOX_ENABLE_LOCA=ON'
    '-DTrilinos_ENABLE_EpetraExt=ON'
        '-DEpetraExt_BUILD_BTF=ON'
        '-DEpetraExt_BUILD_EXPERIMENTAL=ON'
        '-DEpetraExt_BUILD_GRAPH_REORDERINGS=ON'
    '-DTrilinos_ENABLE_TrilinosCouplings=ON'
    '-DTrilinos_ENABLE_Ifpack=ON'
    '-DTrilinos_ENABLE_AztecOO=ON'
    '-DTrilinos_ENABLE_Belos=ON'
    '-DTrilinos_ENABLE_Teuchos=ON'
    '-DTrilinos_ENABLE_COMPLEX_DOUBLE=ON'
    '-DTrilinos_ENABLE_Amesos=ON'
        '-DAmesos_ENABLE_KLU=ON'
    '-DTrilinos_ENABLE_Amesos2=ON'
        '-DAmesos2_ENABLE_KLU2=ON'
        '-DAmesos2_ENABLE_Basker=ON'
    '-DTrilinos_ENABLE_Sacado=ON'
    '-DTrilinos_ENABLE_Stokhos=ON'
    '-DTrilinos_ENABLE_Kokkos=ON'
    '-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF'
    '-DTrilinos_ENABLE_CXX11=ON'
    '-DTPL_ENABLE_AMD=ON'
    '-DTPL_ENABLE_BLAS=ON'
    '-DTPL_ENABLE_LAPACK=ON'
)

# Specify compiler
if [ "$PARALLEL" = true ]; then
    BUILD_CONFIG+=(
        '-DCMAKE_C_COMPILER=mpicc'
        '-DCMAKE_CXX_COMPILER=mpic++'
        '-DCMAKE_Fortran_COMPILER=mpif77'
    )
else
    BUILD_CONFIG+=(
        '-DCMAKE_C_COMPILER=gcc'
        '-DCMAKE_CXX_COMPILER=g++'
        '-DCMAKE_Fortran_COMPILER=gfortran'
    )
fi

mkdir -p "$BUILD_PATH"

# Fetch source code and build
git clone \
    --depth 1 \
    --branch  trilinos-release-"${TRILINOS_VER}" \
    https://github.com/trilinos/Trilinos \
    "$SRC_DIR"

cd "$BUILD_PATH" || exit

cmake \
-G 'Unix Makefiles' \
-DCMAKE_INSTALL_PREFIX="${BUILD_PATH}" \
-DAMD_LIBRARY_DIRS="${LIB_PATH}" \
-DTPL_AMD_INCLUDE_DIRS="${SUITESPARSE_INCLUDE}" \
-DCMAKE_CXX_FLAGS="$FLAGS" \
-DCMAKE_C_FLAGS="$FLAGS" \
-DCMAKE_Fortran_FLAGS="$FLAGS" \
${BUILD_CONFIG[*]} "$SRC_DIR"

make -j "$(nproc)"
