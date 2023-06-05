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

// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';
import 'package:plain_optional/plain_optional.dart';

import '../boot_mode.dart';

// ignore_for_file: sort_constructors_first, avoid_as

@immutable
class BorgBootContext {
  final String dartSdkVersion;
  final String gitref;
  final Iterable<String> modifiedPackages;
  final Optional<String> flutterSdkVersion;
  final BootMode bootMode;

  const BorgBootContext({
    required this.dartSdkVersion,
    required this.gitref,
    required this.bootMode,
    this.modifiedPackages = const [],
    this.flutterSdkVersion = const Optional.none(),
  });

  factory BorgBootContext.fromJson(Map<String, dynamic> json) =>
      BorgBootContext(
        dartSdkVersion: json.containsKey(_dartSdkVersionKey)
            ? json[_dartSdkVersionKey] as String
            : '',
        gitref: json[_gitrefKey] as String,
        bootMode: json.containsKey(_bootModeKey)
            ? _parseBootMode(json[_bootModeKey] as String)
            : BootMode.basic,
        modifiedPackages: json.containsKey(_modifiedPackagesKey)
            ? (json[_modifiedPackagesKey] as List)
                // ignore: avoid_annotating_with_dynamic
                .map((dynamic p) => p as String)
            : [],
        flutterSdkVersion: json.containsKey(_flutterSdkVersionKey)
            ? Optional(json[_flutterSdkVersionKey] as String)
            : const Optional.none(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        _dartSdkVersionKey: dartSdkVersion,
        _gitrefKey: '"$gitref"',
        if (bootMode == BootMode.incremental) _bootModeKey: _incrementalValue,
        if (modifiedPackages.isNotEmpty)
          _modifiedPackagesKey: modifiedPackages.toList(),
        if (flutterSdkVersion.hasValue)
          _flutterSdkVersionKey: flutterSdkVersion.unsafe,
      };
}

BootMode _parseBootMode(String s) =>
    s == _incrementalValue ? BootMode.incremental : BootMode.basic;

const _gitrefKey = 'gitref';
const _modifiedPackagesKey = 'modified_packages';
const _dartSdkVersionKey = 'dart_sdk_version';
const _flutterSdkVersionKey = 'flutter_sdk_version';
const _bootModeKey = 'boot_mode';
const _incrementalValue = 'incremental';
