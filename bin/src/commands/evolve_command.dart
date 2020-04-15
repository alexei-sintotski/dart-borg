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

import 'package:args/command_runner.dart';
import 'package:borg/borg.dart';
import 'package:pubspec_yaml/src/package_dependency_spec/package_dependency_spec.dart';

import '../options/dry_run.dart';
import '../options/exclude.dart';
import '../options/paths.dart';
import '../options/verbose.dart';
import '../pubspec_yaml_functions.dart';

// ignore_for_file: avoid_print

class EvolveCommand extends Command<void> {
  EvolveCommand() {
    addDryRunFlag(argParser);
    addPathsMultiOption(argParser);
    addExcludeMultiOption(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description => 'Upgrade Dart dependencies across multiple packages';

  @override
  String get name => 'evolve';

  @override
  void run() {
    final pubspecYamls = loadPubspecYamlFiles(argResults: argResults);
    assertPubspecYamlConsistency(pubspecYamls);

    final allExternalDepSpecs = getAllExternalPackageDependencySpecs(pubspecYamls.values);
    print('Identified ${allExternalDepSpecs.length} external dependencies');
    if (getVerboseFlag(argResults)) {
      _printDependencies(allExternalDepSpecs);
    }
  }
}

void _printDependencies(Iterable<PackageDependencySpec> deps) {
  for (final dep in deps) {
    print('\t${dep.package()}${_printDependencyDetail(dep)}');
  }
}

String _printDependencyDetail(PackageDependencySpec dep) => dep.iswitch(
      hosted: (dep) => dep.version.iif(
        some: (v) => ': $v',
        none: () => '',
      ),
      sdk: (dep) => ': ${dep.sdk}',
      git: (dep) => ': ${dep.url}',
      path: (_) => '',
    );
