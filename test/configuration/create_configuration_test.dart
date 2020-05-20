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
import 'package:test/test.dart';

void main() {
  group('$createConfiguration', () {
    group('given command line without options', () {
      final argParser = ArgParser();
      populateConfigurationArgs(argParser);

      final argResults = argParser.parse(['--dartsdk=']);
      final configuration = createConfiguration(argResults);

      test('produces configuration without Dart SDK path specified', () {
        expect(configuration.dartSdkPath.hasValue, isFalse);
      });

      test('produces configuration without Flutter SDK path specified', () {
        expect(configuration.flutterSdkPath.hasValue, isFalse);
      });

      test('produces empty list of paths to exclude from scan', () {
        expect(configuration.excludedPaths, isEmpty);
      });
    });

    group('given command line with all options set', () {
      final argParser = ArgParser();
      populateConfigurationArgs(argParser);

      final argResults = argParser.parse(['--dartsdk=x', '--fluttersdk=y', '--exclude=z']);
      final configuration = createConfiguration(argResults);

      test('produces correct Dart SDK path', () {
        expect(configuration.dartSdkPath.unsafe, argResults['dartsdk']);
      });

      test('produces correct Flutter SDK path', () {
        expect(configuration.flutterSdkPath.unsafe, argResults['fluttersdk']);
      });

      test('produces correct paths to scan', () {
        expect(configuration.pathsToScan, argResults['paths']);
      });

      test('produces correct paths to exclude from scan', () {
        expect(configuration.excludedPaths, argResults['exclude']);
      });
    });
  });
}
