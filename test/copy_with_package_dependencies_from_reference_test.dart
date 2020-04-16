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

import 'package:borg/borg.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

void main() {
  group('$copyWithPackageDependenciesFromReference', () {
    group('provided with empty reference list', () {
      final deps = [directHostedXv1];
      final r = copyWithPackageDependenciesFromReference(deps, []);
      test('it copies the provided dependencies', () {
        expect(r, deps);
      });
    });

    group('provided with matching reference', () {
      final refs = [directHostedXv2];
      final r = copyWithPackageDependenciesFromReference([directHostedXv1], refs);
      test('it provides the reference dependency', () {
        expect(r, refs);
      });
    });

    group('provided with matching hosted reference with different dependency type', () {
      final r = copyWithPackageDependenciesFromReference([directHostedXv1], [transitiveHostedXv2]);
      test('it corrects the reference without modifying dependency type', () {
        expect(r, [directHostedXv2]);
      });
    });
  });
}

const directHostedXv1 = PackageDependency.hosted(HostedPackageDependency(
  package: 'x',
  version: '1.0.0',
  name: 'x',
  url: 'url',
  type: DependencyType.direct,
));

const directHostedXv2 = PackageDependency.hosted(HostedPackageDependency(
  package: 'x',
  version: '2.0.0',
  name: 'x',
  url: 'url',
  type: DependencyType.direct,
));

const transitiveHostedXv2 = PackageDependency.hosted(HostedPackageDependency(
  package: 'x',
  version: '2.0.0',
  name: 'x',
  url: 'url',
  type: DependencyType.transitive,
));
