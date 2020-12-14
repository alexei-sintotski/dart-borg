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

import 'package:args/args.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:test/test.dart';

void main() {
  group('$BorgConfigurationFactory', () {
    group('given no configuration file', () {
      final argParser = ArgParser();
      final factory = BorgConfigurationFactory(
        tryToReadFileSync: (_) => const Optional.none(),
      )..populateConfigurationArgs(argParser);

      test('it populates paths command line option', () {
        expect(argParser.options.keys, contains('paths'));
      });

      test('it populates exclude command line option', () {
        expect(argParser.options.keys, contains('exclude'));
      });

      test('it populates dartsdk command line option', () {
        expect(argParser.options.keys, contains('dartsdk'));
      });

      test('it populates fluttersdk command line option', () {
        expect(argParser.options.keys, contains('fluttersdk'));
      });

      group('given command-line with undefined paths', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--paths=']));
        test('it creates configuration object with empty list of paths', () {
          expect(config.pathsToScan, isEmpty);
        });
      });

      group('given command-line with undefined excluded paths', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--exclude=']));
        test(
            'it creates configuration object with empty list of excluded paths',
            () {
          expect(config.excludedPaths, isEmpty);
        });
      });

      group('given command-line with undefined Dart SDK path', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--dartsdk=']));
        test('it creates configuration object with undefined Dart SDK path',
            () {
          expect(config.dartSdkPath.hasValue, isFalse);
        });
      });

      group('given command-line with undefined Flutter SDK path', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--fluttersdk=']));
        test('it creates configuration object with undefined Flutter SDK path',
            () {
          expect(config.flutterSdkPath.hasValue, isFalse);
        });
      });

      group('given command-line with defined paths', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--paths=$_pathsValue']));
        test('it creates configuration object with correct paths value', () {
          expect(config.pathsToScan, [_pathsValue]);
        });
      });

      group('given command-line with defined excluded paths', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--exclude=$_excludeValue']));
        test('it creates configuration object with correct exclude value', () {
          expect(config.excludedPaths, [_excludeValue]);
        });
      });

      group('given command-line with defined path to Dart SDK', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--dartsdk=$_dartsdkValue']));
        test('it creates configuration object with correct dartsdk value', () {
          expect(config.dartSdkPath, const Optional(_dartsdkValue));
        });
      });

      group('given command-line with defined path to Flutter SDK', () {
        final config = factory.createConfiguration(
            argResults: argParser.parse(['--fluttersdk=$_fluttersdkValue']));
        test('it creates configuration object with correct fluttersdk value',
            () {
          expect(config.flutterSdkPath, const Optional(_fluttersdkValue));
        });
      });
    });
  });
}

const _pathsValue = 'included_path';
const _excludeValue = 'excluded_path';
const _dartsdkValue = 'path_to_dart_sdk';
const _fluttersdkValue = 'path_to_flutter_sdk';
