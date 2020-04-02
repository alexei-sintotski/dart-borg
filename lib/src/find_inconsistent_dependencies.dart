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

import 'generic_dependency_usage_report.dart';

/// Finds inconsistent set of external dependencies in the provided set of pubspec.lock content and
/// generates report on inconsistent package usage.
/// As analysis focuses on consistency of external dependencies, consistency of path dependencies is ignored.
/// However, if a dependency is specified by mix of path and other dependencies types in different pubspec.lock files,
/// this case is reported as inconsistency.
List<DependencyUsageReport<PackageDependency>> findInconsistentDependencies(Map<String, PubspecLock> pubspecLocks) {
  final dependencies = _collectAllDependencies(pubspecLocks).toSet();
  final externalDependencies = _filterOutPathOnlyDependencies(dependencies).toSet();
  final normalizedDependencyMap = _normalizeDependencyType(externalDependencies);
  final normalizedDependencies = normalizedDependencyMap.keys.toSet();
  final inconsistentDependencies = _filterOutConsistentDependencies(normalizedDependencies).toSet();
  return _createReport(inconsistentDependencies, normalizedDependencyMap, pubspecLocks);
}

Iterable<PackageDependency> _collectAllDependencies(
  Map<String, PubspecLock> pubspecLocks,
) =>
    pubspecLocks.values.expand((pubspecLock) => pubspecLock.packages);

Iterable<PackageDependency> _filterOutPathOnlyDependencies(
  Iterable<PackageDependency> dependencies,
) =>
    dependencies.where((d) => dependencies
        .where((dd) => dd.package() == d.package())
        .any((dd) => dd.iswitcho(path: (_) => false, otherwise: () => true)));

Map<PackageDependency, PackageDependency> _normalizeDependencyType(Iterable<PackageDependency> dependencies) =>
    Map.fromEntries(dependencies.map((d) => MapEntry(
          d.iswitch(
            sdk: (dd) => PackageDependency.sdk(dd.copyWith(type: DependencyType.direct)),
            hosted: (dd) => PackageDependency.hosted(dd.copyWith(type: DependencyType.direct)),
            git: (dd) => PackageDependency.git(dd.copyWith(type: DependencyType.direct)),
            path: (dd) => PackageDependency.path(dd.copyWith(type: DependencyType.direct)),
          ),
          d,
        )));

Iterable<PackageDependency> _filterOutConsistentDependencies(
  Iterable<PackageDependency> externalDependencies,
) =>
    externalDependencies.where((d) => externalDependencies.where((dd) => dd.package() == d.package()).length > 1);

List<DependencyUsageReport<PackageDependency>> _createReport(
  Iterable<PackageDependency> dependencies,
  Map<PackageDependency, PackageDependency> normalizedDependencyMap,
  Map<String, PubspecLock> pubspecLocks,
) {
  final names = dependencies.map((d) => d.package()).toSet();
  return names
      .map((name) => DependencyUsageReport(
          dependencyName: name,
          references: Map.fromEntries(dependencies.where((d) => d.package() == name).map((d) => MapEntry(
                normalizedDependencyMap[d],
                _referencesToDependency(normalizedDependencyMap[d], pubspecLocks),
              )))))
      .toList();
}

List<String> _referencesToDependency(
  PackageDependency d,
  Map<String, PubspecLock> pubspecLocks,
) =>
    [
      for (final pubspecLock in pubspecLocks.entries) if (pubspecLock.value.packages.contains(d)) ...[pubspecLock.key]
    ];
