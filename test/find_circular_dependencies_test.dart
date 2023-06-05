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

import 'package:borg/src/find_circular_dependencies.dart';
import 'package:borg/src/generic_dependency_usage_report.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

import 'dart_package_utils.dart';

void main() {
  final packageA = dartPackage('a');
  final packageB = dartPackage('b');
  final packageC = dartPackage('c');

  const dependencyToA = PackageDependency.path(
    PathPackageDependency(
      package: 'a',
      version: '1',
      path: '/',
      relative: true,
      type: DependencyType.direct,
    ),
  );

  const dependencyToB = PackageDependency.path(
    PathPackageDependency(
      package: 'b',
      version: '1',
      path: '/',
      relative: true,
      type: DependencyType.direct,
    ),
  );

  group('when the provided list contains a circular dependencies', () {
    final report = findCircularDependencies({
      packageA: const PubspecLock(
        packages: [dependencyToB],
      ),
      packageB: const PubspecLock(
        packages: [dependencyToA],
      ),
      packageC: const PubspecLock(
        packages: [dependencyToA],
      ),
    }).toList();

    test('then all circular dependencies are reported', () {
      expect(
        report,
        equals([
          DependencyUsageReport<PackageDependency>(
            dependencyName: packageA.pubspecYaml.name,
            references: {
              dependencyToB: const ['a']
            },
          ),
          DependencyUsageReport<PackageDependency>(
            dependencyName: packageB.pubspecYaml.name,
            references: {
              dependencyToA: const ['b']
            },
          ),
        ]),
      );
    });
  });

  group('when the provided list contains no circular dependencies', () {
    final report = findCircularDependencies({
      packageA: const PubspecLock(
        packages: [],
      ),
      packageB: const PubspecLock(
        packages: [dependencyToA],
      ),
      packageC: const PubspecLock(
        packages: [dependencyToA],
      ),
    }).toList();

    test('then no circular dependencies are reported', () {
      expect(report, const <DependencyUsageReport<PackageDependency>>[]);
    });
  });
}
