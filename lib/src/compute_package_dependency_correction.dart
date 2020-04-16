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

Iterable<PackageDependency> computePackageDependencyCorrection(
  Iterable<PackageDependency> deps,
  Iterable<PackageDependency> references,
) =>
    references
        .map((ref) => _correctDependencyType(ref, deps))
        .where((ref) => deps.any((dep) => dep.package() == ref.package() && dep != ref));

PackageDependency _correctDependencyType(
  PackageDependency ref,
  Iterable<PackageDependency> deps,
) =>
    ref.iswitch(
      sdk: (r) => PackageDependency.sdk(
          r.copyWith(type: deps.firstWhere((d) => d.package() == r.package, orElse: () => ref).type())),
      hosted: (r) => PackageDependency.hosted(
          r.copyWith(type: deps.firstWhere((d) => d.package() == r.package, orElse: () => ref).type())),
      git: (r) => PackageDependency.git(
          r.copyWith(type: deps.firstWhere((d) => d.package() == r.package, orElse: () => ref).type())),
      path: (r) => PackageDependency.path(
          r.copyWith(type: deps.firstWhere((d) => d.package() == r.package, orElse: () => ref).type())),
    );
