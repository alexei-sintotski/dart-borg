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

/// Given the collections of actual package dependencies (deps) and the
/// reference dependencies (references), this function copies deps and for every
/// dependency version different from references, it takes the one from
/// references.
///
/// This function is intended to correct package configuration to make it
/// consistent with other packages in a Dart mono repository.
///
Iterable<PackageDependency> copyWithPackageDependenciesFromReference(
  Iterable<PackageDependency> deps,
  Iterable<PackageDependency> references,
) =>
    deps.map(
      (dep) => references
          .firstWhere(
            (ref) => ref.package() == dep.package(),
            orElse: () => dep,
          )
          .iswitch(
            sdk: (d) => PackageDependency.sdk(d.copyWith(type: dep.type())),
            hosted: (d) =>
                PackageDependency.hosted(d.copyWith(type: dep.type())),
            git: (d) => PackageDependency.git(d.copyWith(type: dep.type())),
            path: (d) => PackageDependency.path(d.copyWith(type: dep.type())),
          ),
    );
