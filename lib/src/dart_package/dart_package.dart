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

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../utils/file_io.dart';

// ignore_for_file: public_member_api_docs

@immutable
class DartPackage {
  DartPackage({
    @required this.path,
    Optional<String> Function(String) tryToReadFileSync = tryToReadFileSync,
  })  : pubspecYaml = tryToReadFileSync(join(path, 'pubspec.yaml')).iif(
          some: (content) => content.toPubspecYaml(),
          none: () => throw AssertionError(
            '${join(path, 'pubspec.yaml')} does not exist!',
          ),
        ),
        pubspecLock = tryToReadFileSync(join(path, 'pubspec.lock')).iif(
          some: (content) => Optional(content.loadPubspecLockFromYaml()),
          none: () => const Optional.none(),
        );

  final String path;
  final PubspecYaml pubspecYaml;
  final Optional<PubspecLock> pubspecLock;

  bool get isFlutterPackage =>
      pubspecYaml.dependencies.any((d) => d.package() == 'flutter');

  @override
  String toString() => 'DartPackage(path: $path)';

  @override
  // ignore: avoid_annotating_with_dynamic
  bool operator ==(dynamic other) =>
      other.runtimeType == runtimeType && path == other.path;

  @override
  int get hashCode {
    var result = 17;
    // ignore: join_return_with_assignment
    result = 37 * result + path.hashCode;
    return result;
  }
}
