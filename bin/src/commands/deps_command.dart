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
import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:borg/src/dart_package/dart_package.dart';
import 'package:borg/src/get_all_external_package_dependencies.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_lock/pubspec_lock.dart';

import '../options/verbose.dart';
import '../scan_for_packages.dart';
import '../utils/borg_exception.dart';

// ignore_for_file: avoid_print

class DepsCommand extends Command<void> {
  DepsCommand() {
    configurationFactory.populateConfigurationArgs(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description =>
      'Lists external dependencies of multiple packages across repository.\n'
      'Considers all packages by default. To select a subset of packages, '
      'please specify package names in command line.';

  @override
  String get name => 'deps';

  @override
  void run() => exitWithMessageOnBorgException(action: _run, exitCode: 255);

  final BorgConfigurationFactory configurationFactory =
      BorgConfigurationFactory();

  void _run() {
    final configuration =
        configurationFactory.createConfiguration(argResults: argResults);

    final packages = scanForPackages(
      configuration: configuration,
      argResults: argResults,
    );

    final packagesToAnalyze = _selectPackagesSpecifiedInCommandLine(packages);

    if (packagesToAnalyze.isEmpty) {
      print('Dart packages are not found');
      return;
    }

    _assertPubspecLockFilesExist(packagesToAnalyze);

    final pubspecLocks = packagesToAnalyze.map((p) => p.pubspecLock.valueOr(
          () => throw AssertionError('pubspec.lock is not found for '
              'package ${path.relative(p.path)}'),
        ));

    final sdkDeps =
        pubspecLocks.expand((pubspecLock) => pubspecLock.sdks).toSet();
    if (sdkDeps.isNotEmpty) {
      print('=== SDK dependencies:');
      _printSdks(sdkDeps);
      print('');
    }

    final externalDeps = getAllExternalPackageDependencies(pubspecLocks);

    final directDependencies = _getDirectDependencies(
      externalDeps,
      packagesToAnalyze,
    );
    final transDependencies =
        externalDeps.where((d) => !directDependencies.contains(d));

    if (directDependencies.isNotEmpty) {
      print('=== Direct external dependencies:');
      _printDependencies(directDependencies);
      print('');
    }

    if (transDependencies.isNotEmpty) {
      print('=== Transitive external dependencies:');
      _printDependencies(transDependencies);
    }
  }

  Iterable<DartPackage> _selectPackagesSpecifiedInCommandLine(
    Iterable<DartPackage> packages,
  ) =>
      argResults.rest.isNotEmpty
          ? packages
              .where((p) => argResults.rest.any((arg) => p.path.endsWith(arg)))
          : packages;
}

void _printSdks(Set<SdkDependency> sdkDeps) {
  final maxSdkNameLen = _getMaxLength(sdkDeps.map((d) => d.sdk));

  for (final sdk in sdkDeps) {
    print('${sdk.sdk.padRight(maxSdkNameLen)} ${sdk.version} ');
  }
}

void _printDependencies(Iterable<PackageDependency> deps) {
  if (deps.isNotEmpty) {
    final maxPackageNameLen = _getMaxLength(deps.map((d) => d.package()));
    final maxVersionLen = _getMaxLength(deps.map((d) => d.version()));

    for (final dep in deps) {
      final reference = dep.iswitch(
        sdk: (d) => d.description,
        hosted: (d) => '${d.url}/packages/${d.package}',
        git: (d) => d.url,
        path: (d) => d.path,
      );
      print('${dep.package().padRight(maxPackageNameLen)} '
          '${dep.version().padRight(maxVersionLen)} '
          '$reference');
    }
  } else {
    print('Not found');
  }
}

Iterable<PackageDependency> _getDirectDependencies(
  Iterable<PackageDependency> deps,
  Iterable<DartPackage> packages,
) =>
    deps
        .where((dep) => packages.any((package) => package.pubspecLock.iif(
              some: (p) => p.packages.any((d) =>
                  d.package() == dep.package() &&
                  d.type() != DependencyType.transitive),
              none: () => throw AssertionError(
                  'pubspec.lock expected for ${package.path}'),
            )))
        .toList(growable: false);

void _assertPubspecLockFilesExist(
  Iterable<DartPackage> packages,
) {
  final packagesWithoutPubspecLock = packages
      .where((p) => !File(path.join(p.path, 'pubspec.lock')).existsSync());

  if (packagesWithoutPubspecLock.isNotEmpty) {
    print('Found packages without pubspec.lock:');
    for (final p in packagesWithoutPubspecLock) {
      print('\t${path.relative(p.path)}');
    }
    throw const BorgException('\nFAILED: Packages without pubspec.lock found, '
        'please use "pub get" or "borg boot" to resolve dependencies');
  }
}

int _getMaxLength(Iterable<String> ss) => ss.map((s) => s.length).fold(0, max);
