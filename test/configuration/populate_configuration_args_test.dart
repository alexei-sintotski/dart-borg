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
  group('$populateConfigurationArgs', () {
    final argParser = ArgParser();
    populateConfigurationArgs(argParser);

    test('adds option for Dart SDK path', () {
      expect(argParser.options.keys, contains('dartsdk'));
    });

    test('adds option for Flutter SDK path', () {
      expect(argParser.options.keys, contains('fluttersdk'));
    });

    test('adds option for locations included to configuration management', () {
      expect(argParser.options.keys, contains('paths'));
    });

    test('adds option to exclude locations from configuration management', () {
      expect(argParser.options.keys, contains('exclude'));
    });
  });
}
