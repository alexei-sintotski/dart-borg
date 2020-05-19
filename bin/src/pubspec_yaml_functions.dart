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

import 'dart:io';

import 'package:args/args.dart';
import 'package:borg/borg.dart';
import 'package:borg/src/configuration/configuration.dart';
import 'package:meta/meta.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import 'locate_pubspec_files.dart';
import 'utils/print_dependency_usage_report.dart';

// ignore_for_file: avoid_print

Map<String, PubspecYaml> loadPubspecYamlFiles({
  @required BorgConfiguration configuration,
  @required ArgResults argResults,
}) {
  final pubspecYamlLocations = locatePubspecFiles(
    filename: 'pubspec.yaml',
    configuration: configuration,
    argResults: argResults,
  );
  final pubspecYamls = Map.fromEntries(pubspecYamlLocations.map((location) => MapEntry(
        location,
        File(location).readAsStringSync().toPubspecYaml(),
      )));
  return pubspecYamls;
}

void assertPubspecYamlConsistency(Map<String, PubspecYaml> pubspecYamls) {
  final inconsistentSpecList = findInconsistentDependencySpecs(pubspecYamls);

  if (inconsistentSpecList.isNotEmpty) {
    printDependencyUsageReport(
      report: inconsistentSpecList,
      formatDependency: _formatDependencySpec,
    );
    print('\nFAILURE: Inconsistent package dependency specifications detected!');
    exit(1);
  }
}

String _formatDependencySpec(PackageDependencySpec dependency) => dependency.iswitch(
    git: (dep) => '${dep.url}${dep.ref.iif(some: (v) => ": $v", none: () => "")}',
    path: (dep) => '${dep.path}',
    hosted: (dep) => '${dep.version.valueOr(() => "unspecified")}',
    sdk: (dep) => '${dep.version.valueOr(() => "unspecified")}');
