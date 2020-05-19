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
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../options/dry_run.dart';
import '../options/verbose.dart';
import '../pub.dart';
import '../pubspec_yaml_functions.dart';
import '../utils/borg_exception.dart';
import '../utils/run_system_command.dart';
import '../utils/with_temp_location.dart';

// ignore_for_file: avoid_print

class EvolveCommand extends Command<void> {
  EvolveCommand() {
    populateConfigurationArgs(argParser);
    addDryRunFlag(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description => 'Upgrade Dart dependencies consistently across multiple packages';

  @override
  String get name => 'evolve';

  @override
  void run() => exitWithMessageOnBorgException(action: _run, exitCode: 255);

  BorgConfiguration configuration;

  void _run() {
    configuration = createConfiguration(argResults);

    final pubspecYamls = loadPubspecYamlFiles(configuration: configuration, argResults: argResults);
    assertPubspecYamlConsistency(pubspecYamls);

    final allExternalDepSpecs = getAllExternalPackageDependencySpecs(pubspecYamls.values);
    if (getVerboseFlag(argResults)) {
      _printDependencySpecs(allExternalDepSpecs);
    }

    print('\nResolving ${allExternalDepSpecs.length} direct external dependencies used by all found packages...');
    final references = _resolveConsistentDependencySet(allExternalDepSpecs);
    print('\tresolved ${references.length} direct and transitive external dependencies');

    if (getDryRunFlag(argResults)) {
      print('\nDRY RUN: Previewing evolution of ${pubspecYamls.length} Dart packages...');
    } else {
      print('\nCommencing evolution of ${pubspecYamls.length} Dart packages...');
    }

    var i = 1;
    for (final entry in pubspecYamls.entries) {
      final packageLocation = path.dirname(entry.key);
      final counter = '[${i++}/${pubspecYamls.length}]';
      if (getDryRunFlag(argResults)) {
        stdout.write('$counter $packageLocation');
      } else {
        stdout.write('$counter Evolving $packageLocation ...');
      }
      _evolvePackage(packageLocation, references);
    }

    print('\nSUCCESS: ${pubspecYamls.length} packages have been processed');
  }

  Iterable<PackageDependency> _resolveConsistentDependencySet(Iterable<PackageDependencySpec> directDepSpecs) =>
      withTempLocation(action: (location) {
        _createPackage(
          name: 'borg_evolve_temp',
          location: location,
          depSpecs: directDepSpecs,
        );
        _resolveDependencies(location: location, arguments: '--no-precompile');
        final resolvedDeps = _getResolvedDependencies(location: location);
        return resolvedDeps;
      });

  void _createPackage({
    @required String name,
    @required Directory location,
    @required Iterable<PackageDependencySpec> depSpecs,
  }) {
    if (getVerboseFlag(argResults)) {
      print('\tusing temporary package at ${location.path}...');
    }
    File(path.join(location.path, 'pubspec.yaml')).writeAsStringSync(PubspecYaml(
      name: name,
      dependencies: depSpecs,
    ).toYamlString());
  }

  void _resolveDependencies({@required Directory location, String arguments = ''}) {
    final result = runSystemCommand(
      command: '${pub(configuration)} get $arguments',
      workingDirectory: location,
      environment: pubEnvironment(configuration),
    );
    if (result.exitCode != 0) {
      stdout.write('\n');
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
      stdout.write('\n\tpubspec.lock does not exist, creating one...');
      _resolveDependencies(location: Directory(packageLocation));
    }
    final pubspecLock = pubspecLockFile.readAsStringSync().loadPubspecLockFromYaml();
    final depsCorrectionSet = computePackageDependencyCorrection(pubspecLock.packages, references);
    if (depsCorrectionSet.isNotEmpty && !getDryRunFlag(argResults)) {
      final correctedPubspecLock = pubspecLock.copyWith(
        packages: copyWithPackageDependenciesFromReference(pubspecLock.packages, references),
      );
      pubspecLockFile.writeAsStringSync(correctedPubspecLock.toYamlString());
      _resolveDependencies(location: Directory(packageLocation));
    }

    _printDependencyCorrections(actualDependencies: pubspecLock.packages, correctionSet: depsCorrectionSet);
  }
}

void _printDependencySpecs(Iterable<PackageDependencySpec> deps) {
  print('Total amount of direct external dependencies: ${deps.length} ');
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
    print(' => up-to-date');
  } else {
    stdout.write('\n');
    for (final correction in correctionSet.toList()..sort((a, b) => a.package().compareTo(b.package()))) {
      final orgDep = actualDependencies.firstWhere((d) => d.package() == correction.package());
      print('\t${correction.package()}: ${_formatDependencyDetail(orgDep)} => ${_formatDependencyDetail(correction)}');
    }
    stdout.write('\n');
  }
}

String _formatDependencyDetail(PackageDependency dep) => dep.iswitch(
      sdk: (d) => '${d.version}',
      hosted: (d) => '${d.version}',
      git: (d) => '${d.url}:${d.resolvedRef}',
      path: (d) => '${d.path}',
    );
