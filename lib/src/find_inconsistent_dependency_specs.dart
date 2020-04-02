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

import 'package:pubspec_yaml/pubspec_yaml.dart';

import 'generic_dependency_usage_report.dart';

/// Finds inconsistent set of external dependency specifications in the provided set of pubspec.yaml content and
/// generates report on inconsistent references.
/// As analysis focuses on consistency of external dependencies, consistency of path dependencies is ignored.
/// However, if a dependency is specified by a mix of path and other dependency types in different pubspec.yaml files,
/// this case is reported as inconsistency.
///
List<DependencyUsageReport<PackageDependencySpec>> findInconsistentDependencySpecs(
    Map<String, PubspecYaml> pubspecYamls) {
  final specsPerPubspecYaml = _collectAllDepSpecsPerPubspecYaml(pubspecYamls);

  final allSpecs = _collectAllDepSpecs(specsPerPubspecYaml);
  final externalSpecs = _filterOutPathOnlySpecs(allSpecs).toSet();
  final inconsistentSpecs = _filterOutSingularReferences(externalSpecs);
  return _createReport(inconsistentSpecs, specsPerPubspecYaml);
}

Map<String, Set<PackageDependencySpec>> _collectAllDepSpecsPerPubspecYaml(Map<String, PubspecYaml> pubspecYamls) =>
    Map.fromEntries(pubspecYamls.keys.map((k) => MapEntry(k, _getDependencySpecs(pubspecYamls[k]))));

Set<PackageDependencySpec> _collectAllDepSpecs(Map<String, Set<PackageDependencySpec>> specsPerPubspecYaml) => {
      for (final k in specsPerPubspecYaml.keys) ...specsPerPubspecYaml[k],
    };

Set<PackageDependencySpec> _getDependencySpecs(PubspecYaml pubspecYaml) => {
      ...pubspecYaml.dependencies,
      ...pubspecYaml.devDependencies
    }.map((dep) => _correctForOverride(dep, pubspecYaml)).toSet();

PackageDependencySpec _correctForOverride(PackageDependencySpec dep, PubspecYaml pubspecYaml) =>
    pubspecYaml.dependencyOverrides.firstWhere((d) => d.package() == dep.package(), orElse: () => dep);

Iterable<PackageDependencySpec> _filterOutPathOnlySpecs(Iterable<PackageDependencySpec> allSpecs) =>
    allSpecs.where((spec) => allSpecs
        .where((s) => s.package() == spec.package())
        .any((spec) => spec.iswitcho(path: (_) => false, otherwise: () => true)));

Iterable<PackageDependencySpec> _filterOutSingularReferences(Iterable<PackageDependencySpec> allSpecs) =>
    allSpecs.where((s) => allSpecs.where((ss) => s.package() == ss.package()).length > 1);

List<DependencyUsageReport<PackageDependencySpec>> _createReport(
  Iterable<PackageDependencySpec> specs,
  Map<String, Iterable<PackageDependencySpec>> specsPerPubspecYaml,
) {
  final names = specs.map((d) => d.package()).toSet();
  return names
      .map((name) => DependencyUsageReport(
          dependencyName: name,
          references: Map.fromEntries(specs.where((d) => d.package() == name).map((d) => MapEntry(
                d,
                _referencesToDependency(d, specsPerPubspecYaml),
              )))))
      .toList();
}

List<String> _referencesToDependency(
  PackageDependencySpec depSpec,
  Map<String, Iterable<PackageDependencySpec>> specsPerPubspecYaml,
) =>
    [
      for (final entry in specsPerPubspecYaml.entries) if (entry.value.contains(depSpec)) ...[entry.key]
    ];
