#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Download Trilinos and Xyce repo

TRILINOS_VER=${TRILINOS_VER:-14-4-0}
TRILINOS_SRC=$HOME/Trilinos

XYCE_VER=${XYCE_VER:-7.10.0}
XYCE_SRC=$HOME/Xyce

git clone \
    --depth 1 \
    --branch  trilinos-release-"${TRILINOS_VER}" \
    https://github.com/trilinos/Trilinos \
    "$TRILINOS_SRC"

git clone \
    --depth 1 \
    --branch  Release-"${XYCE_VER}" \
    https://github.com/Xyce/Xyce \
    "$XYCE_SRC"
