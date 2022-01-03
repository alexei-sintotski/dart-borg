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

import 'package:borg/borg.dart';
import 'package:borg/src/package_dependency_to_version.dart';
import 'package:pubspec_lock/pubspec_lock.dart';

import 'borg_exception.dart';
import 'print_dependency_usage_report.dart';

// ignore_for_file: avoid_print

void correctPackageDependencyBasedOnReport({
  required List<DependencyUsageReport<PackageDependency>> report,
}) {
  final reports = report
    ..sort((a, b) => a.dependencyName.compareTo(b.dependencyName));

  for (final report in reports) {
    final dependencyName = report.dependencyName;
    print('\n$dependencyName: inconsistent dependency specifications detected');
    printDependencyUsage<PackageDependency>(
      dependencies: report.references,
      formatDependency: (dependency) => dependency.version(),
    );

    final inconsistentVersions = report.references.keys.map(
      (package) => package.version(),
    );

    print('\nChange "$dependencyName" version to? $inconsistentVersions');
    final userInput = stdin.readLineSync();
    if (userInput == null || !inconsistentVersions.contains(userInput)) {
      throw BorgException(
        'FAILURE: Version "$userInput" did not match '
        'any $inconsistentVersions',
      );
    }

    for (final reference in report.references.entries) {
      final newPubspecLocks = packageDependencyToVersion(
        dependency: reference.key,
        inPubspecLocks: reference.value.asMap().map(
              (_, path) => MapEntry(
                path,
                File(path).readAsStringSync().loadPubspecLockFromYaml(),
              ),
            ),
        toVersion: userInput,
      );
      for (final newPubspecLock in newPubspecLocks.entries) {
        File(newPubspecLock.key).writeAsStringSync(
          newPubspecLock.value.toYamlString(),
        );
      }
    }
  }
}
