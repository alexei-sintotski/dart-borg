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

import 'dart:io';

import 'package:args/args.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:borg/src/dart_package/dart_package.dart';
import 'package:borg/src/find_inconsistent_dependencies.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:pubspec_lock/src/pubspec_lock.dart';

import '../assert_pubspec_yaml_consistency.dart';
import '../options/correct.dart';
import '../options/lock.dart';
import '../options/yaml.dart';
import '../scan_for_packages.dart';
import '../utils/borg_exception.dart';
import '../utils/correct_package_dependency.dart';
import '../utils/print_dependency_usage_report.dart';

@immutable
class ProbeCommandRunner {
  const ProbeCommandRunner(this.configurationFactory, this.argResults);

  final BorgConfigurationFactory configurationFactory;
  final ArgResults argResults;

  void run() {
    final configuration =
        configurationFactory.createConfiguration(argResults: argResults);

    final packages = scanForPackages(
      configuration: configuration,
      argResults: argResults,
    );

    if (getPubspecYamlFlag(argResults)) {
      _checkPubspecYamlFiles(packages);
    } else {
      print('Analysis of pubspec.yaml files is skipped');
    }
    print('');
    if (getPubspecLockFlag(argResults)) {
      _checkPubspecLockFiles(packages);
    } else {
      print('Analysis of pubspec.lock files is skipped');
    }
    if (getPubspecYamlFlag(argResults) || getPubspecLockFlag(argResults)) {
      print(
        '\nSUCCESS: All packages use consistent set of external dependencies',
      );
    } else {
      throw const BorgException('FATAL: Nothing to do!');
    }
  }

  void _checkPubspecYamlFiles(Iterable<DartPackage> packages) {
    print('Analyzing dependency specifications...');
    assertPubspecYamlConsistency(packages);
  }

  void _checkPubspecLockFiles(Iterable<DartPackage> packages) {
    final pubspecLocks = Map.fromEntries(packages
        .map((p) => File(path.join(p.path, 'pubspec.lock')))
        .where((f) =>
            f.existsSync() &&
            [FileSystemEntityType.file].contains(f.statSync().type))
        .map((f) => MapEntry(
              f.path,
              f.readAsStringSync().loadPubspecLockFromYaml(),
            )));

    print('Analyzing dependencies...');
    final inconsistentUsageList = findInconsistentDependencies(pubspecLocks);

    if (inconsistentUsageList.isNotEmpty && getCorrectFlag(argResults)) {
      correctPackageDependencyBasedOnReport(report: inconsistentUsageList);
    } else if (inconsistentUsageList.isNotEmpty) {
      printDependencyUsageReport(
        report: inconsistentUsageList,
        formatDependency: _formatDependencyInfo,
      );
      throw const BorgException(
        'FAILURE: Inconsistent use of external dependencies detected!\n'
        '         Consider to use the --correct option to fix issues.',
      );
    }
  }
}

String _formatDependencyInfo(PackageDependency dependency) =>
    dependency.iswitcho(
      git: (dep) => '${dep.url}:${dep.resolvedRef}',
      path: (dep) => dep.path,
      otherwise: () => dependency.version(),
    );
