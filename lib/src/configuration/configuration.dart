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

// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';
import 'package:plain_optional/plain_optional.dart';

// ignore_for_file: sort_constructors_first

@immutable
class BorgConfiguration {
  final Optional<String> dartSdkPath;
  final Optional<String> flutterSdkPath;
  final Iterable<String> pathsToScan;
  final Iterable<String> excludedPaths;

  const BorgConfiguration({
    this.dartSdkPath = const Optional.none(),
    this.flutterSdkPath = const Optional.none(),
    this.pathsToScan = const [],
    this.excludedPaths = const [],
  });

  factory BorgConfiguration.fromJson(Map<String, dynamic> json) => BorgConfiguration(
        dartSdkPath: _getString(json, _dartSdkToken),
        flutterSdkPath: _getString(json, _flutterSdkToken),
        pathsToScan: _getStringIterable(json, _includeToken),
        excludedPaths: _getStringIterable(json, _excludeToken),
      );
}

Optional<String> _getString(Map<String, dynamic> json, String key) {
  if (json.containsKey(key)) {
    return Optional(json[key] as String); // ignore: avoid_as
  } else {
    return const Optional.none();
  }
}

Iterable<String> _getStringIterable(Map<String, dynamic> json, String key) {
  if (json.containsKey(key)) {
    final dynamic value = json[key];
    if (value is String) {
      return [value];
    } else {
      // ignore: avoid_as, avoid_annotating_with_dynamic
      return (value as Iterable).map((dynamic e) => e as String);
    }
  } else {
    return [];
  }
}

const _excludeToken = 'exclude';
const _includeToken = 'include';
const _dartSdkToken = 'dart_sdk';
const _flutterSdkToken = 'flutter_sdk';
