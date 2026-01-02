#!/bin/python3
# Copyright 2026 ResRipper.
# SPDX-License-Identifier: Apache-2.0

#
# Replace Xyce installation path to comply with the FHS
#
# By default, Xyce will dump many files stright into `/.../share`
# and `/.../doc`. 
# 
# This script will fix it by changing the installation path in cmake_install.cmake
# to dedicated folders (/.../share/xyce-<build_type> and /share/doc/xyce-<build_type>).
#

from argparse import ArgumentParser
from os import environ
from pathlib import Path

if __name__ == '__main__':
    parser = ArgumentParser(description='Replace and adjust paths in cmake_install files')
    parser.add_argument(
        'path',
        help='Xyce build folder (normally in Xyce/build)',
        type=str
    )

    args = parser.parse_args()

    # Generate file list
    files = list(Path(args.path).rglob('cmake_install.cmake'))

    build_type = 'serial'
    if environ.get('PARALLEL'):
        build_type = 'parallel'

    for file in files:
        content: str = file.read_text()
        # /share -> /share/xyce-<build_type>
        content = content.replace(
            r'${CMAKE_INSTALL_PREFIX}/share', r'${CMAKE_INSTALL_PREFIX}/share/xyce-' + build_type
        )
        # /doc -> /share/doc/xyce-<build_type>
        content = content.replace(
            r'${CMAKE_INSTALL_PREFIX}/doc', r'${CMAKE_INSTALL_PREFIX}/share/doc/xyce-' + build_type
        )
        if content != file.read_text():
            file.write_text(content)