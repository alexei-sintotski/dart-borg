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

import 'package:pubspec_lock/pubspec_lock.dart';

const rawDirectHostedXv1 = HostedPackageDependency(
  package: 'x',
  version: '1.0.0',
  name: 'x',
  url: 'url',
  type: DependencyType.direct,
);
const directHostedXv1 = PackageDependency.hosted(rawDirectHostedXv1);

final HostedPackageDependency rawDirectHostedXv2 = rawDirectHostedXv1.copyWith(
  version: '2.0.0',
);
final PackageDependency directHostedXv2 =
    PackageDependency.hosted(rawDirectHostedXv2);

final HostedPackageDependency rawTransitiveHostedXv2 =
    rawDirectHostedXv2.copyWith(
  type: DependencyType.transitive,
);
final PackageDependency transitiveHostedXv2 =
    PackageDependency.hosted(rawTransitiveHostedXv2);

const rawDirectSdkXv1 = SdkPackageDependency(
  package: 'x',
  version: '1.0.0',
  description: 'sdk',
  type: DependencyType.direct,
);
const directSdkXv1 = PackageDependency.sdk(rawDirectSdkXv1);

final SdkPackageDependency rawDirectSdkXv2 = rawDirectSdkXv1.copyWith(
  version: '2.0.0',
);
final PackageDependency directSdkXv2 = PackageDependency.sdk(rawDirectSdkXv2);

final SdkPackageDependency rawTransitiveSdkXv2 = rawDirectSdkXv2.copyWith(
  type: DependencyType.transitive,
);
final PackageDependency transitiveSdkXv2 =
    PackageDependency.sdk(rawTransitiveSdkXv2);

const rawDirectGitXv1 = GitPackageDependency(
  package: 'x',
  version: '1.0.0',
  ref: 'ref',
  url: 'url',
  path: 'path',
  resolvedRef: 'ref',
  type: DependencyType.direct,
);
const directGitXv1 = PackageDependency.git(rawDirectGitXv1);

final GitPackageDependency rawDirectGitXv2 = rawDirectGitXv1.copyWith(
  version: '2.0.0',
);
final PackageDependency directGitXv2 = PackageDependency.git(rawDirectGitXv2);

final GitPackageDependency rawTransitiveGitXv2 = rawDirectGitXv2.copyWith(
  type: DependencyType.transitive,
);
final PackageDependency transitiveGitXv2 =
    PackageDependency.git(rawTransitiveGitXv2);

const rawDirectPathXv1 = PathPackageDependency(
  package: 'x',
  version: '1.0.0',
  path: 'path',
  relative: true,
  type: DependencyType.direct,
);
const directPathXv1 = PackageDependency.path(rawDirectPathXv1);

final PathPackageDependency rawDirectPathXv2 = rawDirectPathXv1.copyWith(
  version: '2.0.0',
);
final PackageDependency directPathXv2 =
    PackageDependency.path(rawDirectPathXv2);

final PathPackageDependency rawTransitivePathXv2 = rawDirectPathXv2.copyWith(
  type: DependencyType.transitive,
);
final PackageDependency transitivePathXv2 =
    PackageDependency.path(rawTransitivePathXv2);
