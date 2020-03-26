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

import 'package:args/command_runner.dart';

import '../file_finder.dart';

// ignore_for_file: avoid_print, avoid_as

class ProbeCommand extends Command<void> {
  ProbeCommand() {
    argParser
      ..addMultiOption(
        'paths',
        abbr: 'p',
        help: 'list of paths to scan for Dart packages (glob syntax allowed)',
        valueHelp: 'PATH1,PATH2,...',
        defaultsTo: ['.'],
      )
      ..addMultiOption(
        'exclude',
        abbr: 'x',
        help: 'list of paths to exclude from scan (glob syntax allowed)',
        valueHelp: 'PATH1,PATH2,...',
        defaultsTo: ['.'],
      )
      ..addFlag('verbose', abbr: 'v', help: 'Verbose output');
  }

  @override
  String get description => 'Checks consistency of Dart dependendencies across all packages';

  @override
  String get name => 'probe';

  @override
  void run() {
    final pubspecLockLocations = _pubspecLockLocationsToScan();
    print('Found ${pubspecLockLocations.length} pubspec.lock files');
    if (argResults['verbose'] as bool) {
      for (final location in pubspecLockLocations) {
        print('\t$location');
      }
    }
  }

  Iterable<String> _pubspecLockLocationsToScan() {
    const pubspecLockFinder = FileFinder('pubspec.lock');
    final includedpubspecLockLocations = pubspecLockFinder.findFiles(argResults['paths'] as Iterable<String>);
    final excludedPubspecLockLocations = pubspecLockFinder.findFiles(argResults['exclude'] as Iterable<String>);

    return includedpubspecLockLocations.where((location) => !excludedPubspecLockLocations.contains(location));
  }
}
