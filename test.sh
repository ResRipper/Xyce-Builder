#!/bin/bash
# Copyright 2026 ResRipper.
# SPDX-License-Identifier: Apache-2.0

#
# Test Xyce
#
# CMake method doesn't work (`if(TARGET Xyce)` is always true somehow)
# 
# Use run_xyce_regression instead:
# > https://xyce.sandia.gov/documentation-tutorials/running-the-xyce-regression-suite
#

XYCE_VER=${XYCE_VER:-7.10.0}
PARALLEL=${PARALLEL:-false}

TEST_SUITE_PATH=$HOME/Xyce_Regression
TEST_OUTPUT_PATH=$HOME/Xyce_test
XYCE_BIN_PATH=/usr

mkdir "${TEST_OUTPUT_PATH}"

# Install prerequisites
TEST_DEP=(
    'perl'
    'python3' 'python-is-python3'
    'python3-numpy' 'python3-scipy'
    'libgtest-dev'
)
sudo apt update && sudo apt install -y ${TEST_DEP[*]}

# Download test suite
git clone \
    --depth 1 \
    --branch  Release-"${XYCE_VER}" \
    https://github.com/Xyce/Xyce_Regression \
    "$TEST_SUITE_PATH"

# Prepare & test
EXESTRING=${XYCE_BIN_PATH}/bin/Xyce
if [ "$PARALLEL" = true ]; then
    EXESTRING="mpirun -np 2 $EXESTRING"
fi

cd "$XYCE_BIN_PATH" || exit
eval "$(${TEST_SUITE_PATH}/TestScripts/suggestXyceTagList.sh ${XYCE_BIN_PATH}/bin/Xyce)"

"${TEST_SUITE_PATH}"/TestScripts/run_xyce_regression \
--output="${TEST_OUTPUT_PATH}" \
--xyce_test="${TEST_SUITE_PATH}" \
--resultfile="${TEST_SUITE_PATH}"/serial_results \
--taglist="${TAGLIST}" \
"${EXESTRING}"

# cmake \
#     -DCMAKE_INSTALL_PREFIX="${XYCE_BIN_PATH}" \
#     --log-level=DEBUG \
#     "${TEST_SUITE_PATH}"

# if ! ctest --output-on-failure -j "$(nproc)"
# then
#     # Re-run failed tests
#     ctest \
#     --timeout 3600 \
#     --rerun-failed \
#     --output-on-failure
# fi
