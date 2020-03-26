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

import 'package:pubspec_lock/pubspec_lock.dart';

import 'package_usage_report.dart';

/// Finds inconsistent set of external dependencies in the provided set of pubspec.lock content and
/// generates report on inconsistent package usage.
/// As analysis focuses on consistency of external dependencies, consistency of path dependencies is ignored.
/// However, if a dependency is specified by mix of path and other dependencies types in different pubspec.lock files,
/// this case is reported as inconsistency.
List<PackageUsageReport> findInconsistentDependencies(Map<String, PubspecLock> pubspecLocks) {
  final dependencies = _collectAllDependencies(pubspecLocks);
  final externalDependencies = _filterOutPathOnlyDependencies(dependencies);
  final inconsistentDependencies = _filterOutConsistentDependencies(externalDependencies);
  final names = inconsistentDependencies.map((d) => d.package()).toSet();
  return names
      .map((name) => PackageUsageReport(
          dependencyName: name,
          references: Map.fromEntries(inconsistentDependencies
              .where((d) => d.package() == name)
              .map((d) => MapEntry(d, _referencesToDependency(d, pubspecLocks))))))
      .toList();
}

Set<PackageDependency> _collectAllDependencies(
  Map<String, PubspecLock> pubspecLocks,
) =>
    pubspecLocks.values.expand((pubspecLock) => pubspecLock.packages).toSet();

Iterable<PackageDependency> _filterOutPathOnlyDependencies(
  Set<PackageDependency> dependencies,
) =>
    dependencies.where((d) => dependencies
        .where((dd) => dd.package() == d.package())
        .any((dd) => dd.iswitcho(path: (_) => false, otherwise: () => true)));

Set<PackageDependency> _filterOutConsistentDependencies(
  Iterable<PackageDependency> externalDependencies,
) =>
    externalDependencies
        .where((d) => externalDependencies.where((dd) => dd.package() == d.package()).length > 1)
        .toSet();

List<String> _referencesToDependency(
  PackageDependency d,
  Map<String, PubspecLock> pubspecLocks,
) =>
    [
      for (final pubspecLock in pubspecLocks.entries) if (pubspecLock.value.packages.contains(d)) ...[pubspecLock.key]
    ];
