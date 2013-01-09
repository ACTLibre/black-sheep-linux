#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
# Copyright (C) 2012 Carlos Jenkins <carlos@jenkins.co.cr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
Simple module to parse a CSV (Character separated values) with a list of
packages and create a Debian meta-package with dependencies to those.

It can also check if the current distribution still has those packages.

Usage:

    ./package_builder.py [list|check|version|build]
"""

import os
import sys
import shutil
import subprocess
from email.Utils import formatdate
from os.path import normpath, dirname, abspath, realpath, join, exists, isfile, isdir

###################
# Edit if required
VERSION = '1.0c'
###################

WHERE_AM_I = normpath(dirname(abspath(realpath(__file__))))
CSV_FILE = 'packages.csv'

if __name__ == '__main__':

    # Check arguments
    if len(sys.argv) != 2 or sys.argv[1] not in ['list', 'check', 'build']:
        print('Usage: ./package_builder.py [list|check|build]')
        exit(1)

    # Check if CSV file exists
    CSV_FILE = join(WHERE_AM_I, CSV_FILE)
    if not exists(CSV_FILE):
        print('[ERROR] File {f} not found. Exiting...'.format(f=CSV_FILE))
        exit(1)

    # Read file
    packages = []
    with open(CSV_FILE, 'r') as handler:
        lines = handler.readlines()

        # Remove commented lines and empty lines
        content = []
        for l in lines:
            l = l.strip()
            if not l.startswith('#') and l != '':
                content.append(l)

        # Get package names
        for c in content:
            package = c.split(',')[0].strip()

            if ' ' in package:
                print('[ERROR] Malformed line: {p}'.format(p=package))
                continue

            if package != '':
                packages.append(package)

    # Check that some data was read
    packages = sorted(set(packages))
    if not packages:
        print('[ERROR] No packages found on file.')
        exit(1)

    # Execute commands
    cmd = sys.argv[1]
    #  List command
    if cmd == 'list':
        print('Packages found:')
        print(packages)
        exit(0)

    #  Check command
    if cmd == 'check':
        errors = False
        with open(os.devnull, 'w') as f:
            for p in packages:
                # Debug
                #print('Analizing package {}...'.format(p))
                ret = subprocess.call(
                    ['apt-cache', 'show', p], stdout=f, stderr=f)
                if ret != 0:
                    errors = True
                    print('[ERROR] Package {p} not found.'.format(p=p))
        if errors:
            exit(1)
        print('[DONE] All packages found.')
        exit(0)

    #  Build command
    #   Create build folder
    build_folder = join(WHERE_AM_I, 'build', 'black-sheep_{v}'.format(v=VERSION))
    if exists(build_folder):
        shutil.rmtree(build_folder)
    os.makedirs(build_folder)

    #   Copy Debian package structure
    debian_folder = join(build_folder, 'debian')
    shutil.copytree(join(WHERE_AM_I, 'debian'), debian_folder)

    #   Change Debian control file
    lines = []
    line = []
    size = 27
    for p in packages:
        size += len(p) + 2
        if size <= 79:
            line.append(p)
        else:
            lines.append(', '.join(line))
            size = 1 + len(p)
            line = [p]
    if line:
        lines.append(', '.join(line))
    packages_string = ',\n '.join(lines)

    content = ''
    debian_control = join(debian_folder, 'control')
    with open(debian_control, 'r') as handler:
        content = handler.read()
        content = content.replace('[BLACK-SHEEP-DEPENDS]', packages_string)
    if not content:
        print('[ERROR] Error reading debian control file.')

    with open(debian_control, 'w') as handler:
        handler.write(content)

    #   Change Debian changelog
    content = ''
    debian_changelog = join(debian_folder, 'changelog')
    with open(debian_changelog, 'r') as handler:
        content = handler.read()

    if not 'black-sheep ({v})'.format(v=VERSION) in content:

        now = formatdate(localtime=1)
        distro = subprocess.Popen(
                        ['lsb_release', '-sc'],
                        stdout=subprocess.PIPE).communicate()[0].strip()

        new_entry = (\
            "black-sheep ({v}) {d}; urgency=low\n"
            "\n"
            "  * Updated Black Sheep to version {v}.\n"
            "\n"
            " -- Carlos Jenkins <carlos@jenkins.co.cr>  {n}")
        new_entry = new_entry.format(
                            v=VERSION,
                            d=distro,
                            n=now
                        ) + '\n\n' + content

        with open(debian_changelog, 'w') as handler:
            handler.write(new_entry)

    #   Build Debian package
    os.chdir(build_folder)
    ret = subprocess.call(['debuild', '-us', '-uc'])
    os.chdir(WHERE_AM_I)

    if ret !=0:
        print('[ERROR] Error building the Debian package.')
        exit(ret)

    deb = join(WHERE_AM_I, 'build', 'black-sheep_{v}_all.deb'.format(v=VERSION))
    print('[DONE] Debian package created at {f}'.format(f=deb))
    exit(0)
