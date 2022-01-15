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
import 'package:plain_optional/plain_optional.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';
import 'package:test/test.dart';

void main() {
  group('$getAllExternalPackageDependencySpecs', () {
    group(
        'provided with pubspec.yaml with a single production hosted dependency',
        () {
      final pubspecYaml = PubspecYaml.loadFromYamlString(
        _prependPackageName('dependencies: {a: }'),
      );
      final r = getAllExternalPackageDependencySpecs([pubspecYaml]);

      test('it produces the specified dependency', () {
        expect(r, const [
          PackageDependencySpec.hosted(
              HostedPackageDependencySpec(package: 'a'))
        ]);
      });
    });

    group('provided with pubspec.yaml with a single production path dependency',
        () {
      final pubspecYaml = PubspecYaml.loadFromYamlString(
        _prependPackageName('dependencies: {a: {path: xx}}'),
      );
      final r = getAllExternalPackageDependencySpecs([pubspecYaml]);

      test('it produces empty result', () {
        expect(r, isEmpty);
      });
    });

    group('provided with pubspec.yaml with a single production sdk dependency',
        () {
      const sdk = 'xx';
      final pubspecYaml = PubspecYaml.loadFromYamlString(
        _prependPackageName('dependencies: {a: {sdk: $sdk}}'),
      );
      final r = getAllExternalPackageDependencySpecs([pubspecYaml]);

      test('it produces the specified dependency', () {
        expect(r, const [
          PackageDependencySpec.sdk(
              SdkPackageDependencySpec(package: 'a', sdk: sdk))
        ]);
      });
    });

    group('provided with pubspec.yaml with a single production git dependency',
        () {
      const url = 'xx';
      final pubspecYaml = PubspecYaml.loadFromYamlString(
        _prependPackageName('dependencies: {a: {git: $url}}'),
      );
      final r = getAllExternalPackageDependencySpecs([pubspecYaml]);

      test('it produces the specified dependency', () {
        expect(r, const [
          PackageDependencySpec.git(
              GitPackageDependencySpec(package: 'a', url: url))
        ]);
      });
    });

    group(
      'provided with pubspec.yaml with a single development hosted dependency',
      () {
        final pubspecYaml = PubspecYaml.loadFromYamlString(
          _prependPackageName('dev_dependencies: {a: }'),
        );
        final r = getAllExternalPackageDependencySpecs([pubspecYaml]);

        test('it produces the specified dependency', () {
          expect(r, const [
            PackageDependencySpec.hosted(
              HostedPackageDependencySpec(package: 'a'),
            )
          ]);
        });
      },
    );

    group('provided with pubspec.yaml with a dependency override', () {
      const overridenVersion = '^2.0.0';
      final pubspecYaml = PubspecYaml.loadFromYamlString(
        _prependPackageName('dependencies: {a: ^1.0.0}\n'
            'dependency_overrides: {a: $overridenVersion}'),
      );
      final r = getAllExternalPackageDependencySpecs([pubspecYaml]);

      test('it produces the overriden dependency', () {
        expect(r, const [
          PackageDependencySpec.hosted(HostedPackageDependencySpec(
            package: 'a',
            version: Optional(overridenVersion),
          ))
        ]);
      });
    });

    group(
      'given two pubspec.yaml files with hosted dependency with '
      'version specified and ommitted',
      () {
        final pubspecYamlNoVersion = PubspecYaml.loadFromYamlString(
          _prependPackageName('dependencies: {a:}'),
        );
        final pubspecYamlWithVersion = PubspecYaml.loadFromYamlString(
          _prependPackageName('dependencies: {a: 1.0.0}'),
        );
        final r = getAllExternalPackageDependencySpecs(
          [pubspecYamlNoVersion, pubspecYamlWithVersion],
        );

        test('it produces dependency with detailed specification', () {
          expect(
            r,
            const [
              PackageDependencySpec.hosted(HostedPackageDependencySpec(
                package: 'a',
                version: Optional('1.0.0'),
              ))
            ],
          );
        });
      },
    );
  });
}

String _prependPackageName(String yamlBody) => 'name: package\n$yamlBody';
