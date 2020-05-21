#!/bin/bash -ex

dart bin/main.dart probe --verbose
dart bin/main.dart evolve --dry-run --exclude test/integration_test_sets/package_with_inconsistent_dep_spec --verbose
dartanalyzer --fatal-hints .
pub run test
pub run dependency_validator --ignore=functional_data_generator,sum_types_generator,test_coverage
dev/format_dart_code.sh --set-exit-if-changed
#dev/generate_code.sh
pub publish --dry-run
