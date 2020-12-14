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

void main() {
  group('$BorgConfigurationFactory', () {
    group('given configuration file with paths defined', () {
      final argParser = ArgParser();
      final factory = BorgConfigurationFactory(
        tryToReadFileSync: (_) =>
            const Optional(_configurationWithIncludedLocation),
        toAbsolutePath: (s) => s,
      )..populateConfigurationArgs(argParser);

      group('given no arguments in command line', () {
        final config =
            factory.createConfiguration(argResults: argParser.parse([]));
        test(
            'it produces configuration with included paths according to the configuration file',
            () {
          expect(config.pathsToScan, [_includedLocation]);
        });
      });

      group('given command line with included paths defined', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--paths=$_includedLocation2']));
        test(
            'it produces configuration with included paths according to the command line',
            () {
          expect(config.pathsToScan, [_includedLocation2]);
        });
      });
    });

    group('given configuration file with excluded paths defined', () {
      final argParser = ArgParser();
      final factory = BorgConfigurationFactory(
        tryToReadFileSync: (_) =>
            const Optional(_configurationWithExcludedLocation),
        toAbsolutePath: (s) => s,
      )..populateConfigurationArgs(argParser);

      group('given no arguments in command line', () {
        final config =
            factory.createConfiguration(argResults: argParser.parse([]));
        test(
            'it produces configuration with excluded paths according to the configuration file',
            () {
          expect(config.excludedPaths, [_excludedLocation]);
        });
      });

      group('given command line with excluded paths defined', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--paths=$_excludedLocation2']));
        test(
            'it produces configuration with excluded paths according to the command line',
            () {
          expect(config.pathsToScan, [_excludedLocation2]);
        });
      });
    });

    group('given configuration file with path to Dart SDK defined', () {
      final argParser = ArgParser();
      final factory = BorgConfigurationFactory(
        tryToReadFileSync: (_) =>
            const Optional(_configurationWithDartSdkLocation),
        toAbsolutePath: (s) => s,
      )..populateConfigurationArgs(argParser);

      group('given no arguments in command line', () {
        final config =
            factory.createConfiguration(argResults: argParser.parse([]));
        test(
            'it produces configuration with Dart SDK path according to the configuration file',
            () {
          expect(config.dartSdkPath, const Optional(_dartSdkLocation));
        });
      });

      group('given command line with path to Dart SDK defined', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--dartsdk=$_dartSdkLocation2']));
        test(
            'it produces configuration with Dart SDK path according to the command line',
            () {
          expect(config.dartSdkPath, const Optional(_dartSdkLocation2));
        });
      });
    });

    group('given configuration file with path to Flutter SDK defined', () {
      final argParser = ArgParser();
      final factory = BorgConfigurationFactory(
        tryToReadFileSync: (_) =>
            const Optional(_configurationWithFlutterSdkLocation),
        toAbsolutePath: (s) => s,
      )..populateConfigurationArgs(argParser);

      group('given no arguments in command line', () {
        final config =
            factory.createConfiguration(argResults: argParser.parse([]));
        test(
            'it produces configuration with Flutter SDK path according to the configuration file',
            () {
          expect(config.flutterSdkPath, const Optional(_flutterSdkLocation));
        });
      });

      group('given command line with path to Flutter SDK defined', () {
        final config = factory.createConfiguration(
            argResults:
                argParser.parse(['--fluttersdk=$_flutterSdkLocation2']));
        test(
            'it produces configuration with Flutter SDK path according to the command line',
            () {
          expect(config.flutterSdkPath, const Optional(_flutterSdkLocation2));
        });
      });
    });

    group('given configuration file with all options specified', () {
      test('it produces configuration without exceptions', () {
        final argParser = ArgParser();
        BorgConfigurationFactory(
          tryToReadFileSync: (_) =>
              const Optional(_configurationWithAllOptionsSpecified),
          toAbsolutePath: (s) => s,
        )
          ..populateConfigurationArgs(argParser)
          ..createConfiguration(argResults: argParser.parse([]));
      });
    });
  });
}

const _includedLocation = 'included_location';
const _configurationWithIncludedLocation = '''
include: $_includedLocation
''';
const _includedLocation2 = 'included_location_2';

const _excludedLocation = 'excluded_location';
const _configurationWithExcludedLocation = '''
exclude:
  - $_excludedLocation
''';
const _excludedLocation2 = 'excluded_location_2';

const _dartSdkLocation = 'dartsdk_location';
const _configurationWithDartSdkLocation = '''
dart_sdk: $_dartSdkLocation
''';
const _dartSdkLocation2 = 'dartsdk_location_2';

const _flutterSdkLocation = 'fluttersdk_location';
const _configurationWithFlutterSdkLocation = '''
flutter_sdk: $_flutterSdkLocation
''';
const _flutterSdkLocation2 = 'fluttersdk_location_2';

const _configurationWithAllOptionsSpecified = '''
exclude: $_excludedLocation
include: $_includedLocation
dart_sdk: $_dartSdkLocation
flutter_sdk: $_flutterSdkLocation
''';
