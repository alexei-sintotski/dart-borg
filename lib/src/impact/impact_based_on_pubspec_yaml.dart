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

// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:plain_optional/plain_optional.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../dart_package/dart_package.dart';
import '../utils/file_io.dart';

extension _Package on DartPackage {
  bool productionCodeDependsOn(
    DartPackage package,
    Iterable<DartPackage> allPackagesInScope,
    Optional<String> Function(String) tryToReadFileSync,
  ) =>
      pubspecYaml.dependencies
          .map((d) => _overrideDependency(d, pubspecYaml.dependencyOverrides))
          .any((dep) => dep.iswitcho(
                path: (pathDep) =>
                    package.path == path.canonicalize(path.join(this.path, pathDep.path)) ||
                    allPackagesInScope
                        .firstWhere(
                          (p) => p.path == path.canonicalize(path.join(this.path, pathDep.path)),
                          orElse: () => DartPackage(
                            path: path.canonicalize(path.join(this.path, pathDep.path)),
                            tryToReadFileSync: tryToReadFileSync,
                          ),
                        )
                        .productionCodeDependsOn(package, allPackagesInScope, tryToReadFileSync),
                otherwise: () => false,
              ));

  bool devCodeDependsOn(
    DartPackage package,
    Iterable<DartPackage> allPackages,
  ) =>
      pubspecYaml.devDependencies
          .map((d) => _overrideDependency(d, pubspecYaml.dependencyOverrides))
          .any((dep) => dep.iswitcho(
                path: (pathDep) => package.path == path.canonicalize(path.join(this.path, pathDep.path)),
                otherwise: () => false,
              ));
}

PackageDependencySpec _overrideDependency(
  PackageDependencySpec d,
  Iterable<PackageDependencySpec> dependencyOverrides,
) =>
    dependencyOverrides.firstWhere(
      (override) => d.package() == override.package(),
      orElse: () => d,
    );

Iterable<DartPackage> impactBasedOnPubspecYaml({
  @required Iterable<DartPackage> packages,
  @required Iterable<DartPackage> allPackagesInScope,
  Optional<String> Function(String) tryToReadFileSync = tryToReadFileSync,
}) =>
    packages
        .expand((package) => allPackagesInScope.where((p) =>
            p.path == package.path ||
            p.productionCodeDependsOn(package, allPackagesInScope, tryToReadFileSync) ||
            p.devCodeDependsOn(package, allPackagesInScope)))
        .toSet();
