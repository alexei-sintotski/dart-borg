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

import 'package:borg/borg.dart';
import 'package:borg/src/dart_package/dart_package.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import 'utils/borg_exception.dart';
import 'utils/print_dependency_usage_report.dart';
import 'utils/render_package_name.dart';

// ignore_for_file: avoid_print

void assertPubspecYamlConsistency(Iterable<DartPackage> packages) {
  final inconsistentSpecList = findInconsistentDependencySpecs(
      Map.fromEntries(packages.map((p) => MapEntry(
            renderPackageName(p.path),
            p.pubspecYaml,
          ))));

  if (inconsistentSpecList.isNotEmpty) {
    printDependencyUsageReport(
      report: inconsistentSpecList,
      formatDependency: _formatDependencySpec,
    );

    throw const BorgException(
        'FAILURE: Inconsistent package dependency specifications detected!');
  }
}

String _formatDependencySpec(PackageDependencySpec dependency) =>
    dependency.iswitch(
      git: (dep) => '${dep.url}${dep.ref.iif(
        some: (v) => ": $v",
        none: () => "",
      )}',
      path: (dep) => dep.path,
      hosted: (dep) => dep.version.valueOr(() => 'unspecified'),
      sdk: (dep) => dep.version.valueOr(() => 'unspecified'),
    );
