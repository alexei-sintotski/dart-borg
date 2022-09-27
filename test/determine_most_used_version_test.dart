import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

import '../bin/src/utils/correct_package_dependency.dart';

void main() {
  group('$determineMostUsedVersion', () {
    test('returns the most used version', () {
      final result = determineMostUsedVersion({
        const PackageDependency.hosted(
          HostedPackageDependency(
            package: 'foo',
            version: '1.0',
            url: '',
            type: DependencyType.direct,
            name: 'foo',
          ),
        ): ['package1', 'package2'],
        const PackageDependency.hosted(
          HostedPackageDependency(
            package: 'foo',
            version: '2.0',
            url: '',
            type: DependencyType.direct,
            name: 'foo',
          ),
        ): ['package3', 'package4', 'package5'],
      });

      expect(result, '2.0');
    });

    test("returns null of there isn't a single most used version", () {
      final result = determineMostUsedVersion({
        const PackageDependency.hosted(
          HostedPackageDependency(
            package: 'foo',
            version: '1.0',
            url: '',
            type: DependencyType.direct,
            name: 'foo',
          ),
        ): ['package1', 'package2'],
        const PackageDependency.hosted(
          HostedPackageDependency(
            package: 'foo',
            version: '2.0',
            url: '',
            type: DependencyType.direct,
            name: 'foo',
          ),
        ): ['package3', 'package4'],
      });

      expect(result, null);
    });
  });
}
