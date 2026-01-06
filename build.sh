#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Xyce build script
# Options:
#       - PARALLEL (boolen): Compile for MPI parallelism
#       - XYCE_VER (string): Xyce version to build

PARALLEL=${PARALLEL:-false}
XYCE_VER=${XYCE_VER:-7.10.0}
TEST=${TEST:-false}

SRC_DIR=$HOME/Xyce
Trilinos_PATH=/usr
SCRIPT_PATH=$(pwd)

SUITESPARSE_INCLUDE=/usr/include/suitesparse

# Installation prefix
BIN_PATH=$HOME/Xyce_bin
INSTALL_PATH=/usr
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
    "-D CMAKE_INSTALL_PREFIX=${INSTALL_PATH}"
    '-D Xyce_PLUGIN_SUPPORT=ON'
    "-D Xyce_ROL=ON"

    # # Test
    # '-D BUILD_TESTING=ON'
    # "-D Xyce_REGRESSION_DIR=${TEST_SUITE_PATH}"
    # '-D Xyce_GTEST_UNIT_TESTS=ON' # Enable Google Test
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

## Adjust installation path to comply with the FHS
if [ "$PARALLEL" = true ]; then
    sed -i 's|${XyceInstDir}/share|${XyceInstDir}/share/xyce-parallel|' "${SRC_DIR}"/build/buildxyceplugin.sh
    sed -i 's|/usr/share|/usr/share/xyce-parallel|' "${SRC_DIR}"/build/utils/XyceCInterface/SetupPythonEnv.m
    sed -i 's|${Xyce_DIR}/../../../share/|${Xyce_DIR}/../../../share/xyce-parallel|' "${SRC_DIR}"/build/utils/ADMS/CMakeLists.txt
    sed -i 's|<Path to Xyce Install>/share|<Path to Xyce Install>/share/xyce-parallel|' "${SRC_DIR}"/build/utils/ADMS/CMakeLists.txt
else
    sed -i 's|${XyceInstDir}/share|${XyceInstDir}/share/xyce-serial|' "${SRC_DIR}"/build/buildxyceplugin.sh
    sed -i 's|/usr/share|/usr/share/xyce-serial|' "${SRC_DIR}"/build/utils/XyceCInterface/SetupPythonEnv.m
    sed -i 's|${Xyce_DIR}/../../../share/|${Xyce_DIR}/../../../share/xyce-serial|' "${SRC_DIR}"/build/utils/ADMS/CMakeLists.txt
    sed -i 's|<Path to Xyce Install>/share|<Path to Xyce Install>/share/xyce-serial|' "${SRC_DIR}"/build/utils/ADMS/CMakeLists.txt
fi

python3 "${SCRIPT_PATH}"/replace_path.py "${SRC_DIR}"/build

# Install to binary path
cmake --install . --prefix "${BIN_PATH}"
# Install to current environment for testing
if [ "$TEST" = true ]; then
    sudo cmake --install .
fi

# Build documentation
## Reference guide
cd "${SRC_DIR}"/doc/Reference_Guide || exit
### Replace Sandia's internal class
sed -i 's|\\documentclass\[11pt,report\]{SANDreport}|\\documentclass\[11pt,letterpaper\]{scrreprt}|' Xyce_RG.tex
sed -i 's|\\usepackage\[sand\]{optional}|\\usepackage\[report\]{optional}|' Xyce_RG.tex
sed -i 's|\\SANDauthor{|\\author{|' Xyce_RG.tex
make

## User guide
cd "${SRC_DIR}"/doc/Users_Guide || exit
### Replace Sandia's internal class
sed -i 's|\\documentclass\[11pt,report\]{SANDreport}|\\documentclass\[11pt,letterpaper\]{scrreprt}|' Xyce_UG.tex
sed -i 's|\\usepackage\[sand\]{optional}|\\usepackage\[report\]{optional}|' Xyce_UG.tex
sed -i 's|\\SANDauthor{|\\author{|' Xyce_UG.tex
make

# Move files
BUILD_TYPE='serial'
if [ "$PARALLEL" = true ]; then
    BUILD_TYPE='parallel'
fi

mkdir -p "${BIN_PATH}"/share/licenses/xyce-"${BUILD_TYPE}"

## License
mv "${BIN_PATH}"/share/doc/xyce-"${BUILD_TYPE}"/CPack.OSLicense.txt "${BIN_PATH}"/share/licenses/xyce-"${BUILD_TYPE}"/

## Doc

### Delete 'no pdf doc anymore' note
rm "${BIN_PATH}"/share/doc/xyce-"${BUILD_TYPE}"/README.TXT

mv "${SRC_DIR}"/doc/Reference_Guide/Xyce_RG.pdf "${BIN_PATH}"/share/doc/xyce-"${BUILD_TYPE}"
mv "${SRC_DIR}"/doc/Users_Guide/Xyce_UG.pdf "${BIN_PATH}"/share/doc/xyce-"${BUILD_TYPE}"

# Pack
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