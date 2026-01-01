#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Xyce build script
# Options:
#       - PARALLEL (boolen): Compile for MPI parallelism
#       - XYCE_VER (string): Xyce version to build

PARALLEL=${PARALLEL:-false}
XYCE_VER=${XYCE_VER:-7.10.0}
SKIP_TEST=${SKIP_TEST:-false}

SRC_DIR=$HOME/Xyce
Trilinos_PATH=/usr
TEST_SUITE_PATH=$HOME/Xyce_Regression

SUITESPARSE_INCLUDE=/usr/include/suitesparse

# Installation prefix
BIN_PATH=$HOME/Xyce_bin
mkdir -p "$BIN_PATH"

# Compilier flags
FLAGS=(
    '-O3' # Optimize level: 3
    '-fPIC' # Position independent code
    "-I${SUITESPARSE_INCLUDE}"
)

# Build config
BUILD_CONFIG=(
    "-D Trilinos_ROOT=${Trilinos_PATH}"
    "-D CMAKE_INSTALL_PREFIX=${BIN_PATH}"
    '-D Xyce_PLUGIN_SUPPORT=ON'

    # Test
    '-D BUILD_TESTING=ON'
    "-D Xyce_REGRESSION_DIR=${TEST_SUITE_PATH}"
    '-D Xyce_GTEST_UNIT_TESTS=ON' # Enable Google Test
)

if [ "$PARALLEL" = true ]; then
    BUILD_CONFIG+=(
        '-D CMAKE_C_COMPILER=mpicc'
        '-D CMAKE_CXX_COMPILER=mpicxx'

        # Enable ShyLU
        '-D Xyce_SHYLU=ON'
        '-D Xyce_AMESOS2_SHYLUBASKER=ON'
    )
else
    BUILD_CONFIG+=(
        '-D CMAKE_C_COMPILER=gcc'
        '-D CMAKE_CXX_COMPILER=g++'
    )
fi

cd "$SRC_DIR" && ./bootstrap
mkdir -p build && cd build || exit

# Config and build
cmake \
-D CMAKE_C_FLAGS="${FLAGS[*]}" \
-D CMAKE_CXX_FLAGS="${FLAGS[*]}" \
${BUILD_CONFIG[*]} "${SRC_DIR}"

cmake --build . -j "$(nproc)"

# Run tests
#   - Most tests run on multiple cores, using parallel (-j) 
#     doesn't offer much benefit and can even slow down testing.
if [ "$SKIP_TEST" = false ]; then
    if ! ctest --output-on-failure
    then
        # Re-run failed tests
        ctest \
        --timeout 3600 \
        --rerun-failed \
        --output-on-failure
    fi
fi

cmake --install .

# Move files under `/share` into a dedicated folder `/share/xyce-<type>`
mkdir -p "${BIN_PATH}"/share_tmp
cp -r "${BIN_PATH}"/share/ "${BIN_PATH}"/share_tmp/ && rm -rf "${BIN_PATH}"/share
mv "${BIN_PATH}"/share_tmp "${BIN_PATH}"/share

if [ "$PARALLEL" = true ]; then
    mv "${BIN_PATH}"/share/share "${BIN_PATH}"/share/xyce-parallel
else
    mv "${BIN_PATH}"/share/share "${BIN_PATH}"/share/xyce-serial
fi

# Build documentation
## Reference guide
cd "${SRC_DIR}"/doc/Reference_Guide || exit
## Replace Sandia's internal class
sed -i 's|\\documentclass\[11pt,report\]{SANDreport}|\\documentclass\[11pt,letterpaper\]{scrreprt}|' Xyce_RG.tex
sed -i 's|\\usepackage\[sand\]{optional}|\\usepackage\[report\]{optional}|' Xyce_RG.tex
sed -i 's|\\SANDauthor{|\\author{|' Xyce_RG.tex
make

# User guide
cd "${SRC_DIR}"/doc/Users_Guide || exit
## Replace Sandia's internal class
sed -i 's|\\documentclass\[11pt,report\]{SANDreport}|\\documentclass\[11pt,letterpaper\]{scrreprt}|' Xyce_UG.tex
sed -i 's|\\usepackage\[sand\]{optional}|\\usepackage\[report\]{optional}|' Xyce_UG.tex
sed -i 's|\\SANDauthor{|\\author{|' Xyce_UG.tex
make

# Packup
mv "${SRC_DIR}"/doc/Reference_Guide/Xyce_RG.pdf "${BIN_PATH}"/doc/
mv "${SRC_DIR}"/doc/Users_Guide/Xyce_UG.pdf "${BIN_PATH}"/doc/

if [ "$PARALLEL" = true ]; then
    tar -c \
    --zstd \
    -f "${HOME}/xyce_parallel-${XYCE_VER}.tar.zst" \
    -C "${BIN_PATH}"/ .
else
    tar -c \
    --zstd \
    -f "${HOME}/xyce_serial-${XYCE_VER}.tar.zst" \
    -C "${BIN_PATH}"/ .
fi
