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
import 'package:collection/collection.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:yaml/yaml.dart';

import 'configuration.dart';

part 'options/dart_sdk.dart';
part 'options/exclude.dart';
part 'options/flutter_sdk.dart';
part 'options/paths.dart';

// ignore_for_file: public_member_api_docs

void populateConfigurationArgs(ArgParser argParser) {
  _addDartSdkOption(argParser);
  _addFlutterSdkOption(argParser);
  _addPathsMultiOption(argParser);
  _addExcludeMultiOption(argParser);
}

BorgConfiguration createConfiguration(
  ArgResults argResults, {
  Optional<String> Function(String) tryToReadFileSync = _tryToReadFileSync,
}) {
  final configFromFile = tryToReadFileSync('.borg.yaml').iif(
    some: (s) =>
        BorgConfiguration.fromJson(json.decode(json.encode(loadYaml(s))) as Map<String, dynamic>), // ignore: avoid_as
    none: () => const BorgConfiguration(),
  );

  final dartSdkOption = _getDartSdkOption(argResults);
  final flutterSdkOption = _getFlutterSdkOption(argResults);
  return BorgConfiguration(
    dartSdkPath: _getDartSdkOption(argResults) == _defaultDartSdkOption && configFromFile.dartSdkPath.hasValue
        ? configFromFile.dartSdkPath
        : dartSdkOption.isEmpty ? const Optional.none() : Optional(dartSdkOption),
    flutterSdkPath:
        _getFlutterSdkOption(argResults) == _defaultFlutterSdkOption && configFromFile.flutterSdkPath.hasValue
            ? configFromFile.flutterSdkPath
            : flutterSdkOption.isEmpty ? const Optional.none() : Optional(flutterSdkOption),
    pathsToScan: [
      if (_equals(_getPathsMultiOption(argResults), _defaultPathsMultiOption) && configFromFile.pathsToScan.isNotEmpty)
        ...configFromFile.pathsToScan
      else
        ..._getPathsMultiOption(argResults)
    ],
    excludedPaths: [
      if (_equals(_getExcludesMultiOption(argResults), _defaultExcludeMultiOption) &&
          configFromFile.excludedPaths.isNotEmpty)
        ...configFromFile.excludedPaths
      else
        ..._getExcludesMultiOption(argResults)
    ],
  );
}

Optional<String> _tryToReadFileSync(String filePath) {
  final file = File(filePath);
  if (file.existsSync() && [FileSystemEntityType.file].contains(file.statSync().type)) {
    return Optional(file.readAsStringSync());
  } else {
    return const Optional.none();
  }
}

bool _equals(Iterable v1, Iterable v2) => const DeepCollectionEquality().equals(v1, v2);
