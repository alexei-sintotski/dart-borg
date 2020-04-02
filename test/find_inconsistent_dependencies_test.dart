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

import 'package:borg/src/find_inconsistent_dependencies.dart';
import 'package:borg/src/generic_dependency_usage_report.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

void main() {
  group('findInconsistentDependencies', () {
    group('when provided with empty input', () {
      final report = findInconsistentDependencies({});
      test('it return empty report', () {
        expect(report, isEmpty);
      });
    });

    group('when provided with single pubspec.lock', () {
      final report = findInconsistentDependencies({
        'a': const PubspecLock(packages: [_hostedDependencyAv1])
      });
      test('it provides empty report', () {
        expect(report, isEmpty);
      });
    });

    group('when provided with two conherent instances of pubspec.lock', () {
      final report = findInconsistentDependencies({
        'a1': const PubspecLock(packages: [_hostedDependencyAv1]),
        'a2': const PubspecLock(packages: [_hostedDependencyAv1]),
      });
      test('it provides empty report', () {
        expect(report, isEmpty);
      });
    });

    group('when provided with two distinct versions of a hosted dependency', () {
      final report = findInconsistentDependencies({
        'a1': const PubspecLock(packages: [_hostedDependencyAv1]),
        'a2': const PubspecLock(packages: [_hostedDependencyAv2]),
      });
      test('provides correct report', () {
        expect(report, _reportAv1Av2);
      });
    });
  });

  group('when provided with two distinct versions of a path dependency', () {
    final report = findInconsistentDependencies({
      'a1': const PubspecLock(packages: [_pathDependencyAv1]),
      'a2': const PubspecLock(packages: [_pathDependencyAv2]),
    });
    test('it provides empty report', () {
      expect(report, isEmpty);
    });
  });

  group('when provided with two hosted and path versions of a dependency', () {
    final report = findInconsistentDependencies({
      'a1': const PubspecLock(packages: [_hostedDependencyAv1]),
      'a2': const PubspecLock(packages: [_pathDependencyAv1]),
    });
    test('it provides report with a single entry', () {
      expect(report.length, 1);
    });
  });

  group('when provided with two dependencies with difference in dependency type only', () {
    final report = findInconsistentDependencies({
      'a1': const PubspecLock(packages: [_hostedDependencyAv1]),
      'a2': const PubspecLock(packages: [_hostedDependencyAv1Transitive]),
    });
    test('it provides empty report', () {
      expect(report, isEmpty);
    });
  });
}

const _hostedDependencyAv1 = PackageDependency.hosted(HostedPackageDependency(
  package: 'a',
  version: '1.0.0',
  name: 'a',
  url: 'https://pub.dartlang.org',
  type: DependencyType.direct,
));

const _hostedDependencyAv1Transitive = PackageDependency.hosted(HostedPackageDependency(
  package: 'a',
  version: '1.0.0',
  name: 'a',
  url: 'https://pub.dartlang.org',
  type: DependencyType.transitive,
));

const _hostedDependencyAv2 = PackageDependency.hosted(HostedPackageDependency(
  package: 'a',
  version: '2.0.0',
  name: 'a',
  url: 'https://pub.dartlang.org',
  type: DependencyType.development,
));

final _reportAv1Av2 = [
  //ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
  DependencyUsageReport<PackageDependency>(dependencyName: 'a', references: {
    // ignore: prefer_const_literals_to_create_immutables
    _hostedDependencyAv1: ['a1'],
    // ignore: prefer_const_literals_to_create_immutables
    _hostedDependencyAv2: ['a2'],
  })
];

const _pathDependencyAv1 = PackageDependency.path(PathPackageDependency(
  package: 'a',
  version: '0.0.1',
  path: '../package1',
  relative: true,
  type: DependencyType.direct,
));

const _pathDependencyAv2 = PackageDependency.path(PathPackageDependency(
  package: 'a',
  version: '0.0.2',
  path: '../../package1',
  relative: true,
  type: DependencyType.direct,
));
