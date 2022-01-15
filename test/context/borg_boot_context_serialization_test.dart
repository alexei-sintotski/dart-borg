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

import 'package:borg/src/boot_mode.dart';
import 'package:borg/src/context/borg_boot_context.dart';
import 'package:borg/src/context/borg_context.dart';
import 'package:borg/src/context/borg_context_factory.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

// ignore_for_file: avoid_as

void main() {
  group('$BorgContextFactory', () {
    group('given context file does not exist', () {
      final factory =
          BorgContextFactory(tryToReadFileSync: (_) => const Optional.none());
      final context = factory.createBorgContext();
      test('it provides context without boot context', () {
        expect(context.bootContext.hasValue, false);
      });
    });

    group('given empty context file', () {
      final factory =
          BorgContextFactory(tryToReadFileSync: (_) => const Optional(''));
      final context = factory.createBorgContext();
      test('it provides context without boot context', () {
        expect(context.bootContext.hasValue, false);
      });
    });

    group('given valid YAML file without boot context section', () {
      final factory = BorgContextFactory(
          tryToReadFileSync: (_) => const Optional('some_key:'));
      final context = factory.createBorgContext();
      test('it provides context without boot context', () {
        expect(context.bootContext.hasValue, false);
      });
    });

    group('given context object without boot context', () {
      const context = BorgContext();

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

    group('handling of Dart SDK version', () {
      group(
          'given context file without boot context containing Dart SDK version',
          () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) =>
              const Optional(contextWithBootContextWithGitrefOnly),
        );
        final context = factory.createBorgContext();

        test('it provides empty string for Dart SDK version', () {
          expect(context.bootContext.unsafe!.dartSdkVersion, isEmpty);
        });
      });

      group('given context file with boot context containing Dart SDK version',
          () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) => const Optional(contextWithDartSdkVersion),
        );
        final context = factory.createBorgContext();

        test('it provides correct Dart SDK version', () {
          expect(context.bootContext.unsafe!.dartSdkVersion, dartSdkVersion);
        });
      });

      group('given context object with boot context', () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.basic,
          )),
        );

        test('it creates context file with correct Dart SDK version', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent)
                    .bootContext
                    .unsafe!
                    .dartSdkVersion,
                dartSdkVersion);
          }).save(context: context);
        });
      });
    });

    group('handling of gitref', () {
      group('given context file with boot context containing gitref', () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) =>
              const Optional(contextWithBootContextWithGitrefOnly),
        );
        final context = factory.createBorgContext();

        test('it provides boot context object', () {
          expect(context.bootContext.hasValue, true);
        });

        test('it provides correct gitref', () {
          expect(context.bootContext.unsafe!.gitref, gitref);
        });

        test('it provides an empty list of modified packages', () {
          expect(context.bootContext.unsafe!.modifiedPackages, isEmpty);
        });
      });

      group('given context object with boot context', () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.basic,
          )),
        );

        test('it provides content to save', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            expect(content, isNotEmpty);
          }).save(context: context);
        });

        test('it provides content with boot context', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent).bootContext.hasValue, isTrue);
          }).save(context: context);
        });

        test('it provides boot context with correct gitref value', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(BorgContext.fromJson(jsonContent).bootContext.unsafe!.gitref,
                gitref);
          }).save(context: context);
        });
      });

      group('given last successful boot gitref covertible to a number in YAML',
          () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitrefThatLooksLikeANumber,
            bootMode: BootMode.basic,
          )),
        );
        String? contextString;
        BorgContextFactory(
                saveStringToFileSync: (_, content) => contextString = content)
            .save(context: context);

        test('it does not crash while loading context containing this gitref',
            () {
          expect(contextString, isNotNull);
          BorgContextFactory(tryToReadFileSync: (_) => Optional(contextString))
              .createBorgContext();
        });
      });
    });

    group('handling of boot mode', () {
      group('given context file without boot mode specified', () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) =>
              const Optional(contextWithBootContextWithGitrefOnly),
        );
        final context = factory.createBorgContext();

        test('it produces context with boot mode basic', () {
          expect(context.bootContext.unsafe!.bootMode, BootMode.basic);
        });
      });

      group('given context file with boot mode basic specified', () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) => const Optional(contextWithBootModeBasic),
        );
        final context = factory.createBorgContext();

        test('it produces context with boot mode basic', () {
          expect(context.bootContext.unsafe!.bootMode, BootMode.basic);
        });
      });

      group('given context file with boot mode incremental specified', () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) =>
              const Optional(contextWithBootModeIncremental),
        );
        final context = factory.createBorgContext();

        test('it produces context with boot mode incremental', () {
          expect(context.bootContext.unsafe!.bootMode, BootMode.incremental);
        });
      });

      group('given context object with boot mode basic', () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.basic,
          )),
        );

        test('it save boot context with boot mode basic', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent).bootContext.unsafe!.bootMode,
                BootMode.basic);
          }).save(context: context);
        });
      });

      group('given context object with boot mode incremental', () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.incremental,
          )),
        );

        test('it save boot context with boot mode incremental', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent).bootContext.unsafe!.bootMode,
                BootMode.incremental);
          }).save(context: context);
        });
      });
    });

    group('handling of modified packages', () {
      group(
        'given context file with boot context not containing list of '
        'modified packages',
        () {
          final factory = BorgContextFactory(
            tryToReadFileSync: (_) =>
                const Optional(contextWithBootContextWithGitrefOnly),
          );
          final context = factory.createBorgContext();

          test('it provides an empty list of modified packages', () {
            expect(context.bootContext.unsafe!.modifiedPackages, isEmpty);
          });
        },
      );

      group(
        'given context file with boot context containing list of '
        'modified packages',
        () {
          final factory = BorgContextFactory(
            tryToReadFileSync: (_) =>
                const Optional(contextWithBootContextWithModifiedPackages),
          );
          final context = factory.createBorgContext();

          test('it provides correct list of modified packages', () {
            expect(
              context.bootContext.unsafe!.modifiedPackages,
              ['a', 'b', 'c'],
            );
          });
        },
      );

      group('given context object with empty list of modified packages', () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.basic,
          )),
        );
        test('it produces context file with empty list of modified_packages',
            () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent)
                    .bootContext
                    .unsafe!
                    .modifiedPackages,
                isEmpty);
          }).save(context: context);
        });
      });

      group('given context object with non-empty list of modified packages',
          () {
        const modifiedPackages = ['a', 'b', 'c'];
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.basic,
            modifiedPackages: modifiedPackages,
          )),
        );
        test('it produces context file with empty list of modified_packages',
            () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent)
                    .bootContext
                    .unsafe!
                    .modifiedPackages,
                modifiedPackages);
          }).save(context: context);
        });
      });
    });

    group('handling of Flutter SDK version', () {
      group('given context file without specified Flutter SDK version', () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) =>
              const Optional(contextWithBootContextWithGitrefOnly),
        );
        final context = factory.createBorgContext();

        test('it provides context object without Flutter SDK version', () {
          expect(
              context.bootContext.unsafe!.flutterSdkVersion.hasValue, isFalse);
        });
      });

      group(
          'given context file with boot context containing Flutter SDK version',
          () {
        final factory = BorgContextFactory(
          tryToReadFileSync: (_) =>
              const Optional(contextWithFlutterSdkVersion),
        );
        final context = factory.createBorgContext();

        test('it provides correct Flutter SDK version', () {
          expect(context.bootContext.unsafe!.flutterSdkVersion.unsafe,
              flutterSdkVersion);
        });
      });

      group(
          'given context object with boot context without Flutter SDK version',
          () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.basic,
          )),
        );

        test('it creates context file without Flutter SDK version', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent)
                    .bootContext
                    .unsafe!
                    .flutterSdkVersion
                    .hasValue,
                isFalse);
          }).save(context: context);
        });
      });

      group('given context object with boot context with Flutter SDK version',
          () {
        const context = BorgContext(
          bootContext: Optional(BorgBootContext(
            dartSdkVersion: dartSdkVersion,
            gitref: gitref,
            bootMode: BootMode.basic,
            flutterSdkVersion: Optional(flutterSdkVersion),
          )),
        );

        test('it creates context file with correct Flutter SDK version', () {
          BorgContextFactory(saveStringToFileSync: (_, content) {
            final jsonContent = json.decode(json.encode(loadYaml(content)))
                as Map<String, dynamic>;
            expect(
                BorgContext.fromJson(jsonContent)
                    .bootContext
                    .unsafe!
                    .flutterSdkVersion
                    .unsafe,
                flutterSdkVersion);
          }).save(context: context);
        });
      });
    });
  });
}

