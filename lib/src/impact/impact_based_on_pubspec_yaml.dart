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

// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:plain_optional/plain_optional.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../dart_package/dart_package.dart';
import '../utils/file_io.dart';

Iterable<DartPackage> impactBasedOnPubspecYaml({
  @required Iterable<DartPackage> packages,
  @required Iterable<DartPackage> allPackagesInScope,
  Optional<String> Function(String) tryToReadFileSync = tryToReadFileSync,
}) {
  final productImpactResolver = _ProductImpactResolver(
    allPackagesInScope: allPackagesInScope,
    tryToReadFileSync: tryToReadFileSync,
  );
  final devImpactResolver = _DevImpactResolver(
    allPackagesInScope: allPackagesInScope,
    tryToReadFileSync: tryToReadFileSync,
  );
  return packages
      .expand(productImpactResolver.impact)
      .toSet()
      .union(packages.expand(devImpactResolver.impact).toSet());
}

class _ProductImpactResolver {
  _ProductImpactResolver({
    @required Iterable<DartPackage> allPackagesInScope,
    @required Optional<String> Function(String) tryToReadFileSync,
  }) : _impactMap = _createImpactMap(
          allPackagesInScope: allPackagesInScope,
          tryToReadFileSync: tryToReadFileSync,
        );

  Set<DartPackage> impact(DartPackage package) =>
      _impactMap.containsKey(package) ? _impactMap[package] : {};

  final Map<DartPackage, Set<DartPackage>> _impactMap;

  static Map<DartPackage, Set<DartPackage>> _createImpactMap({
    @required Iterable<DartPackage> allPackagesInScope,
    Optional<String> Function(String) tryToReadFileSync = tryToReadFileSync,
  }) {
    final impactMap = _createInitialImpactMap(allPackagesInScope);
    _inflateDirectDependencies(allPackagesInScope,
        (p) => p.pubspecYaml.dependencies, impactMap, tryToReadFileSync);
    _growTransitiveDependencies(impactMap);
    return impactMap;
  }
}

class _DevImpactResolver {
  _DevImpactResolver({
    @required Iterable<DartPackage> allPackagesInScope,
    @required Optional<String> Function(String) tryToReadFileSync,
  }) : _impactMap = _createImpactMap(
          allPackagesInScope: allPackagesInScope,
          tryToReadFileSync: tryToReadFileSync,
        );

  Set<DartPackage> impact(DartPackage package) =>
      _impactMap.containsKey(package) ? _impactMap[package] : {};

  final Map<DartPackage, Set<DartPackage>> _impactMap;

  static Map<DartPackage, Set<DartPackage>> _createImpactMap({
    @required Iterable<DartPackage> allPackagesInScope,
    Optional<String> Function(String) tryToReadFileSync = tryToReadFileSync,
  }) {
    final impactMap = _createInitialImpactMap(allPackagesInScope);
    _inflateDirectDependencies(allPackagesInScope,
        (p) => p.pubspecYaml.devDependencies, impactMap, tryToReadFileSync);
    return impactMap;
  }
}

Map<DartPackage, Set<DartPackage>> _createInitialImpactMap(
        Iterable<DartPackage> allPackagesInScope) =>
    <DartPackage, Set<DartPackage>>{
      for (final p in allPackagesInScope) ...{
        p: {p}
      }
    };

void _inflateDirectDependencies(
  Iterable<DartPackage> allPackagesInScope,
  Iterable<PackageDependencySpec> Function(DartPackage) dependencies,
  Map<DartPackage, Set<DartPackage>> impactMap,
  Optional<String> Function(String) tryToReadFileSync,
) {
  for (final package in allPackagesInScope) {
    _populateDirectDependencies(
      package,
      dependencies,
      impactMap,
      tryToReadFileSync,
    );
  }
}

void _populateDirectDependencies(
  DartPackage package,
  Iterable<PackageDependencySpec> Function(DartPackage) dependencies,
  Map<DartPackage, Set<DartPackage>> impactMap,
  Optional<String> Function(String) tryToReadFileSync,
) {
  for (final d in dependencies(package)
      .map((p) =>
          _overrideDependency(p, package.pubspecYaml.dependencyOverrides))
      .where(_isPathDependency)) {
    final dp = d.iswitcho(
      path: (pathDep) => impactMap.keys.firstWhere(
          (pp) =>
              pp.path ==
              path.canonicalize(path.join(package.path, pathDep.path)),
          orElse: () => DartPackage(
                path: path.canonicalize(path.join(package.path, pathDep.path)),
                tryToReadFileSync: tryToReadFileSync,
              )),
      otherwise: () => null,
    );
    if (impactMap.containsKey(dp)) {
      impactMap[dp].add(package);
    } else {
      impactMap[dp] = {dp};
      _populateDirectDependencies(
          dp, dependencies, impactMap, tryToReadFileSync);
    }
  }
}

void _growTransitiveDependencies(
  Map<DartPackage, Set<DartPackage>> impactMap,
) {
  var previousFingerprint = <DartPackage, int>{};
  var currentFingerprint = _fingerprint(impactMap);
  while (!const DeepCollectionEquality.unordered()
      .equals(previousFingerprint, currentFingerprint)) {
    previousFingerprint = currentFingerprint;
    for (final package in impactMap.keys) {
      final totalImpact = {
        for (final impactedPackage in impactMap[package])
          ...impactMap[impactedPackage]
      };
      impactMap[package] = totalImpact;
    }
    currentFingerprint = _fingerprint(impactMap);
  }
}

Map<DartPackage, int> _fingerprint(
        Map<DartPackage, Set<DartPackage>> impactMap) =>
    impactMap.map((p, d) => MapEntry(p, d.length));

PackageDependencySpec _overrideDependency(
  PackageDependencySpec d,
  Iterable<PackageDependencySpec> dependencyOverrides,
) =>
    dependencyOverrides.firstWhere(
      (override) => d.package() == override.package(),
      orElse: () => d,
    );

bool _isPathDependency(PackageDependencySpec d) =>
    d.iswitcho(path: (_) => true, otherwise: () => false);
