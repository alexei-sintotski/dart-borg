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

import 'dart:convert';

import 'package:json2yaml/json2yaml.dart';
import 'package:meta/meta.dart';
import 'package:plain_optional/plain_optional.dart';
import 'package:yaml/yaml.dart';

import '../utils/file_io.dart';
import 'borg_context.dart';

@immutable
class BorgContextFactory {
  const BorgContextFactory({
    Optional<String> Function(String) tryToReadFileSync = tryToReadFileSync,
    void Function(String, String) saveStringToFileSync = saveStringToFileSync,
  })  : _tryToReadFileSync = tryToReadFileSync,
        _saveStringToFileSync = saveStringToFileSync;

  final Optional<String> Function(String) _tryToReadFileSync;
  final void Function(String, String) _saveStringToFileSync;

  BorgContext createBorgContext() => _tryToReadFileSync(pathToContextFile).iif(
        // ignore: avoid_as
        some: (content) => BorgContext.fromJson(
          // ignore: avoid_as
          json.decode(json.encode(loadYaml(content))) as Map<String, dynamic>,
        ),
        none: () => const BorgContext(),
      );

  void save({
    required BorgContext context,
  }) =>
      _saveStringToFileSync(
        pathToContextFile,
        json2yaml(context.toJson()),
      );
}

const pathToContextFile = '.dart_tool/borg/context.yaml';
