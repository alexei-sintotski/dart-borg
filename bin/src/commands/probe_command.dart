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
import 'package:borg/src/configuration/factory.dart';
import 'package:pubspec_lock/pubspec_lock.dart';

import '../locate_pubspec_files.dart';
import '../options/lock.dart';
import '../options/verbose.dart';
import '../options/yaml.dart';
import '../pubspec_yaml_functions.dart';
import '../utils/print_dependency_usage_report.dart';

// ignore_for_file: avoid_print

class ProbeCommand extends Command<void> {
  ProbeCommand() {
    populateConfigurationArgs(argParser);
    addPubspecYamlFlag(argParser);
    addPubspecLockFlag(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description => 'Checks consistency of Dart dependendencies across multiple packages';

  @override
  String get name => 'probe';

  @override
  void run() {
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
      print('\nSUCCESS: All packages use consistent set of external dependencies');
    } else {
      print('\nWARNING: Nothing to do!');
      exit(2);
    }
  }

  void _checkPubspecYamlFiles() {
    final pubspecYamls = loadPubspecYamlFiles(argResults: argResults);
    print('Analyzing dependency specifications...');
    assertPubspecYamlConsistency(pubspecYamls);
  }

  void _checkPubspecLockFiles() {
    final pubspecLockLocations = locatePubspecFiles(filename: 'pubspec.lock', argResults: argResults);
    final pubspecLocks = Map.fromEntries(pubspecLockLocations.map((location) => MapEntry(
          location,
          File(location).readAsStringSync().loadPubspecLockFromYaml(),
        )));

    print('Analyzing dependencies...');
    final inconsistentUsageList = findInconsistentDependencies(pubspecLocks);

    if (inconsistentUsageList.isNotEmpty) {
      printDependencyUsageReport(
        report: inconsistentUsageList,
        formatDependency: _formatDependencyInfo,
      );
      print('\nFAILURE: Inconsistent use of external dependencies detected!');
      exit(1);
    }
  }
}

String _formatDependencyInfo(PackageDependency dependency) => dependency.iswitcho(
      git: (dep) => '${dep.url}:${dep.resolvedRef}',
      path: (dep) => '${dep.path}',
      otherwise: () => '${dependency.version()}',
    );
