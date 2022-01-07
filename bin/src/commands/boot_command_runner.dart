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
import 'package:borg/src/boot_mode.dart';
import 'package:borg/src/configuration/configuration.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:borg/src/context/borg_boot_context.dart';
import 'package:borg/src/context/borg_context_factory.dart';
import 'package:borg/src/dart_package/dart_package.dart';
import 'package:borg/src/impact/impact_based_on_pubspec_yaml.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:plain_optional/plain_optional.dart';

import '../options/boot_mode.dart';
import '../options/verbose.dart';
import '../pub_operations.dart';
import '../scan_for_packages.dart';
import '../utils/borg_exception.dart';
import '../utils/git.dart';
import '../utils/platform_version.dart';
import '../utils/render_package_name.dart';

@immutable
class BootCommandRunner {
  const BootCommandRunner(
    this.configurationFactory,
    this.contextFactory,
    this.argResults,
  );

  final BorgConfigurationFactory configurationFactory;
  final BorgContextFactory contextFactory;
  final ArgResults argResults;

  void run() {
    final configuration =
        configurationFactory.createConfiguration(argResults: argResults);
    final context = contextFactory.createBorgContext();

    final packages = scanForPackages(
      configuration: configuration,
      argResults: argResults,
    );

    switch (getBootModeOption(argResults)) {
      case BootMode.basic:
        _executeBasicBootstrapping(
          packages: packages,
          configuration: configuration,
        );
        break;
      case BootMode.incremental:
        if (_isPartialBootstrappingRequested()) {
          print(
            'Bootstrapping of specific packages is requested, '
            'using basic bootstrapping\n',
          );
          _executeBasicBootstrapping(
            packages: packages,
            configuration: configuration,
          );
        } else {
          _executeIncrementalBootstrapping(
            packages: packages,
            configuration: configuration,
            context: context.bootContext,
          );
        }
    }

    if (!_isPartialBootstrappingRequested()) {
      contextFactory.save(
        context: context.copyWith(
          bootContext: Optional(BorgBootContext(
              dartSdkVersion: dartSdkVersion,
              gitref: gitHead(),
              bootMode: getBootModeOption(argResults),
              modifiedPackages:
                  _getPackageDiff(gitref: 'HEAD').map(path.relative),
              flutterSdkVersion: configuration.flutterSdkPath.iif(
                some: (flutterSdkPath) =>
                    Optional(flutterSdkVersion(flutterSdkPath: flutterSdkPath)),
                none: () => const Optional.none(),
              ))),
        ),
      );
    }
  }

  bool _isPartialBootstrappingRequested() => argResults.rest.isNotEmpty;

  void _executeBasicBootstrapping({
    required Iterable<DartPackage> packages,
    required BorgConfiguration configuration,
  }) {
    final packagesToBoot = _selectPackagesSpecifiedInCommandLine(packages);

    if (packagesToBoot.isEmpty) {
      throw const BorgException(
          '\nFATAL: Nothing to do, please check command line');
    }

    _bootstrapPackages(
      packages: packagesToBoot,
      configuration: configuration,
    );
  }

