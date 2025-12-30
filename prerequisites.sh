#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Install all prerequisites

PARALLEL=${PARALLEL:-false}

#  If TeXLive from distro is obsoleted
# > https://wiki.debian.org/TeXLive
TEXLIVE_OBSOLETE=${TEXLIVE_OBSOLETE:-true}
TEXLIVE_VER=${TEXLIVE_VER:-2023}

sudo apt update && sudo apt upgrade -y

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

    # Documentation
    'latexmk' 'texlive'
)

# Dependencies - Parallel
DEPS_PRL=(
    'libopenmpi-dev'
    'libparmetis-dev'
)

TEST_DEP=(
    'perl'
    'python3' 'python-is-python3'
    'python3-numpy' 'python3-scipy'
    'libgtest-dev'
)

sudo apt install -y \
${BUILD_TOOLS[*]} \
${DEPS[*]} \
${TEST_DEP[*]}

if [ "$PARALLEL" = true ]; then
    sudo apt install -y ${DEPS_PRL[*]}
fi

# LaTeX dependencies
tlmgr init-usertree

## Change mirror
## Mirror list: https://www.tug.org/historic/
if [ "$TEXLIVE_OBSOLETE" = true ]; then
    tlmgr option repository \
        "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TEXLIVE_VER}/tlnet-final/"
fi

tlmgr install binhex enumitem framed kastrup \
    multirow newtx optional pgf preprint