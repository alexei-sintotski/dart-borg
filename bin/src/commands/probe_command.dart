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

import 'package:args/command_runner.dart';
import 'package:borg/borg.dart';
import 'package:borg/src/configuration/configuration.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:borg/src/dart_package/dart_package.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_lock/pubspec_lock.dart';

import '../assert_pubspec_yaml_consistency.dart';
import '../options/lock.dart';
import '../options/verbose.dart';
import '../options/yaml.dart';
import '../scan_for_packages.dart';
import '../utils/borg_exception.dart';
import '../utils/print_dependency_usage_report.dart';

// ignore_for_file: avoid_print

class ProbeCommand extends Command<void> {
  ProbeCommand() {
    configurationFactory.populateConfigurationArgs(argParser);
    addPubspecYamlFlag(argParser);
    addPubspecLockFlag(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description =>
      'Checks consistency of Dart dependendencies across multiple packages';

  @override
  String get name => 'probe';

  @override
  void run() => exitWithMessageOnBorgException(action: _run, exitCode: 255);

  final BorgConfigurationFactory configurationFactory =
      BorgConfigurationFactory();
  BorgConfiguration configuration;
  Iterable<DartPackage> packages;

  void _run() {
    configuration =
        configurationFactory.createConfiguration(argResults: argResults);

    packages = scanForPackages(
      configuration: configuration,
      argResults: argResults,
    );

    if (getPubspecYamlFlag(argResults)) {
      _checkPubspecYamlFiles();
    } else {
      print('Analysis of pubspec.yaml files is skipped');
    }
    print('');
    if (getPubspecLockFlag(argResults)) {
      _checkPubspecLockFiles();
    } else {
      print('Analysis of pubspec.lock files is skipped');
    }
    if (getPubspecYamlFlag(argResults) || getPubspecLockFlag(argResults)) {
      print(
          '\nSUCCESS: All packages use consistent set of external dependencies');
    } else {
      throw const BorgException('FATAL: Nothing to do!');
    }
  }

  void _checkPubspecYamlFiles() {
    print('Analyzing dependency specifications...');
    assertPubspecYamlConsistency(packages);
  }

  void _checkPubspecLockFiles() {
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

    if (inconsistentUsageList.isNotEmpty) {
      printDependencyUsageReport(
        report: inconsistentUsageList,
        formatDependency: _formatDependencyInfo,
      );
      throw const BorgException(
          'FAILURE: Inconsistent use of external dependencies detected!');
    }
  }
}

String _formatDependencyInfo(PackageDependency dependency) =>
    dependency.iswitcho(
      git: (dep) => '${dep.url}:${dep.resolvedRef}',
      path: (dep) => '${dep.path}',
      otherwise: () => '${dependency.version()}',
    );
