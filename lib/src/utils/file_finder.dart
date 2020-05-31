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

import 'dart:io';

import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

@immutable
class FileFinder {
  const FileFinder({@required this.filename, @required this.ignored});

  final String filename;
  final Iterable<String> ignored;

  List<String> findFiles(Iterable<String> locationSpecs) =>
      locationSpecs.expand(_findFilesAtLocationSpec).toSet().toList()..sort();

  List<String> _findFilesAtLocationSpec(String locationSpec) {
    final globbedLocations =
        Glob(locationSpec).listSync().where((item) => item.statSync().type == FileSystemEntityType.directory);
    final locationsToScan = <Directory>[
      Directory(locationSpec),
      ...globbedLocations.map((entity) => Directory(entity.path))
    ].where(_isNotIgnored);
    return locationsToScan
        .expand(_findFilesInDirectory)
        .map((location) => path.canonicalize(path.absolute(location)))
        .toList();
  }

  List<String> _findFilesInDirectory(Directory dir) => [
        if (dir.existsSync())
          ...dir
              .listSync(recursive: true)
              .where(_isNotIgnored)
              .where((item) => item.statSync().type == FileSystemEntityType.file && item.path.endsWith(filename))
              .map((entity) => entity.path)
              .toList()
      ];

  bool _isNotIgnored(FileSystemEntity f) => !ignored.any((x) => f.path.contains(x));
}
