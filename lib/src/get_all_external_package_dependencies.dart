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

import 'package:pubspec_lock/pubspec_lock.dart';

/// This function returns all external package dependencies used in collection
/// of pubspec.lock files.
///
Iterable<PackageDependency> getAllExternalPackageDependencies(
  Iterable<PubspecLock> pubspecLocks,
) {
  final dependencies = _collectAllDependencies(pubspecLocks).toSet();
  final externalDependencies =
      _filterOutPathOnlyDependencies(dependencies).toSet();
  return _normalizeDependencyType(externalDependencies).toSet();
}

Iterable<PackageDependency> _collectAllDependencies(
  Iterable<PubspecLock> pubspecLocks,
) =>
    pubspecLocks.expand((pubspecLock) => pubspecLock.packages);

Iterable<PackageDependency> _filterOutPathOnlyDependencies(
  Iterable<PackageDependency> dependencies,
) =>
    dependencies.where((d) => dependencies
        .where((dd) => dd.package() == d.package())
        .any((dd) => dd.iswitcho(path: (_) => false, otherwise: () => true)));

Iterable<PackageDependency> _normalizeDependencyType(
  Iterable<PackageDependency> dependencies,
) =>
    dependencies.map(
      (d) => d.iswitch(
        sdk: (dd) => PackageDependency.sdk(
          dd.copyWith(type: DependencyType.direct),
        ),
        hosted: (dd) => PackageDependency.hosted(
          dd.copyWith(type: DependencyType.direct),
        ),
        git: (dd) => PackageDependency.git(
          dd.copyWith(type: DependencyType.direct),
        ),
        path: (dd) => PackageDependency.path(
          dd.copyWith(type: DependencyType.direct),
        ),
      ),
    );
