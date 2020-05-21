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
import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:yaml/yaml.dart';

import 'configuration.dart';

part 'factory_default_file_io.dart';
part 'options/dart_sdk.dart';
part 'options/exclude.dart';
part 'options/flutter_sdk.dart';
part 'options/paths.dart';

// ignore_for_file: public_member_api_docs

@immutable
class BorgConfigurationFactory {
  BorgConfigurationFactory({Optional<String> Function(String) tryToReadFileSync = _tryToReadFileSync})
      : _configFromFile = tryToReadFileSync(_configurationFileName).iif(
          some: (s) => BorgConfiguration.fromJson(
              json.decode(json.encode(loadYaml(s))) as Map<String, dynamic>), // ignore: avoid_as
          none: () => const BorgConfiguration(),
        );

  final BorgConfiguration _configFromFile;

  void populateConfigurationArgs(ArgParser argParser) {
    _addDartSdkOption(
      argParser: argParser,
      defaultsTo: _configFromFile.dartSdkPath.iif(
        some: (e) => e,
        none: () => _defaultDartSdkPath,
      ),
    );
    _addFlutterSdkOption(
      argParser: argParser,
      defaultsTo: _configFromFile.flutterSdkPath.iif(
        some: (e) => e,
        none: () => '',
      ),
    );
    _addPathsMultiOption(
      argParser: argParser,
      defaultsTo: _configFromFile.pathsToScan.isNotEmpty ? _configFromFile.pathsToScan : [Directory.current.path],
    );
    _addExcludeMultiOption(
      argParser: argParser,
      defaultsTo: _configFromFile.excludedPaths.isNotEmpty ? _configFromFile.excludedPaths : [],
    );
  }

  BorgConfiguration createConfiguration({@required ArgResults argResults}) {
    final dartSdkOption = _getDartSdkOption(argResults);
    final flutterSdkOption = _getFlutterSdkOption(argResults);
    return BorgConfiguration(
      pathsToScan: _getPathsMultiOption(argResults).map((e) => e.trim()).where((e) => e.isNotEmpty),
      excludedPaths: _getExcludesMultiOption(argResults).map((e) => e.trim()).where((e) => e.isNotEmpty),
      dartSdkPath: dartSdkOption.isEmpty ? const Optional.none() : Optional(dartSdkOption),
      flutterSdkPath: flutterSdkOption.isEmpty ? const Optional.none() : Optional(flutterSdkOption),
    );
  }

  void createInitialConfigurationFile({void Function(String, String) saveStringToFileSync = _saveStringToFileSync}) {
    saveStringToFileSync(
      _configurationFileName,
      _initialConfigurationFileContent,
    );
  }
}

const _configurationFileName = '.borg.yaml';
final _defaultDartSdkPath = Platform.environment['DART_SDK'] ?? '';

final _initialConfigurationFileContent = '''
include: # list of locations processed by Borg, glob specifications are allowed
  - .
exclude: # specify here a list of locations to be ignored by Borg
dart_sdk: $_defaultDartSdkPath # path to Dart SDK
flutter_sdk: # path to the root of Flutter SDK
''';
