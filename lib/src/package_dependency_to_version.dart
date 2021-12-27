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

/// This function sets a [dependency] to a specific [toVersion] by adjusting
/// every pubspecLock found in the [inPubspecLocks] list. Returns the altered
/// list.
///
Map<String, PubspecLock> packageDependencyToVersion({
  required PackageDependency dependency,
  required String toVersion,
  required Map<String, PubspecLock> inPubspecLocks,
}) {
  if (dependency.version() == toVersion) {
    return inPubspecLocks;
  }

  final newPackageDependency = dependency.iswitch<PackageDependency>(
    sdk: (sdk) => PackageDependency.sdk(
      sdk.copyWith(version: toVersion),
    ),
    hosted: (hosted) => PackageDependency.hosted(
      hosted.copyWith(version: toVersion),
    ),
    git: (git) => PackageDependency.git(
      git.copyWith(version: toVersion),
    ),
    path: (path) => PackageDependency.path(
      path.copyWith(version: toVersion),
    ),
  );

  return inPubspecLocks.map(
    (path, pubspecLock) {
      final packages = pubspecLock.packages.toList();
      final replacementIndex = packages.indexWhere(
        (p) => p.package() == dependency.package(),
      );
      packages[replacementIndex] = newPackageDependency;
      return MapEntry(path, pubspecLock.copyWith(packages: packages));
    },
  );
}
