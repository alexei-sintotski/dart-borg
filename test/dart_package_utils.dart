import 'package:borg/src/dart_package/dart_package.dart';
import 'package:plain_optional/plain_optional.dart';

DartPackage dartPackage(String name) => DartPackage(
      path: '/$name',
      tryToReadFileSync: (path) {
        if (path.endsWith('pubspec.yaml')) {
          return Optional('name: $name');
        }

        return const Optional.none();
      },
    );
