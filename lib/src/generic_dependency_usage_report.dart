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

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Data class to capture usage of a dependency by multiple Dart packages.
@immutable
class DependencyUsageReport<DependencyType> {
  /// The constructor is used to create report
  const DependencyUsageReport({@required this.dependencyName, @required this.references});

  /// Name of the package dependency
  final String dependencyName;

  /// Usage map: Dependency version => list of users
  final Map<DependencyType, List<String>> references;

  @override
  String toString() =>
      'DependencyUsageReport<$DependencyType>(dependencyName: $dependencyName, references: $references)';

  @override
  // ignore: avoid_annotating_with_dynamic
  bool operator ==(dynamic other) =>
      other.runtimeType == runtimeType &&
      dependencyName == other.dependencyName &&
      const DeepCollectionEquality().equals(references, other.references);

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + dependencyName.hashCode;
    result = 37 * result + const DeepCollectionEquality().hash(references);
    return result;
  }
}
