#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2017, Psiphon Inc.
# All rights reserved.
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

from __future__ import print_function
import codecs
from collections import OrderedDict
import plistlib


# Change these two values for each project.
STRINGS_FILE = 'PsiphonClientCommonLibrary/Resources/Strings/en.lproj/Root.strings'
PLIST_FILES = [
    'Example/PsiphonClientCommonLibrary/InAppSettings.bundle/Root.inApp.plist',
    'PsiphonClientCommonLibrary/Resources/InAppSettings.bundle/ConnectionHelp.plist',
    'PsiphonClientCommonLibrary/Resources/InAppSettings.bundle/Feedback.plist',
    'PsiphonClientCommonLibrary/Resources/InAppSettings.bundle/PsiphonSettings.plist'
]

STRING_KEYS = ['Title', 'FooterText', 'IASKSubtitle', 'IASKPlaceholder']
MULTISTRING_KEYS = ['Titles']

def process_plist(plist_fname, strings):
    """
    Copy strings, keys, and comments from `plist_fname` into the
    `strings` dict, which is `key => {'key':..., 'default':..., 'description':...}`
    """
    plist = plistlib.readPlist(plist_fname)
    for item in plist['PreferenceSpecifiers']:
        _process_plist_dict(item, strings)


def _process_plist_dict(plist_dict, strings):
    """
    Helper for process_plist to process a single dict in a plist, which might
    contains strings.
    """
    if not isinstance(plist_dict, dict):
        return

    for multistring_key in MULTISTRING_KEYS:
        if multistring_key not in plist_dict:
            continue

        for plist_subdict in plist_dict.get(multistring_key):
            _process_plist_dict(plist_subdict, strings)

    for string_key in STRING_KEYS:
        if string_key not in plist_dict:
            continue

        key = plist_dict.get(string_key)
        default = plist_dict.get(string_key+'Default')
        description = plist_dict.get(string_key+'Description')

        if not key:
            raise Exception('ERROR: Empty key found: %s' % plist_dict)
        elif not default:
            # Skipping. This is probably an item covered by common-lib.
            print('SKIPPING: %s' % key.encode('utf-8'))
            continue
        elif not description:
            raise Exception('ERROR: Missing string description (if this string belongs to common-lib, exclude the default; otherwise do not be lazy and add a description): %s' % plist_dict)

        default = default.replace('"', '\\"').replace('\n', '\\n')

        if key in strings:
            # The key is already present in strings, so we'll combine the
            # descriptions (if necessary).
            if default != strings[key]['default']:
                raise Exception('ERROR: key used multiple times with non-matching defaults (same key must have same default): %s' % plist_dict)
            elif description != strings[key]['description']:
                strings[key]['description'] += '\n   ' + description
        else:
            strings[key] = {
                'key': key,
                'default': default,
                'description': description}


def go():
    strings = OrderedDict()

    for plist_fname in PLIST_FILES:
        process_plist(plist_fname, strings)

    with codecs.open(STRINGS_FILE, 'w', 'utf-8') as strings_file:
        strings_file.write('/* THIS FILE IS GENERATED. DO NOT EDIT. */\n\n')
        for key in strings:
            strings_file.write('/* %s */\n"%s" = "%s";\n\n' % (strings[key]['description'],
                                                               strings[key]['key'],
                                                               strings[key]['default']))



if __name__ == '__main__':
    go()
