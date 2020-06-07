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

import '../utils/platform_version.dart' as platform;

// ignore_for_file: sort_constructors_first, avoid_as

@immutable
class BorgBootContext {
  BorgBootContext({
    @required this.gitref,
    String dartSdkVersion,
    this.modifiedPackages = const [],
  }) : dartSdkVersion = dartSdkVersion ?? platform.dartSdkVersion;

  final String dartSdkVersion;
  final String gitref;
  final Iterable<String> modifiedPackages;

  factory BorgBootContext.fromJson(Map<String, dynamic> json) => BorgBootContext(
        dartSdkVersion: json.containsKey(_dartSdkVersionKey) ? json[_dartSdkVersionKey] as String : '',
        gitref: json[_gitrefKey] as String,
        modifiedPackages: json.containsKey(_modifiedPackagesKey)
            // ignore: avoid_annotating_with_dynamic
            ? (json[_modifiedPackagesKey] as List).map((dynamic p) => p as String)
            : [],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        _dartSdkVersionKey: dartSdkVersion,
        _gitrefKey: '"$gitref"',
        if (modifiedPackages.isNotEmpty) _modifiedPackagesKey: modifiedPackages.toList(),
      };
}

const _gitrefKey = 'gitref';
const _modifiedPackagesKey = 'modified_packages';
const _dartSdkVersionKey = 'dart_sdk_version';
