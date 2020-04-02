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
import 'package:meta/meta.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../file_finder.dart';
import '../options/exclude.dart';
import '../options/lock.dart';
import '../options/paths.dart';
import '../options/verbose.dart';
import '../options/yaml.dart';

// ignore_for_file: avoid_print

class ProbeCommand extends Command<void> {
  ProbeCommand() {
    addPubspecYamlFlag(argParser);
    addPubspecLockFlag(argParser);
    addPathsMultiOption(argParser);
    addExcludeMultiOption(argParser);
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
    final pubspecYamlLocations = _locatePubspecFiles(filename: 'pubspec.yaml');
    final pubspecYamls = Map.fromEntries(pubspecYamlLocations.map((location) => MapEntry(
          location,
          File(location).readAsStringSync().toPubspecYaml(),
        )));

    print('Analyzing dependency specifications...');
    final inconsistentSpecList = findInconsistentDependencySpecs(pubspecYamls);

    if (inconsistentSpecList.isNotEmpty) {
      _printDependencyUsageReport(
        report: inconsistentSpecList,
        formatDependency: _formatDependencySpec,
      );
      print('\nFAILURE: Inconsistent package dependency specifications detected!');
      exit(1);
    }
  }

  void _checkPubspecLockFiles() {
    final pubspecLockLocations = _locatePubspecFiles(filename: 'pubspec.lock');
    final pubspecLocks = Map.fromEntries(pubspecLockLocations.map((location) => MapEntry(
          location,
          File(location).readAsStringSync().loadPubspecLockFromYaml(),
        )));

    print('Analyzing dependencies...');
    final inconsistentUsageList = findInconsistentDependencies(pubspecLocks);

    if (inconsistentUsageList.isNotEmpty) {
      _printDependencyUsageReport(
        report: inconsistentUsageList,
        formatDependency: _formatDependencyInfo,
      );
      print('\nFAILURE: Inconsistent use of external dependencies detected!');
      exit(1);
    }
  }

  Iterable<String> _locatePubspecFiles({
    @required String filename,
  }) {
    print('==> Scanning for $filename files...');
    final pubspecFileLocations = _locationsToScan(filename);
    print('Found ${pubspecFileLocations.length} $filename files');
    if (getVerboseFlag(argResults)) {
      for (final loc in pubspecFileLocations) {
        print('\t$loc');
      }
    }

    if (pubspecFileLocations.isEmpty) {
      print('\nWARNING: No configuration files selected for analysis');
      exit(2);
    }

    return pubspecFileLocations;
  }

  Iterable<String> _locationsToScan(String filename) {
    final pubspecLockFinder = FileFinder(filename);
    final includedpubspecLockLocations = pubspecLockFinder.findFiles(getPathsMultiOption(argResults));
    final excludedPubspecLockLocations = pubspecLockFinder.findFiles(getExcludesMultiOption(argResults));
    return includedpubspecLockLocations.where((location) => !excludedPubspecLockLocations.contains(location));
  }
}

void _printDependencyUsageReport<DependencyType>({
  @required List<DependencyUsageReport<DependencyType>> report,
  @required String Function(DependencyType dependency) formatDependency,
}) {
  for (final use in report) {
    print('\n${use.dependencyName}: inconsistent dependency specifications detected');
    for (final dependency in use.references.keys) {
      print('\tVersion ${formatDependency(dependency)} is used by:');
      for (final user in use.references[dependency]) {
        print('\t\t$user');
      }
    }
  }
}

String _formatDependencySpec(PackageDependencySpec dependency) => dependency.iswitch(
    git: (dep) => '${dep.url}:${dep.ref}',
    path: (dep) => '${dep.path}',
    hosted: (dep) => '${dep.version}',
    sdk: (dep) => '${dep.version}');

String _formatDependencyInfo(PackageDependency dependency) => dependency.iswitcho(
      git: (dep) => '${dep.url}:${dep.resolvedRef}',
      path: (dep) => '${dep.path}',
      otherwise: () => '${dependency.version()}',
    );
