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
import '../resolve_dependencies.dart';
import '../utils/borg_exception.dart';
// ignore_for_file: avoid_print

class BootCommand extends Command<void> {
  BootCommand() {
    configurationFactory.populateConfigurationArgs(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description => 'Executes "pub get" for multiple packages in repository\n\n'
      'Packages to bootstrap can be specified as arguments. '
      'If no arguments are supplied, the command bootstraps all scanned packages.';

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

    final packagesToBoot = argResults.rest.isEmpty
        ? packages
        : packages.where((location) => argResults.rest.any((arg) => location.endsWith(arg)));

    if (packagesToBoot.isEmpty) {
      throw const BorgException('\nWARNING: Nothing to do!');
    }

    print('\nBootstrapping packages:');
    var i = 1;
    for (final packageLocation in packagesToBoot) {
      final counter = '[${i++}/${packagesToBoot.length}]';
      print('$counter pub get $packageLocation ...');

      resolveDependencies(
        location: Directory(packageLocation),
        configuration: configuration,
        verbosity: getVerboseFlag(argResults) ? VerbosityLevel.verbose : VerbosityLevel.short,
      );
    }

    print('\nSUCCESS: ${packagesToBoot.length} packages have been bootstrapped');
  }
}
