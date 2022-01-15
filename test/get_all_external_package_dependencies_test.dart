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

import 'package:borg/src/get_all_external_package_dependencies.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

void main() {
  group('$getAllExternalPackageDependencies', () {
    group('when provided with empty input', () {
      final deps = getAllExternalPackageDependencies([]);
      test('it provides empty set', () {
        expect(deps, isEmpty);
      });
    });

    group('when provided with single pubspec.lock', () {
      final deps = getAllExternalPackageDependencies([
        const PubspecLock(packages: [_hostedDependencyA])
      ]);
      test('it provides single dependency', () {
        expect(deps, [_hostedDependencyA]);
      });
    });

    group(
      'when provided with two instances of pubspec.lock with '
      'the same dependency',
      () {
        final deps = getAllExternalPackageDependencies([
          const PubspecLock(packages: [_hostedDependencyA]),
          const PubspecLock(packages: [_hostedDependencyA]),
        ]);
        test('it provides single dependency', () {
          expect(deps, [_hostedDependencyA]);
        });
      },
    );

    group('when provided with two distinct hosted dependencies', () {
      final deps = getAllExternalPackageDependencies([
        const PubspecLock(packages: [_hostedDependencyA]),
        const PubspecLock(packages: [_hostedDependencyB]),
      ]);
      test('provides correct dependencies', () {
        expect(deps, [_hostedDependencyA, _hostedDependencyB]);
      });
    });
  });

  group('when provided with a path dependency', () {
    final deps = getAllExternalPackageDependencies([
      const PubspecLock(packages: [_pathDependencyA]),
    ]);
    test('it provides empty set', () {
      expect(deps, isEmpty);
    });
  });

  group(
    'when provided with two dependencies with difference in '
    'dependency type only',
    () {
      final deps = getAllExternalPackageDependencies([
        const PubspecLock(packages: [_hostedDependencyA]),
        const PubspecLock(packages: [_hostedDependencyATransitive]),
      ]);
      test('it provides single direct dependency', () {
        expect(deps, [_hostedDependencyA]);
      });
    },
  );
}

const _hostedDependencyA = PackageDependency.hosted(
  HostedPackageDependency(
    package: 'a',
    version: '1.0.0',
    name: 'a',
    url: 'https://pub.dartlang.org',
    type: DependencyType.direct,
  ),
);

const _hostedDependencyB = PackageDependency.hosted(
  HostedPackageDependency(
    package: 'b',
    version: '2.0.0',
    name: 'b',
    url: 'https://pub.dartlang.org',
    type: DependencyType.direct,
  ),
);

const _hostedDependencyATransitive = PackageDependency.hosted(
  HostedPackageDependency(
    package: 'a',
    version: '1.0.0',
    name: 'a',
    url: 'https://pub.dartlang.org',
    type: DependencyType.transitive,
  ),
);

const _pathDependencyA = PackageDependency.path(
  PathPackageDependency(
    package: 'a',
    version: '0.0.1',
    path: '../package1',
    relative: true,
    type: DependencyType.direct,
  ),
);
