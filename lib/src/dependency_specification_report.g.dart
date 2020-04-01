// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dependency_specification_report.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

abstract class $PackageDependencySpecReport {
  dynamic get dependencyName;
  Map<PackageDependencySpec, List> get references;
  const $PackageDependencySpecReport();
  PackageDependencySpecReport copyWith({dynamic dependencyName, Map<PackageDependencySpec, List> references}) =>
      PackageDependencySpecReport(
          dependencyName: dependencyName ?? this.dependencyName, references: references ?? this.references);
  String toString() => "PackageDependencySpecReport(dependencyName: $dependencyName, references: $references)";
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

class PackageDependencySpecReport$ {
  static final dependencyName = Lens<PackageDependencySpecReport, dynamic>(
      (s_) => s_.dependencyName, (s_, dependencyName) => s_.copyWith(dependencyName: dependencyName));
  static final references = Lens<PackageDependencySpecReport, Map<PackageDependencySpec, List>>(
      (s_) => s_.references, (s_, references) => s_.copyWith(references: references));
}

// ignore_for_file: ARGUMENT_TYPE_NOT_ASSIGNABLE
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: always_require_non_null_named_parameters
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_classes_with_only_static_members
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
// ignore_for_file: implicit_dynamic_parameter
// ignore_for_file: join_return_with_assignment
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: prefer_asserts_with_message
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: prefer_single_quotes
// ignore_for_file: public_member_api_docs
// ignore_for_file: sort_constructors_first
// ignore_for_file: type_annotate_public_apis
