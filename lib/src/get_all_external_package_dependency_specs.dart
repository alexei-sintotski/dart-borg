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

import 'package:pubspec_yaml/pubspec_yaml.dart';

/// This function returns all package dependency specifications used in a
/// collection of pubspec.yaml files.
///
/// Package dependency overrides are taken into account.
///
Iterable<PackageDependencySpec> getAllExternalPackageDependencySpecs(
        Iterable<PubspecYaml> pubspecYamls) =>
    _filterOutRedundantHostedSpecs(
      {
        for (final pubspecYaml in pubspecYamls)
          ..._getDependencySpecs(pubspecYaml),
      }.where(_isExternal),
    );

bool _isExternal(PackageDependencySpec dep) =>
    dep.iswitcho(path: (_) => false, otherwise: () => true);

Set<PackageDependencySpec> _getDependencySpecs(PubspecYaml pubspecYaml) => {
      ...pubspecYaml.dependencies,
      ...pubspecYaml.devDependencies,
    }.map((dep) => _correctForOverride(dep, pubspecYaml)).toSet();

PackageDependencySpec _correctForOverride(
        PackageDependencySpec dep, PubspecYaml pubspecYaml) =>
    pubspecYaml.dependencyOverrides
        .firstWhere((d) => d.package() == dep.package(), orElse: () => dep);

Iterable<PackageDependencySpec> _filterOutRedundantHostedSpecs(
        Iterable<PackageDependencySpec> specs) =>
    specs.where((s) => s.iswitcho(
          hosted: (hs) =>
              hs.version.hasValue ||
              specs
                  .where((s) => s.package() == hs.package)
                  .every((s) => s.iswitcho(
                        hosted: (h) => !h.version.hasValue,
                        otherwise: () => true,
                      )),
          otherwise: () => true,
        ));
