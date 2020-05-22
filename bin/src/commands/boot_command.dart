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
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
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

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:path/path.dart' as path;

import '../locate_pubspec_files.dart';
import '../options/verbose.dart';
import '../pub.dart';
import '../utils/borg_exception.dart';
// ignore_for_file: avoid_print

class BootCommand extends Command<void> {
  BootCommand() {
    configurationFactory.populateConfigurationArgs(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description => 'Executes pub get for every package in repository';

  @override
  String get name => 'boot';

  @override
  void run() => exitWithMessageOnBorgException(action: _run, exitCode: 255);

  final BorgConfigurationFactory configurationFactory = BorgConfigurationFactory();

  void _run() {
    final configuration = configurationFactory.createConfiguration(argResults: argResults);

    final packages = locatePubspecFiles(
      filename: 'pubspec.yaml',
      configuration: configuration,
      argResults: argResults,
    ).map(path.dirname);

    print('');

    var i = 1;
    for (final packageLocation in packages) {
      final counter = '[${i++}/${packages.length}]';
      print('$counter Executing pub get for $packageLocation ...');

      resolveDependencies(configuration: configuration, location: Directory(packageLocation));
    }

    print('\nSUCCESS: ${packages.length} packages have been booted');
  }
}
