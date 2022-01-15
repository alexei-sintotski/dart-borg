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

import 'package:borg/src/package_dependency_to_version.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

void main() {
  group('setPackageDependenciesToVersion', () {
    group('when provided with no pubspec lock objects', () {
      final newPubspecLocks = packageDependencyToVersion(
        dependency: _hostedDependencyAv1,
        inPubspecLocks: {},
        toVersion: '1.0.0',
      );

      test('it returns an empty pubspec locks list', () {
        expect(newPubspecLocks, isEmpty);
      });
    });

    group('when provided a pubspec.lock not containing the dependency', () {
      final pubspecLocks = {
        'a': const PubspecLock(packages: [_hostedDependencyAv2])
      };

      final newPubspecLocks = packageDependencyToVersion(
        dependency: _hostedDependencyAv1,
        toVersion: '1.0.0',
        inPubspecLocks: pubspecLocks,
      );

      test('it provides the same pubspec locks', () {
        expect(newPubspecLocks, pubspecLocks);
      });
    });

    group('when provided pubspec.lock objects containing the dependency', () {
      const version = '1.1.0';

      final pubspecLocks = {
        'a': const PubspecLock(
          packages: [
            _hostedDependencyAv1,
            _hostedDependencyAv2,
          ],
        ),
        'b': const PubspecLock(
          packages: [
            _hostedDependencyAv1,
            _hostedDependencyAv2,
          ],
        ),
        'c': const PubspecLock(
          packages: [
            _hostedDependencyAv1,
            _hostedDependencyAv2,
          ],
        ),
        'd': const PubspecLock(
          packages: [
            _hostedDependencyAv1,
            _hostedDependencyAv2,
          ],
        )
      };

      final newPubspecLocks = packageDependencyToVersion(
        dependency: _hostedDependencyAv1,
        toVersion: version,
        inPubspecLocks: pubspecLocks,
      );

      test('it changes $_hostedDependencyAv1 packages to version $version', () {
        for (final pubspecLock in newPubspecLocks.entries) {
          for (final package in pubspecLock.value.packages) {
            if (package.package() == _hostedDependencyAv1.package()) {
              expect(package.version(), version);
            }
          }
        }
      });

      test('it did not change $_hostedDependencyAv2 packages', () {
        for (final pubspecLock in newPubspecLocks.entries) {
          for (final package in pubspecLock.value.packages) {
            if (package.package() == _hostedDependencyAv2.package()) {
              expect(package.version(), _hostedDependencyAv2.version());
            }
          }
        }
      });
    });
  });
}

const _hostedDependencyAv1 = PackageDependency.hosted(
  HostedPackageDependency(
    package: 'a',
    version: '1.0.0',
    name: 'a',
    url: 'https://pub.dartlang.org',
    type: DependencyType.direct,
  ),
);

const _hostedDependencyAv2 = PackageDependency.hosted(
  HostedPackageDependency(
    package: 'b',
    version: '2.0.0',
    name: 'b',
    url: 'https://pub.dartlang.org',
    type: DependencyType.development,
  ),
);
