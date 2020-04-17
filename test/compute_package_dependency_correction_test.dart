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

import 'package:borg/src/compute_package_dependency_correction.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

void main() {
  group('$computePackageDependencyCorrection', () {
    group('given empty reference', () {
      final deps = [_directHostedXv1];
      final r = computePackageDependencyCorrection(deps, []);
      test('it produces empty correction set', () {
        expect(r, isEmpty);
      });
    });

    group('given matching reference', () {
      final refs = [_directHostedXv2];
      final r = computePackageDependencyCorrection([_directHostedXv1], refs);
      test('it produces correction from the reference', () {
        expect(r, refs);
      });
    });

    group('given empty input', () {
      final r = computePackageDependencyCorrection([], [_directHostedXv2]);
      test('it produces empty correction set', () {
        expect(r, isEmpty);
      });
    });

    group('given reference equal to input', () {
      final deps = [_directHostedXv1];
      final r = computePackageDependencyCorrection(deps, deps);
      test('it produces empty correction set', () {
        expect(r, isEmpty);
      });
    });

    group('given reference equal to input except for dependency type', () {
      final deps = [_directHostedXv2];
      final refs = [_transitiveHostedXv2];
      final r = computePackageDependencyCorrection(deps, refs);
      test('it produces empty correction set', () {
        expect(r, isEmpty);
      });
    });

    group('given matching reference with different dependency type', () {
      final deps = [_directHostedXv1];
      final refs = [_transitiveHostedXv2];
      final r = computePackageDependencyCorrection(deps, refs);
      test('it produces correction with dependency type matching input', () {
        expect(r, [_directHostedXv2]);
      });
    });

    group('given matching sdk reference with different dependency type', () {
      final deps = [_directSdkXv1];
      final refs = [_transitiveSdkXv2];
      final r = computePackageDependencyCorrection(deps, refs);
      test('it produces correction with dependency type matching input', () {
        expect(r, [_directSdkXv2]);
      });
    });

    group('given matching git reference with different dependency type', () {
      final deps = [_directGitXv1];
      final refs = [_transitiveGitXv2];
      final r = computePackageDependencyCorrection(deps, refs);
      test('it produces correction with dependency type matching input', () {
        expect(r, [_directGitXv2]);
      });
    });

    group('given matching path reference with different dependency type', () {
      final deps = [_directPathXv1];
      final refs = [_transitivePathXv2];
      final r = computePackageDependencyCorrection(deps, refs);
      test('it produces correction with dependency type matching input', () {
        expect(r, [_directPathXv2]);
      });
    });
  });
}

const _rawDirectHostedXv1 = HostedPackageDependency(
  package: 'x',
  version: '1.0.0',
  name: 'x',
  url: 'url',
  type: DependencyType.direct,
);
const _directHostedXv1 = PackageDependency.hosted(_rawDirectHostedXv1);

final _rawDirectHostedXv2 = _rawDirectHostedXv1.copyWith(
  version: '2.0.0',
);
final _directHostedXv2 = PackageDependency.hosted(_rawDirectHostedXv2);

final _rawTransitiveHostedXv2 = _rawDirectHostedXv2.copyWith(
  type: DependencyType.transitive,
);
final _transitiveHostedXv2 = PackageDependency.hosted(_rawTransitiveHostedXv2);

const _rawDirectSdkXv1 = SdkPackageDependency(
  package: 'x',
  version: '1.0.0',
  description: 'sdk',
  type: DependencyType.direct,
);
const _directSdkXv1 = PackageDependency.sdk(_rawDirectSdkXv1);

final _rawDirectSdkXv2 = _rawDirectSdkXv1.copyWith(
  version: '2.0.0',
);
final _directSdkXv2 = PackageDependency.sdk(_rawDirectSdkXv2);

final _rawTransitiveSdkXv2 = _rawDirectSdkXv2.copyWith(
  type: DependencyType.transitive,
);
final _transitiveSdkXv2 = PackageDependency.sdk(_rawTransitiveSdkXv2);

const _rawDirectGitXv1 = GitPackageDependency(
  package: 'x',
  version: '1.0.0',
  ref: 'ref',
  url: 'url',
  path: 'path',
  resolvedRef: 'ref',
  type: DependencyType.direct,
);
const _directGitXv1 = PackageDependency.git(_rawDirectGitXv1);

final _rawDirectGitXv2 = _rawDirectGitXv1.copyWith(
  version: '2.0.0',
);
final _directGitXv2 = PackageDependency.git(_rawDirectGitXv2);

final _rawTransitiveGitXv2 = _rawDirectGitXv2.copyWith(
  type: DependencyType.transitive,
);
final _transitiveGitXv2 = PackageDependency.git(_rawTransitiveGitXv2);

const _rawDirectPathXv1 = PathPackageDependency(
  package: 'x',
  version: '1.0.0',
  path: 'path',
  relative: true,
  type: DependencyType.direct,
);
const _directPathXv1 = PackageDependency.path(_rawDirectPathXv1);

final _rawDirectPathXv2 = _rawDirectPathXv1.copyWith(
  version: '2.0.0',
);
final _directPathXv2 = PackageDependency.path(_rawDirectPathXv2);

final _rawTransitivePathXv2 = _rawDirectPathXv2.copyWith(
  type: DependencyType.transitive,
);
final _transitivePathXv2 = PackageDependency.path(_rawTransitivePathXv2);
