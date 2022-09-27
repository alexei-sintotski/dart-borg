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

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:borg/src/dart_package/dart_package.dart';
import 'package:borg/src/find_circular_dependencies.dart';
import 'package:borg/src/find_inconsistent_dependencies.dart';
import 'package:meta/meta.dart';
import 'package:pubspec_lock/pubspec_lock.dart';

import '../assert_pubspec_yaml_consistency.dart';
import '../options/correct.dart';
import '../options/lock.dart';
import '../options/pick_most_used.dart';
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
    ).toList(growable: false);

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
    final pubspecLocks = Map.fromEntries(
      packages
          .where(
            (package) =>
                package.pubspecLockFile.existsSync() &&
                [FileSystemEntityType.file]
                    .contains(package.pubspecLockFile.statSync().type),
          )
          .map(
            (package) => MapEntry(
              package,
              package.pubspecLockFile
                  .readAsStringSync()
                  .loadPubspecLockFromYaml(),
            ),
          ),
    );

    print('Analyzing dependencies...');
    final inconsistentUsageList = findInconsistentDependencies(pubspecLocks);
    final circularDependenciesReport =
        findCircularDependencies(pubspecLocks).toList();

    if (inconsistentUsageList.isNotEmpty && getCorrectFlag(argResults)) {
      correctPackageDependencyBasedOnReport(
        report: inconsistentUsageList,
        pickMostUsed: getPickMostUsedFlag(argResults),
      );
    } else {
      if (inconsistentUsageList.isNotEmpty) {
        printInconsistentDependencyUsageReport(
          report: inconsistentUsageList,
          formatDependency: _formatDependencyInfo,
        );
      }

      if (circularDependenciesReport.isNotEmpty) {
        printCircularDependencyUsageReport(
          report: circularDependenciesReport,
          formatDependency: _formatDependencyInfo,
        );
      }

      if (inconsistentUsageList.isNotEmpty ||
          circularDependenciesReport.isNotEmpty) {
        throw BorgException(
          'FAILURE: Inconsistent use of (external) dependencies detected!',
          supportMessage: inconsistentUsageList.isNotEmpty
              ? 'FAILURE: '
                  'Inconsistent use of external dependencies detected!\n'
                  'Consider using the --correct and --pick-most-used options '
                  'to fix issues.'
              : null,
        );
      }
    }
  }
}

String _formatDependencyInfo(PackageDependency dependency) =>
    dependency.iswitcho(
      git: (dep) => '${dep.url}:${dep.resolvedRef}',
      path: (dep) => dep.path,
      otherwise: () => dependency.version(),
    );
