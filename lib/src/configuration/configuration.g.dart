// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

abstract class $BorgConfiguration {
  const $BorgConfiguration();

  Optional<String> get dartSdkPath;
  Optional<String> get flutterSdkPath;
  Iterable<String> get pathsToScan;
  Iterable<String> get excludedPaths;

  BorgConfiguration copyWith({
    Optional<String>? dartSdkPath,
    Optional<String>? flutterSdkPath,
    Iterable<String>? pathsToScan,
    Iterable<String>? excludedPaths,
  }) =>
      BorgConfiguration(
        dartSdkPath: dartSdkPath ?? this.dartSdkPath,
        flutterSdkPath: flutterSdkPath ?? this.flutterSdkPath,
        pathsToScan: pathsToScan ?? this.pathsToScan,
        excludedPaths: excludedPaths ?? this.excludedPaths,
      );

  BorgConfiguration copyUsing(
      void Function(BorgConfiguration$Change change) mutator) {
    final change = BorgConfiguration$Change._(
      this.dartSdkPath,
      this.flutterSdkPath,
      this.pathsToScan,
      this.excludedPaths,
    );
    mutator(change);
    return BorgConfiguration(
      dartSdkPath: change.dartSdkPath,
      flutterSdkPath: change.flutterSdkPath,
      pathsToScan: change.pathsToScan,
      excludedPaths: change.excludedPaths,
    );
  }

  @override
  String toString() =>
      "BorgConfiguration(dartSdkPath: $dartSdkPath, flutterSdkPath: $flutterSdkPath, pathsToScan: $pathsToScan, excludedPaths: $excludedPaths)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is BorgConfiguration &&
      other.runtimeType == runtimeType &&
      dartSdkPath == other.dartSdkPath &&
      flutterSdkPath == other.flutterSdkPath &&
      pathsToScan == other.pathsToScan &&
      excludedPaths == other.excludedPaths;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + dartSdkPath.hashCode;
    result = 37 * result + flutterSdkPath.hashCode;
    result = 37 * result + pathsToScan.hashCode;
    result = 37 * result + excludedPaths.hashCode;
    return result;
  }
}

class BorgConfiguration$Change {
  BorgConfiguration$Change._(
    this.dartSdkPath,
    this.flutterSdkPath,
    this.pathsToScan,
    this.excludedPaths,
  );

  Optional<String> dartSdkPath;
  Optional<String> flutterSdkPath;
  Iterable<String> pathsToScan;
  Iterable<String> excludedPaths;
}

// ignore: avoid_classes_with_only_static_members
class BorgConfiguration$ {
  static final dartSdkPath = Lens<BorgConfiguration, Optional<String>>(
    (dartSdkPathContainer) => dartSdkPathContainer.dartSdkPath,
    (dartSdkPathContainer, dartSdkPath) =>
        dartSdkPathContainer.copyWith(dartSdkPath: dartSdkPath),
  );

  static final flutterSdkPath = Lens<BorgConfiguration, Optional<String>>(
    (flutterSdkPathContainer) => flutterSdkPathContainer.flutterSdkPath,
    (flutterSdkPathContainer, flutterSdkPath) =>
        flutterSdkPathContainer.copyWith(flutterSdkPath: flutterSdkPath),
  );

  static final pathsToScan = Lens<BorgConfiguration, Iterable<String>>(
    (pathsToScanContainer) => pathsToScanContainer.pathsToScan,
    (pathsToScanContainer, pathsToScan) =>
        pathsToScanContainer.copyWith(pathsToScan: pathsToScan),
  );

  static final excludedPaths = Lens<BorgConfiguration, Iterable<String>>(
    (excludedPathsContainer) => excludedPathsContainer.excludedPaths,
    (excludedPathsContainer, excludedPaths) =>
        excludedPathsContainer.copyWith(excludedPaths: excludedPaths),
  );
}

// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: prefer_single_quotes
// ignore_for_file: public_member_api_docs
// ignore_for_file: require_trailing_commas
// ignore_for_file: unnecessary_this
