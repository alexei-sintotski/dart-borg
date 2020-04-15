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
import 'package:pubspec_yaml/src/package_dependency_spec/package_dependency_spec.dart';

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
    final pubspecYamls = loadPubspecYamlFiles(argResults: argResults);
    assertPubspecYamlConsistency(pubspecYamls);

    final allExternalDepSpecs = getAllExternalPackageDependencySpecs(pubspecYamls.values);
    print('Identified ${allExternalDepSpecs.length} direct external dependencies');
    if (getVerboseFlag(argResults)) {
      _printDependencySpecs(allExternalDepSpecs);
    }

    withTempLocation(action: (location) {
      _createPackage(
        name: 'borg_evolve_temp',
        location: location,
        depSpecs: allExternalDepSpecs,
      );
      _resolveDependencies(location);
      final resolvedDeps = _getResolvedDependencies(location: location);
      print('Resolved ${resolvedDeps.length} external dependencies');
    });
  }

  void _createPackage({
    @required String name,
    @required Directory location,
    @required Iterable<PackageDependencySpec> depSpecs,
  }) {
    if (getVerboseFlag(argResults)) {
      print('Creating temporary package at ${location.path}');
    }
    File(path.join(location.path, 'pubspec.yaml')).writeAsStringSync(PubspecYaml(
      name: name,
      dependencies: depSpecs,
    ).toYamlString());
  }

  void _resolveDependencies(Directory location) {
    print('\n==> Resolving external dependencies...');
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

  Iterable<PackageDependency> _getResolvedDependencies({@required Directory location}) =>
      File(path.join(location.path, 'pubspec.lock')).readAsStringSync().loadPubspecLockFromYaml().packages;
}

void _printDependencySpecs(Iterable<PackageDependencySpec> deps) {
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
