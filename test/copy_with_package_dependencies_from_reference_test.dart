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

import 'package:borg/borg.dart';
import 'package:test/test.dart';

import 'dependency_test_dataset.dart';

void main() {
  group('$copyWithPackageDependenciesFromReference', () {
    group('provided with empty reference list', () {
      final deps = [directHostedXv1];
      final r = copyWithPackageDependenciesFromReference(deps, []);
      test('it copies the provided dependencies', () {
        expect(r, deps);
      });
    });

    group('provided with matching reference', () {
      final refs = [directHostedXv2];
      final r =
          copyWithPackageDependenciesFromReference([directHostedXv1], refs);
      test('it provides the reference dependency', () {
        expect(r, refs);
      });
    });

    group(
      'provided with matching hosted reference with different dependency type',
      () {
        final r = copyWithPackageDependenciesFromReference(
          [directHostedXv1],
          [transitiveHostedXv2],
        );
        test('it corrects the reference without modifying dependency type', () {
          expect(r, [directHostedXv2]);
        });
      },
    );

    group('provided with matching sdk reference with different dependency type',
        () {
      final r = copyWithPackageDependenciesFromReference(
          [directSdkXv1], [transitiveSdkXv2]);
      test('it corrects the reference without modifying dependency type', () {
        expect(r, [directSdkXv2]);
      });
    });

    group('provided with matching git reference with different dependency type',
        () {
      final r = copyWithPackageDependenciesFromReference(
          [directGitXv1], [transitiveGitXv2]);
      test('it corrects the reference without modifying dependency type', () {
        expect(r, [directGitXv2]);
      });
    });

    group(
        'provided with matching path reference with different dependency type',
        () {
      final r = copyWithPackageDependenciesFromReference(
          [directPathXv1], [transitivePathXv2]);
      test('it corrects the reference without modifying dependency type', () {
        expect(r, [directPathXv2]);
      });
    });
  });
}
