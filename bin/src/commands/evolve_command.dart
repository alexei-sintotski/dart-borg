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
import 'package:path/path.dart' as path;
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../options/dart_sdk.dart';
import '../options/dry_run.dart';
import '../options/exclude.dart';
import '../options/flutter_sdk.dart';
import '../options/paths.dart';
import '../options/verbose.dart';
import '../pub.dart';
import '../pubspec_yaml_functions.dart';
import '../utils/borg_exception.dart';
import '../utils/run_system_command.dart';
import '../utils/with_temp_location.dart';

// ignore_for_file: avoid_print

class EvolveCommand extends Command<void> {
  EvolveCommand() {
    addDryRunFlag(argParser);
    addPathsMultiOption(argParser);
    addExcludeMultiOption(argParser);
    addVerboseFlag(argParser);
    addDartSdkOption(argParser);
    addFlutterSdkOption(argParser);
  }

  @override
  String get description => 'Upgrade Dart dependencies across multiple packages';

  @override
  String get name => 'evolve';

  @override
  void run() => exitWithMessageOnBorgException(action: _run, exitCode: 255);

  void _run() {
    if (getDryRunFlag(argResults)) {
      print('DRY RUN: no existing pubspec.lock files are going to be modified\n');
    }

    final pubspecYamls = loadPubspecYamlFiles(argResults: argResults);
    assertPubspecYamlConsistency(pubspecYamls);

    final allExternalDepSpecs = getAllExternalPackageDependencySpecs(pubspecYamls.values);
    if (getVerboseFlag(argResults)) {
      _printDependencySpecs(allExternalDepSpecs);
    }

    final references = _computeConsistentDependencySet(allExternalDepSpecs);

    if (getDryRunFlag(argResults)) {
      print('\nDRY RUN: Previewing evolution of ${pubspecYamls.length} Dart packages...');
    } else {
      print('\nCommencing evolution of ${pubspecYamls.length} Dart packages...');
    }

    var i = 1;
    for (final entry in pubspecYamls.entries) {
      final packageLocation = path.dirname(entry.key);
      if (getDryRunFlag(argResults)) {
        stdout.write('[${i++}/${pubspecYamls.length}] ${path.absolute(packageLocation)}');
      } else {
        stdout.write('[${i++}/${pubspecYamls.length}] Evolving ${path.absolute(packageLocation)}...');
      }
      _evolvePackage(packageLocation, references);
    }

    if (getDryRunFlag(argResults)) {
      print('\nSUCCESS: ${pubspecYamls.length} packages have been analyzed');
    } else {
      print('\nSUCCESS: ${pubspecYamls.length} packages have been upgraded');
    }
  }

  Iterable<PackageDependency> _computeConsistentDependencySet(Iterable<PackageDependencySpec> directDepSpecs) =>
      withTempLocation(action: (location) {
        _createPackage(
          name: 'borg_evolve_temp',
          location: location,
          depSpecs: directDepSpecs,
        );
        print('\nResolving ${directDepSpecs.length} direct external dependencies...');
        _resolveDependencies(location);
        final resolvedDeps = _getResolvedDependencies(location: location);
        print('Resolved ${resolvedDeps.length} external dependencies');
        return resolvedDeps;
      });

  void _createPackage({
    @required String name,
    @required Directory location,
    @required Iterable<PackageDependencySpec> depSpecs,
  }) {
    if (getVerboseFlag(argResults)) {
      print('\nCreating temporary package at ${location.path}');
    }
    File(path.join(location.path, 'pubspec.yaml')).writeAsStringSync(PubspecYaml(
      name: name,
      dependencies: depSpecs,
    ).toYamlString());
  }

  void _resolveDependencies(Directory location) {
    final result = runSystemCommand(
      command: '${pub(argResults)} get',
      workingDirectory: location,
      environment: pubEnvironment(argResults),
    );
    if (result.exitCode != 0 || getVerboseFlag(argResults)) {
      print(result.stdout);
      print(result.stderr);
    }
    if (result.exitCode != 0) {
      throw const BorgException('FAILURE: pub get failed');
    }
  }

  void _evolvePackage(
    String packageLocation,
    Iterable<PackageDependency> references,
  ) {
    final pubspecLockFile = File(path.join(packageLocation, 'pubspec.lock'));
    if (!pubspecLockFile.existsSync()) {
      if (getVerboseFlag(argResults)) {
        print('\npubspec.lock does not exist, resolving dependencies...');
      }
      _resolveDependencies(Directory(packageLocation));
    }
    final pubspecLock = pubspecLockFile.readAsStringSync().loadPubspecLockFromYaml();
    final depsCorrectionSet = computePackageDependencyCorrection(pubspecLock.packages, references);
    if (depsCorrectionSet.isNotEmpty && !getDryRunFlag(argResults)) {
      final correctedPubspecLock = pubspecLock.copyWith(
        packages: copyWithPackageDependenciesFromReference(pubspecLock.packages, references),
      );
      pubspecLockFile.writeAsStringSync(correctedPubspecLock.toYamlString());
      _resolveDependencies(Directory(packageLocation));
    }
    if (getVerboseFlag(argResults) || getDryRunFlag(argResults)) {
      _printDependencyCorrections(actualDependencies: pubspecLock.packages, correctionSet: depsCorrectionSet);
    }
  }
}

void _printDependencySpecs(Iterable<PackageDependencySpec> deps) {
  print('Identified ${deps.length} direct external dependencies:');
  for (final dep in deps.toList()..sort((a, b) => a.package().compareTo(b.package()))) {
    print('\t${dep.package()}${_printDependencySpecDetail(dep)}');
  }
}

String _printDependencySpecDetail(PackageDependencySpec dep) => dep.iswitch(
      hosted: (dep) => dep.version.iif(
        some: (v) => ': $v',
        none: () => '',
      ),
      sdk: (dep) => ': ${dep.sdk} SDK',
      git: (dep) => ': ${dep.url}',
      path: (_) => '',
    );

Iterable<PackageDependency> _getResolvedDependencies({@required Directory location}) =>
    File(path.join(location.path, 'pubspec.lock')).readAsStringSync().loadPubspecLockFromYaml().packages;

void _printDependencyCorrections({
  @required Iterable<PackageDependency> actualDependencies,
  @required Iterable<PackageDependency> correctionSet,
}) {
  if (correctionSet.isEmpty) {
    print(' => package is UP-TO-DATE');
  } else {
    print(' => package upgrade is available:');
    for (final correction in correctionSet.toList()..sort((a, b) => a.package().compareTo(b.package()))) {
      final orgDep = actualDependencies.firstWhere((d) => d.package() == correction.package());
      print('\t${correction.package()}: ${_formatDependencyDetail(orgDep)} => ${_formatDependencyDetail(correction)}');
    }
  }
}

String _formatDependencyDetail(PackageDependency dep) => dep.iswitch(
      sdk: (d) => '${d.version}',
      hosted: (d) => '${d.version}',
      git: (d) => '${d.url}:${d.resolvedRef}',
      path: (d) => '${d.path}',
    );
