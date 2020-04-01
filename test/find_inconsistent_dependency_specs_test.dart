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

import 'package:borg/borg.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';
import 'package:test/test.dart';

void main() {
  group('$findInconsistentDependencySpecs', () {
    group('given empty pubspec.yaml list', () {
      final report = findInconsistentDependencySpecs({});
      test('it produces empty report', () {
        expect(report, isEmpty);
      });
    });

    group('given a single pubspec.yaml file', () {
      final pubspecYamlWithSingleDepSpec = PubspecYaml.loadFromYamlString('dependencies: {a:}');
      final report = findInconsistentDependencySpecs({'x': pubspecYamlWithSingleDepSpec});
      test('it produces empty report', () {
        expect(report, isEmpty);
      });
    });

    group('given two pubspec.yaml files with conflicting dependency specs', () {
      final pubspecYamlWithA = PubspecYaml.loadFromYamlString('dependencies: {a:}');
      final pubspecYamlWithVersionedA = PubspecYaml.loadFromYamlString('dependencies: {a: 1.0.0}');
      final report = findInconsistentDependencySpecs({'x': pubspecYamlWithA, 'y': pubspecYamlWithVersionedA});
      test('it produces correct report', () {
        expect(report, [
          PackageDependencySpecReport(dependencyName: 'a', references: {
            pubspecYamlWithA.dependencies.first: const ['x'],
            pubspecYamlWithVersionedA.dependencies.first: const ['y'],
          })
        ]);
      });
    });

    group('given two pubspec.yaml files with consistent dependency specs', () {
      final pubspecYaml = PubspecYaml.loadFromYamlString('dependencies: {a: ^1.0.0}');
      final anotherPubspecYaml = PubspecYaml.loadFromYamlString('dependencies: {a: ^1.0.0}');
      final report = findInconsistentDependencySpecs({'x': pubspecYaml, 'y': anotherPubspecYaml});
      test('it produces empty report', () {
        expect(report, isEmpty);
      });
    });

    group('given two pubspec.yaml files with inconsistent dependency and dev_dependency specs', () {
      final pubspecYamlWithDep = PubspecYaml.loadFromYamlString('dependencies: {a:}');
      final pubspecYamlWithDevDep = PubspecYaml.loadFromYamlString('dev_dependencies: {a: ^1.0.0}');
      final report = findInconsistentDependencySpecs({'x': pubspecYamlWithDep, 'y': pubspecYamlWithDevDep});
      test('it produces correct report', () {
        expect(report, [
          PackageDependencySpecReport(dependencyName: 'a', references: {
            pubspecYamlWithDep.dependencies.first: const ['x'],
            pubspecYamlWithDevDep.devDependencies.first: const ['y'],
          })
        ]);
      });
    });

    group('given two pubspec.yaml files with consistency enforced with dependency override', () {
      final pubspecYaml = PubspecYaml.loadFromYamlString('dependencies: {a:}');
      final pubspecYamlWithOverride = PubspecYaml.loadFromYamlString('dev_dependencies: {a: ^1.0.0}\n'
          'dependency_overrides: {a:}');
      final report = findInconsistentDependencySpecs({'x': pubspecYaml, 'y': pubspecYamlWithOverride});
      test('it produces empty report', () {
        expect(report, isEmpty);
      });
    });

    group('given two pubspec.yaml files with path dependency with different paths', () {
      final pubspecYaml = PubspecYaml.loadFromYamlString('dependencies: {a: {path: x}}');
      final anotherPubspecYaml = PubspecYaml.loadFromYamlString('dependencies: {a: {path: xx}}');
      final report = findInconsistentDependencySpecs({'x': pubspecYaml, 'y': anotherPubspecYaml});
      test('it produces empty report', () {
        expect(report, isEmpty);
      });
    });
  });
}
