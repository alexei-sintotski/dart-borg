// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

// ignore_for_file: join_return_with_assignment
// ignore_for_file: avoid_classes_with_only_static_members
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
abstract class $BorgConfiguration {
  const $BorgConfiguration();
  Optional<String> get dartSdkPath;
  Optional<String> get flutterSdkPath;
  Iterable<String> get pathsToScan;
  Iterable<String> get excludedPaths;
  BorgConfiguration copyWith(
          {Optional<String> dartSdkPath,
          Optional<String> flutterSdkPath,
          Iterable<String> pathsToScan,
          Iterable<String> excludedPaths}) =>
      BorgConfiguration(
          dartSdkPath: dartSdkPath ?? this.dartSdkPath,
          flutterSdkPath: flutterSdkPath ?? this.flutterSdkPath,
          pathsToScan: pathsToScan ?? this.pathsToScan,
          excludedPaths: excludedPaths ?? this.excludedPaths);
  @override
  String toString() =>
      "BorgConfiguration(dartSdkPath: $dartSdkPath, flutterSdkPath: $flutterSdkPath, pathsToScan: $pathsToScan, excludedPaths: $excludedPaths)";
  @override
  bool operator ==(dynamic other) =>
      other.runtimeType == runtimeType &&
      dartSdkPath == other.dartSdkPath &&
      flutterSdkPath == other.flutterSdkPath &&
      pathsToScan == other.pathsToScan &&
      excludedPaths == other.excludedPaths;
  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + dartSdkPath.hashCode;
    result = 37 * result + flutterSdkPath.hashCode;
    result = 37 * result + pathsToScan.hashCode;
    result = 37 * result + excludedPaths.hashCode;
    return result;
  }
}

class BorgConfiguration$ {
  static final dartSdkPath = Lens<BorgConfiguration, Optional<String>>(
      (s_) => s_.dartSdkPath,
      (s_, dartSdkPath) => s_.copyWith(dartSdkPath: dartSdkPath));
  static final flutterSdkPath = Lens<BorgConfiguration, Optional<String>>(
      (s_) => s_.flutterSdkPath,
      (s_, flutterSdkPath) => s_.copyWith(flutterSdkPath: flutterSdkPath));
  static final pathsToScan = Lens<BorgConfiguration, Iterable<String>>(
      (s_) => s_.pathsToScan,
      (s_, pathsToScan) => s_.copyWith(pathsToScan: pathsToScan));
  static final excludedPaths = Lens<BorgConfiguration, Iterable<String>>(
      (s_) => s_.excludedPaths,
      (s_, excludedPaths) => s_.copyWith(excludedPaths: excludedPaths));
}

// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: prefer_single_quotes
// ignore_for_file: public_member_api_docs
