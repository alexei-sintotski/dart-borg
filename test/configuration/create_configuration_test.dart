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

import 'package:args/args.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:test/test.dart';

ArgResults _produceArgResults({Iterable<String> args = const []}) {
  final argParser = ArgParser();
  populateConfigurationArgs(argParser);
  return argParser.parse(args);
}

void main() {
  group('$createConfiguration', () {
    group('given command line without options and no configuration file', () {
      final configuration = createConfiguration(_produceArgResults(args: ['--dartsdk=']),
          tryToReadFileSync: (_) => const Optional.none());

      test('it produces configuration without Dart SDK path specified', () {
        expect(configuration.dartSdkPath.hasValue, isFalse);
      });

      test('it produces configuration without Flutter SDK path specified', () {
        expect(configuration.flutterSdkPath.hasValue, isFalse);
      });

      test('it produces empty list of paths to exclude from scan', () {
        expect(configuration.excludedPaths, isEmpty);
      });
    });

    group('given command line with all options set and no configuration file', () {
      final argResults = _produceArgResults(args: ['--dartsdk=x', '--fluttersdk=y', '--exclude=z']);
      final configuration = createConfiguration(argResults, tryToReadFileSync: (_) => const Optional.none());

      test('it produces correct Dart SDK path', () {
        expect(configuration.dartSdkPath.unsafe, argResults['dartsdk']);
      });

      test('it produces correct Flutter SDK path', () {
        expect(configuration.flutterSdkPath.unsafe, argResults['fluttersdk']);
      });

      test('it produces correct paths to scan', () {
        expect(configuration.pathsToScan, argResults['paths']);
      });

      test('it produces correct paths to exclude from scan', () {
        expect(configuration.excludedPaths, argResults['exclude']);
      });
    });

    group('given configuration file with excluded paths specified', () {
      final configuration = createConfiguration(
        _produceArgResults(),
        tryToReadFileSync: (_) => const Optional(_configurationWithExcludedLocation),
      );

      test('it produces configuration with correct excluded paths', () {
        expect(configuration.excludedPaths, [_excludedLocation]);
      });
    });

    group('given configuration file and command line with excluded paths specified', () {
      final argResults = _produceArgResults(args: ['--dartsdk=x', '--exclude=z']);
      final configuration = createConfiguration(
        argResults,
        tryToReadFileSync: (_) => const Optional(_configurationWithExcludedLocation),
      );

      test('it produces configuration with excluded paths as specified in command line', () {
        expect(configuration.excludedPaths, argResults['exclude']);
      });
    });

    group('given configuration file with paths specified', () {
      final configuration = createConfiguration(
        _produceArgResults(),
        tryToReadFileSync: (_) => const Optional(_configurationWithIncludedLocation),
      );

      test('it produces configuration with included paths from the configuration file', () {
        expect(configuration.pathsToScan, [_includedLocation]);
      });
    });

    group('given configuration file and command line with paths specified', () {
      final argResults = _produceArgResults(args: ['--dartsdk=x', '--paths=z']);
      final configuration = createConfiguration(
        argResults,
        tryToReadFileSync: (_) => const Optional(_configurationWithExcludedLocation),
      );

      test('it produces configuration with included paths as specified in command line', () {
        expect(configuration.pathsToScan, argResults['paths']);
      });
    });

    group('given configuration file with Dart SDK path specified', () {
      final configuration = createConfiguration(
        _produceArgResults(),
        tryToReadFileSync: (_) => const Optional(_configurationWithDartSdkLocation),
      );

      test('it produces configuration with Dart SDK path from the configuration file', () {
        expect(configuration.dartSdkPath, const Optional(_dartSdkLocation));
      });
    });

    group('given configuration file and command line with path to Dart SDK specified', () {
      final argResults = _produceArgResults(args: ['--dartsdk=x']);
      final configuration = createConfiguration(
        argResults,
        tryToReadFileSync: (_) => const Optional(_configurationWithDartSdkLocation),
      );

      test('it produces configuration with Dart SDK path as specified in command line', () {
        expect(configuration.dartSdkPath.unsafe, argResults['dartsdk']);
      });
    });

    group('given configuration file with Flutter SDK path specified', () {
      final configuration = createConfiguration(
        _produceArgResults(),
        tryToReadFileSync: (_) => const Optional(_configurationWithFlutterSdkLocation),
      );

      test('it produces configuration with Flutter SDK path from the configuration file', () {
        expect(configuration.flutterSdkPath, const Optional(_flutterSdkLocation));
      });
    });

    group('given configuration file and command line with path to Flutter SDK specified', () {
      final argResults = _produceArgResults(args: ['--fluttersdk=x']);
      final configuration = createConfiguration(
        argResults,
        tryToReadFileSync: (_) => const Optional(_configurationWithFlutterSdkLocation),
      );

      test('it produces configuration with Flutter SDK path as specified in command line', () {
        expect(configuration.flutterSdkPath.unsafe, argResults['fluttersdk']);
      });
    });

    group('given configuration file with all options specified', () {
      test('it produces configuration without exceptions', () {
        createConfiguration(
          _produceArgResults(),
          tryToReadFileSync: (_) => const Optional(_configurationWithAllOptionsSpecified),
        );
      });
    });
  });
}

const _excludedLocation = 'excluded_location';
const _configurationWithExcludedLocation = '''
exclude:
  - $_excludedLocation
''';

const _includedLocation = 'included_location';
const _configurationWithIncludedLocation = '''
include: $_includedLocation
''';

const _dartSdkLocation = 'dartsdk_location';
const _configurationWithDartSdkLocation = '''
dart_sdk: $_dartSdkLocation
''';

const _flutterSdkLocation = 'fluttersdk_location';
const _configurationWithFlutterSdkLocation = '''
flutter_sdk: $_flutterSdkLocation
''';

const _configurationWithAllOptionsSpecified = '''
exclude: $_excludedLocation
include: $_includedLocation
dart_sdk: $_dartSdkLocation
flutter_sdk: $_flutterSdkLocation
''';
