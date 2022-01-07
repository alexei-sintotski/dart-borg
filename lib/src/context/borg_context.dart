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

import 'borg_boot_context.dart';

// ignore_for_file: sort_constructors_first

@immutable
class BorgContext {
  final Optional<BorgBootContext> bootContext;

  const BorgContext({this.bootContext = const Optional.none()});

  BorgContext copyWith({Optional<BorgBootContext>? bootContext}) =>
      BorgContext(bootContext: bootContext ?? this.bootContext);

  factory BorgContext.fromJson(Map<String, dynamic>? json) => BorgContext(
        bootContext: json == null
            ? const Optional.none()
            : json.containsKey(_bootContextKey)
                ? Optional(BorgBootContext.fromJson(
                    // ignore: avoid_as
                    json[_bootContextKey] as Map<String, dynamic>,
                  ))
                : const Optional.none(),
      );

  Map<String, dynamic> toJson() => bootContext.iif(
        some: (bootCtx) => <String, dynamic>{_bootContextKey: bootCtx.toJson()},
        none: () => const <String, dynamic>{},
      );
}

const _bootContextKey = 'last_successful_bootstrap';
