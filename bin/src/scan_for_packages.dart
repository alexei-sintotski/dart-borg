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

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:borg/src/configuration/configuration.dart';
import 'package:borg/src/dart_package/dart_package.dart';
import 'package:borg/src/dart_package/discover_dart_packages.dart';
import 'package:meta/meta.dart';

import 'options/verbose.dart';
import 'utils/borg_exception.dart';

Iterable<DartPackage> scanForPackages({
  @required BorgConfiguration configuration,
  @required ArgResults argResults,
}) {
  stdout.write('Scanning for Dart packages...');

  final packages = discoverDartPackages(configuration: configuration);

  print(' ${packages.length} packages found');

  if (packages.isEmpty) {
    throw const BorgException('FATAL: No Dart packages found, check borg configuration and command-line!');
  }

  if (getVerboseFlag(argResults)) {
    for (final package in packages) {
      print('\t${package.path}');
    }
  }

  print('');

  return packages;
}
