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

import 'dart:io';

import 'package:args/args.dart';

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

BorgConfiguration createConfiguration(ArgResults argResults) => BorgConfiguration(
      dartSdkPath: _getDartSdkOption(argResults),
      flutterSdkPath: _getFlutterSdkOption(argResults),
      pathsToScan: _getPathsMultiOption(argResults),
      excludedPaths: _getExcludesMultiOption(argResults),
    );
