#!/usr/bin/env python3
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

'''
Pulls and massages our translations from Transifex.

Run with
# If you don't already have pipenv:
$ python3 -m pip install --upgrade pipenv

$ pipenv install --ignore-pipfile
$ pipenv run python transifex_pull.py

#To reset your pipenv state (e.g., after a Python upgrade):
$ pipenv --rm

'''

import transifexlib


DEFAULT_LANGS = {
    'am': 'am',         # Amharic
    'ar': 'ar',         # Arabic
    'az@latin': 'az',   # Azerbaijani
    'be': 'be',         # Belarusian
    'bn': 'bn',         # Bengali
    'bo': 'bo',         # Tibetan
    'de': 'de',         # German
    'el_GR': 'el',      # Greek
    'es': 'es',         # Spanish
    'fa': 'fa',         # Farsi/Persian
    'fa_AF': 'fa-AF',   # Dari (Afgan Farsi)
    'fi_FI': 'fi',      # Finnish
    'fr': 'fr',         # French
    'he': 'he',         # Hebrew
    'hi': 'hi',         # Hindi
    'hr': 'hr',         # Croation
    'id': 'id',         # Indonesian
    'it': 'it',         # Italian
    'kk': 'kk',         # Kazakh
    'km': 'km',         # Khmer
    'ko': 'ko',         # Korean
    'ky': 'ky',         # Kyrgyz
    'my': 'my',         # Burmese
    'nb_NO': 'nb',      # Norwegian
    'nl': 'nl',         # Dutch
    'pt_BR': 'pt-BR',   # Portuguese-Brazil
    'pt_PT': 'pt-PT',   # Portuguese-Portugal
    'ru': 'ru',         # Russian
    'sw': 'sw',         # Swahili
    'tg': 'tg',         # Tajik
    'th': 'th',         # Thai
    'ti': 'ti',         # Tigrinya
    'tk': 'tk',         # Turkmen
    'tr': 'tr',         # Turkish
    'uk': 'uk',         # Ukrainian
    'uz': 'uz',         # Uzbek
    'vi': 'vi',         # Vietnamese
    'zh': 'zh-Hans',    # Chinese (simplified)
    'zh_TW': 'zh-Hant'  # Chinese (traditional)
}


RTL_LANGS = ('ar', 'fa', 'he')


UNTRANSLATED_FLAG = '[UNTRANSLATED]'


def pull_ios_app_translations():
    resources = (
        ('ios-common-library-localizablestrings', 'Localizable.strings'),
        ('ios-common-library-rootstrings', 'Root.strings'),
    )

    def mutator_fn(lang, fname, content):
        content = merge_applestrings_translations(lang, fname, content)
        content = flag_untranslated_applestrings(lang, fname, content)
        return content

    for resname, fname in resources:
        transifexlib.process_resource(f'https://www.transifex.com/otf/Psiphon3/{resname}/',
                                      DEFAULT_LANGS,
                                      './PsiphonClientCommonLibrary/Resources/Strings/en.lproj/Localizable.strings',
                                      lambda lang: './PsiphonClientCommonLibrary/Resources/Strings/%s.lproj/%s' % (lang, fname),
                                      mutator_fn,
                                      bom=False)
        print('%s: DONE' % (resname,))


def go():
    pull_ios_app_translations()

    print('FINISHED')


if __name__ == '__main__':
    go()