const gitref = 'some_gitref';
const contextWithBootContextWithGitrefOnly = '''
last_successful_bootstrap:
  gitref: $gitref
''';

const gitrefThatLooksLikeANumber = '07014e169';

const contextWithBootContextWithModifiedPackages = '''
last_successful_bootstrap:
  gitref: $gitref
  modified_packages: [a, b, c]
''';

const dartSdkVersion =
    '1.0.0 (stable) (Tue May 26 18:39:38 2020 +0200) on macos_x64';
const contextWithDartSdkVersion = '''
last_successful_bootstrap:
  gitref: $gitref
  dart_sdk_version: $dartSdkVersion
''';

const flutterSdkVersion = '''
Flutter 1.17.2 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 5f21edf8b6 (10 days ago) • 2020-05-28 12:44:12 -0700
Engine • revision b851c71829
Tools • Dart 2.8.3''';
const contextWithFlutterSdkVersion = '''
last_successful_bootstrap:
  dart_sdk_version: $dartSdkVersion
  gitref: $gitref
  flutter_sdk_version: |
    Flutter 1.17.2 • channel stable • https://github.com/flutter/flutter.git
    Framework • revision 5f21edf8b6 (10 days ago) • 2020-05-28 12:44:12 -0700
    Engine • revision b851c71829
    Tools • Dart 2.8.3''';

const contextWithBootModeBasic = '''
last_successful_bootstrap:
  gitref: $gitref
  dart_sdk_version: $dartSdkVersion
  boot_mode: basic''';

const contextWithBootModeIncremental = '''
last_successful_bootstrap:
  gitref: $gitref
  dart_sdk_version: $dartSdkVersion
  boot_mode: incremental''';
