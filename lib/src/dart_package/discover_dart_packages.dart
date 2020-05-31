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

// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../configuration/configuration.dart';
import '../utils/file_finder.dart';
import 'dart_package.dart';

Iterable<DartPackage> discoverDartPackages({
  @required BorgConfiguration configuration,
}) =>
    _locationsToScan(configuration).map((location) => DartPackage(path: location));

Iterable<String> _locationsToScan(BorgConfiguration config) {
  const fileFinder = FileFinder('pubspec.yaml');
  final includedLocations = fileFinder.findFiles(config.pathsToScan).where(_isNotGeneratedFlutterPluginDir);
  final excludedLocations = fileFinder.findFiles(config.excludedPaths).where(_isNotGeneratedFlutterPluginDir);
  final packages =
      includedLocations.where((location) => !excludedLocations.contains(location)).map(path.relative).map(path.dirname);
  return packages.toList()..sort();
}

bool _isNotGeneratedFlutterPluginDir(String path) => !path.contains('/.symlinks/');
