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

    ./package_builder.py [build|check]
"""

import os
import sys
from os.path import normpath, dirname, abspath, realpath, join, exists

WHERE_AM_I = normpath(dirname(abspath(realpath(__file__))))
CSV_FILE = 'packages.csv'

if __name__ == '__main__':

    # Check arguments
    if len(sys.argv) != 2 or sys.argv[1] not in ['build', 'check']:
        print('Usage: ./package_builder.py [build|check]')
        exit(1)

    # Check if CSV file exists
    CSV_FILE = join(WHERE_AM_I, CSV_FILE)
    if not exists(CSV_FILE):
        print('File {f} not found. Exiting...'.format(f=CSV_FILE))
        exit(1)

    # Read file
    packages = []
    with open(CSV_FILE) as handler:
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
                print('Malformed line: {p}'.format(p=package))
                continue

            if package != '':
                packages.append(package)



    print(packages)
