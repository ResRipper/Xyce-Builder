#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Install all prerequisites

PARALLEL=${PARALLEL:-false}

apt update && apt upgrade -y

BUILD_TOOLS=(
    'gcc' 'g++' 'gfortran'
    'autoconf' 'automake' 'cmake' 'make'
    'git' 'libtool'
)

# Common dependencies
DEPS=(
    'adms' 'bison' 'flex'
    'libblas-dev' 'libfftw3-dev' 'libfl-dev'
    'liblapack-dev' 'libmetis-dev' 'libomp-dev'
    'libsuitesparse-dev'
)

# Dependencies - Parallel
DEPS_PRL=(
    'libopenmpi-dev'
    'libparmetis-dev'
)

TEST_DEP=(
    'perl'
    'python3'
    'python-is-python3'
    'libgtest-dev'
)

apt install -y \
${BUILD_TOOLS[*]} \
${DEPS[*]} \
${TEST_DEP[*]}

if [ "$PARALLEL" = true ]; then
    apt install -y ${DEPS_PRL[*]}
fi