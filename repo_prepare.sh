#!/bin/bash
# Copyright 2025 ResRipper.
# SPDX-License-Identifier: Apache-2.0

# Download Trilinos and Xyce repo

TRILINOS_VER=${TRILINOS_VER:-14-4-0}
TRILINOS_SRC=$HOME/Trilinos

XYCE_VER=${XYCE_VER:-7.10.0}
XYCE_SRC=$HOME/Xyce
TEST_SUITE_PATH=$HOME/Xyce_Regression

# Trilinos
git clone \
    --depth 1 \
    --branch  trilinos-release-"${TRILINOS_VER}" \
    https://github.com/trilinos/Trilinos \
    "$TRILINOS_SRC"

# Xyce
git clone \
    --depth 1 \
    --branch  Release-"${XYCE_VER}" \
    https://github.com/Xyce/Xyce \
    "$XYCE_SRC"

# Test suite
git clone \
    --depth 1 \
    --branch  Release-"${XYCE_VER}" \
    https://github.com/Xyce/Xyce_Regression \
    "$TEST_SUITE_PATH"