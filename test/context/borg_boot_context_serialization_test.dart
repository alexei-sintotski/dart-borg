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

import 'dart:convert';

import 'package:borg/src/context/borg_boot_context.dart';
import 'package:borg/src/context/borg_context.dart';
import 'package:borg/src/context/borg_context_factory.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('$BorgContextFactory', () {
    group('if context file does not exist', () {
      final factory = BorgContextFactory(tryToReadFileSync: (_) => const Optional.none());
      final context = factory.createBorgContext();
      test('it provides context without boot context', () {
        expect(context.bootContext.hasValue, false);
      });
    });

    group('if context file exists with boot context filled in', () {
      final factory = BorgContextFactory(tryToReadFileSync: (_) => const Optional(contextWithBootContext));
      final context = factory.createBorgContext();

      test('it provides boot context object', () {
        expect(context.bootContext.hasValue, true);
      });

      test('it provides correct gitref', () {
        expect(context.bootContext.unsafe.gitref, gitref);
      });
    });

    group('given empty context file', () {
      final factory = BorgContextFactory(tryToReadFileSync: (_) => const Optional(''));
      final context = factory.createBorgContext();
      test('it provides context without boot context', () {
        expect(context.bootContext.hasValue, false);
      });
    });

    group('given valid YAML file without boot context section', () {
      final factory = BorgContextFactory(tryToReadFileSync: (_) => const Optional('some_key:'));
      final context = factory.createBorgContext();
      test('it provides context without boot context', () {
        expect(context.bootContext.hasValue, false);
      });
    });

    group('given context object without boot context', () {
      const context = BorgContext(bootContext: Optional.none());

      test('it saves content to a file', () {
        var savedToFile = false;
        BorgContextFactory(saveStringToFileSync: (_, content) {
          savedToFile = true;
        }).save(context: context);
        expect(savedToFile, isTrue);
      });

      test('it provides no content to save', () {
        BorgContextFactory(saveStringToFileSync: (_, content) {
          expect(content, isEmpty);
        }).save(context: context);
      });
    });

    group('given context object with boot context', () {
      const context = BorgContext(bootContext: Optional(BorgBootContext(gitref: gitref)));

      test('it provides content to save', () {
        BorgContextFactory(saveStringToFileSync: (_, content) {
          expect(content, isNotEmpty);
        }).save(context: context);
      });

      test('it provides content with boot context', () {
        BorgContextFactory(saveStringToFileSync: (_, content) {
          // ignore: avoid_as
          final jsonContent = json.decode(json.encode(loadYaml(content))) as Map<String, dynamic>;
          expect(BorgContext.fromJson(jsonContent).bootContext.hasValue, isTrue);
        }).save(context: context);
      });

      test('it provides boot context with correct gitref value', () {
        BorgContextFactory(saveStringToFileSync: (_, content) {
          // ignore: avoid_as
          final jsonContent = json.decode(json.encode(loadYaml(content))) as Map<String, dynamic>;
          expect(BorgContext.fromJson(jsonContent).bootContext.unsafe.gitref, gitref);
        }).save(context: context);
      });
    });
  });
}

const gitref = 'gitref';
const contextWithBootContext = '''
last_successful_bootstrap:
  gitref: $gitref
''';
