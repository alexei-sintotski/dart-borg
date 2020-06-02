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

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../utils/file_io.dart';
import '../utils/lazy_data.dart';

// ignore_for_file: public_member_api_docs

@immutable
class DartPackage {
  DartPackage({
    @required this.path,
    Optional<String> Function(String) tryToReadFileSync = tryToReadFileSync,
  }) : _pubspecYaml = LazyData(
            populate: () => tryToReadFileSync(join(path, 'pubspec.yaml')).iif(
                  some: (content) => content.toPubspecYaml(),
                  none: () => null,
                ));

  final String path;
  PubspecYaml get pubspecYaml => _pubspecYaml.entry;

  bool get isFlutterPackage => pubspecYaml.dependencies.any((d) => d.package() == 'flutter');

  final LazyData<PubspecYaml> _pubspecYaml;
}
