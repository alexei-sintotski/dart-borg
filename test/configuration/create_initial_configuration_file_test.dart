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

import 'dart:convert';

import 'package:borg/src/configuration/configuration.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('$BorgConfigurationFactory', () {
    final factory = BorgConfigurationFactory(
        tryToReadFileSync: (_) => const Optional.none());

    test(
        'creates initial configuration file with include entry referring to '
        'current directory', () {
      factory.createInitialConfigurationFile(
          saveStringToFileSync: (_, content) {
        final savedConfig = BorgConfiguration.fromJson(_toJson(content));
        expect(savedConfig.pathsToScan, contains('.'));
      });
    });

    test('creates initial configuration file with exclude entry', () {
      factory.createInitialConfigurationFile(
          saveStringToFileSync: (_, content) {
        expect(_toJson(content).keys, contains('exclude'));
      });
    });

    test('creates initial configuration file with dartsdk entry', () {
      factory.createInitialConfigurationFile(
          saveStringToFileSync: (_, content) {
        expect(_toJson(content).keys, contains('dart_sdk'));
      });
    });
  });
}

Map<String, dynamic> _toJson(String yaml) =>
    // ignore: avoid_as
    json.decode(json.encode(loadYaml(yaml))) as Map<String, dynamic>;