  void _executeIncrementalBootstrapping({
    required Iterable<DartPackage> packages,
    required BorgConfiguration configuration,
    required Optional<BorgBootContext> context,
  }) {
    print('Analyzing workspace changes for incremental bootstrapping...\n');

    final packagesToBoot = context.iif(
      some: (ctx) {
        if (_isFlutterVersionChanged(
            context: ctx, configuration: configuration)) {
          return packages;
        }

        if (ctx.dartSdkVersion != dartSdkVersion &&
            ctx.dartSdkVersion.isNotEmpty) {
          print(
            'Dart version change detected, '
            'bootstrapping of all packages required\n'
            '\t${ctx.dartSdkVersion}\n'
            '=> \t$dartSdkVersion\n',
          );
          return packages;
        }

        final packagesWithoutPubspecLock = packages.where(
            (p) => !File(path.join(p.path, 'pubspec.lock')).existsSync());
        if (packagesWithoutPubspecLock.isNotEmpty) {
          print('Found packages without pubspec.lock:');
          for (final package in packagesWithoutPubspecLock) {
            print('\t${renderPackageName(package.path)}');
          }
          print('');
        }

        final packageDiff = {
          ..._getPackageDiff(gitref: ctx.gitref),
          ...ctx.modifiedPackages.map(path.canonicalize),
        }
            .where((d) => Directory(d).existsSync())
            .where((d) => File(path.join(d, 'pubspec.yaml')).existsSync())
            .toList(growable: false);

        final changedPackagesWithinScope = packages
            .where((p) => packageDiff.contains(p.path))
            .toList(growable: false);
        final changedPackagesOutsideOfScope = packageDiff
            .where((d) => !changedPackagesWithinScope.any((p) => p.path == d))
            .map((d) => DartPackage(path: d))
            .toList(growable: false);

        final changedPackages = {
          ...changedPackagesWithinScope,
          ...changedPackagesOutsideOfScope,
        };

        if (changedPackages.isNotEmpty) {
          print('Configuration changes detected for the following packages:');
          for (final package in changedPackages) {
            print('\t${renderPackageName(package.path)}');
          }
          print('');
        }

        final packagesToAnalyze = [
          ...changedPackages,
          ...packagesWithoutPubspecLock
        ];

        print('Analyzing package dependencies...');
        final packagesUnderImpactSinceLastSuccessfulBoot =
            impactBasedOnPubspecYaml(
          packages: packagesToAnalyze,
          allPackagesInScope: {...packages, ...changedPackagesOutsideOfScope},
        )
                .where((p) => !changedPackagesOutsideOfScope
                    .any((pp) => pp.path == p.path))
                .toSet();
        print('');

        return packagesUnderImpactSinceLastSuccessfulBoot;
      },
      none: () {
        print('No information on the last successful bootstrapping is found.');
        print('Bootstrapping all found packages...\n');

        if (packages.isEmpty) {
          throw const BorgException(
              '\nFATAL: Nothing to do, please check command line');
        }

        return packages;
      },
    );

    if (packagesToBoot.isEmpty) {
      print('SUCCESS: Workspace is up-to-date, bootstrapping is not required');
    } else {
      _bootstrapPackages(
        packages: packagesToBoot,
        configuration: configuration,
      );
    }
  }

  bool _isFlutterVersionChanged({
    required BorgBootContext context,
    required BorgConfiguration configuration,
  }) =>
      context.flutterSdkVersion.iif(
        some: (ctxVersion) => configuration.flutterSdkPath.iif(
          some: (flutterSdkPath) {
            final actualVersion =
                flutterSdkVersion(flutterSdkPath: flutterSdkPath);
            if (actualVersion != ctxVersion) {
              print('Flutter version change detected, '
                  'bootstrapping of all packages required\n\n'
                  '$ctxVersion\n\n'
                  '=>\n\n'
                  '$actualVersion\n');
            }
            return ctxVersion != actualVersion;
          },
          none: () {
            print('Path to Flutter SDK has become undefined\n'
                'Bootstrapping of all packages required\n');
            return true;
          },
        ),
        none: () => configuration.flutterSdkPath.iif(
          some: (p) => false,
          none: () => false,
        ),
      );
  Iterable<DartPackage> _selectPackagesSpecifiedInCommandLine(
          Iterable<DartPackage> packages) =>
      _isPartialBootstrappingRequested()
          ? packages
              .where((p) => argResults.rest.any((arg) => p.path.endsWith(arg)))
          : packages;
  void _bootstrapPackages({
    required Iterable<DartPackage> packages,
    required BorgConfiguration configuration,
  }) {
    print('Bootstrapping packages:');
    var i = 1;
    for (final package in packages) {
      final counter = '[${i++}/${packages.length}]';
      print(
        '$counter ${package.isFlutterPackage ? 'Flutter' : 'Dart'} '
        'package ${renderPackageName(package.path)}...',
      );
      resolveDependencies(
        package: package,
        configuration: configuration,
        verbosity: getVerboseFlag(argResults)
            ? VerbosityLevel.verbose
            : VerbosityLevel.short,
      );
    }

    print('\nSUCCESS: ${packages.length} packages have been bootstrapped');
  }
}

Set<String> _getPackageDiff({
  required String gitref,
}) =>
    gitDiffFiles(gitref: gitref)
        .where(_isPubspecFile)
        .map(path.dirname)
        .map(path.canonicalize)
        .toSet();

bool _isPubspecFile(String pathToFile) =>
    path.basenameWithoutExtension(pathToFile) == 'pubspec';
