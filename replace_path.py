#!/bin/python3
# Copyright 2026 ResRipper.
# SPDX-License-Identifier: Apache-2.0

#
# Replace and adjust paths in files
#
# By default, Xyce will hardcode the CMAKE_INSTALL_PREFIX
# parameter into some files; it will also add files directly 
# to the `<install_path>/share` directory.
#
# This script is for:
#     - Replacing the path set in CMAKE_INSTALL_PREFIX to the real installation path (normally `/usr`).
#     - Change the path linking to `<install_path>/share` to `<install_path>/share/xyce-<build_type>`
#
# Usage:
#     - CMAKE_INSTALL_PREFIX=/home/runner/Xyce_bin
#     - Current Xyce installation path: ./bin/xyce_serial-7.10.0/
#     - Xyce will be installed to `/usr`
#     > ./replace_path.py -p /home/runner/Xyce_bin -f ./bin/xyce_serial-7.10.0/ -i /usr

from argparse import ArgumentParser
from os import environ
from pathlib import Path

if __name__ == '__main__':
    parser = ArgumentParser(description='Replace and adjust paths in files')
    parser.add_argument(
        '-f',
        '--folder',
        help='Current Xyce installation path',
        type=str,
        default=f'{environ.get("HOME")}/Xyce_bin',
    )
    parser.add_argument(
        '-p',
        '--path',
        help='Xyce installation path (specified in CMAKE_INSTALL_PREFIX during build)',
        type=str,
        default=f'{environ.get("HOME")}/Xyce_bin',
    )
    parser.add_argument(
        '-i',
        '--install_path',
        help='Target installation path',
        type=str,
        default='/usr',
    )

    args = parser.parse_args()

    # Generate text file list
    file_ext = ['m', 'py', 'sh', 'txt', 'xml']
    files = []
    for ext in file_ext:
        files += list(Path(args.folder).rglob(f'*.{ext}'))

    build_type = 'serial'
    if environ.get('PARALLEL'):
        build_type = 'parallel'

    for file in files:
        content: str = file.read_text()
        # /.../Xyce_bin/share -> <install_path>/share/xyce-<build_type>
        content = content.replace(f'{Path(args.path)}/share', f'{Path(args.install_path)}/share/xyce-{build_type}')
        # /.../Xyce_bin -> <install_path>
        content = content.replace(f'{Path(args.path)}', f'{Path(args.install_path)}')
        # For /.../Xyce_bin/bin/buildxyceplugin.sh
        content = content.replace(r'xmldir=${XyceInstDir}/share', r'xmldir=${XyceInstDir}' + f'/share/xyce-{build_type}')

        if content != file.read_text():
            file.write_text(content)