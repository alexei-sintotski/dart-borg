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

import 'package:borg/borg.dart';

// ignore_for_file: avoid_print

void printDependencyUsageReport<DependencyType>({
  required List<DependencyUsageReport<DependencyType>> report,
  required String Function(DependencyType dependency) formatDependency,
}) {
  final sortedUses = report
    ..sort((a, b) => a.dependencyName.compareTo(b.dependencyName));

  for (final use in sortedUses) {
    print(
      '\n${use.dependencyName}: '
      'inconsistent dependency specifications detected',
    );
    printDependencyUsage(
      dependencies: use.references,
      formatDependency: formatDependency,
    );
  }
}

void printDependencyUsage<DependencyType>({
  required Map<DependencyType, List<String>> dependencies,
  required String Function(DependencyType dependency) formatDependency,
}) {
  for (final dependency in dependencies.keys) {
    print('\tVersion ${formatDependency(dependency)} is used by:');
    for (final user in dependencies[dependency]) {
      print('\t\t$user');
    }
  }
}
