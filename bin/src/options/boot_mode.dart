/*
 * MIT License
 *
 * Copyright (c) 2020 Alexei Sintotski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import 'package:args/args.dart';
import 'package:borg/src/boot_mode.dart';
import 'package:meta/meta.dart';

void addBootModeOption(ArgParser argParser, {@required BootMode defaultsTo}) =>
    argParser.addOption(
      _name,
      abbr: 'm',
      help:
          'Switches borg to the specified bootstrapping mode -- all subsequent '
          'borg runs will use the specified mode '
          'until another mode is selected in command line',
      allowed: [
        _basicValue,
        _incrementalValue,
      ],
      allowedHelp: {
        _basicValue:
            'Switches borg to bootstrap all packages found during package scan '
                'or specified in the command line',
        _incrementalValue:
            'Switches borg to bootstrap only packages with dependencies '
                'updated since the last successful bootstrapping',
      },
      defaultsTo: _optionEnum2String[defaultsTo],
    );

BootMode getBootModeOption(
  ArgResults argResults,
) =>
// ignore: avoid_as
    _optionString2Enum[argResults[_name] as String];

const _name = 'mode';
const _basicValue = 'basic';
const _incrementalValue = 'incremental';

const _optionString2Enum = {
  _basicValue: BootMode.basic,
  _incrementalValue: BootMode.incremental,
};

const _optionEnum2String = {
  BootMode.basic: _basicValue,
  BootMode.incremental: _incrementalValue,
};
