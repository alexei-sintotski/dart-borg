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

import 'package:borg/src/dart_package/dart_package.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:test/test.dart';

void main() {
  group('$DartPackage', () {
    group('given a Dart package definition', () {
      final package = DartPackage(path: packagePath, tryToReadFileSync: (_) => const Optional(dartPackageDefinition));

      test('it provides correct package path', () {
        expect(package.path, packagePath);
      });

      test('it identifies package as a Dart package', () {
        expect(package.isFlutterPackage, false);
      });
    });
  });

  group('given a Flutter package definition', () {
    final package = DartPackage(path: packagePath, tryToReadFileSync: (_) => const Optional(flutterPackageDefinition));

    test('it identifies package as a Flutter package', () {
      expect(package.isFlutterPackage, true);
    });
  });
}

const packageName = 'some_package';
const packagePath = '.';
const dartPackageDefinition = 'name: $packageName';
const flutterPackageDefinition = '''
name: $packageName
dependencies:
  flutter:
''';
