#!/bin/bash -ex

dart bin/main.dart probe --verbose
dart bin/main.dart evolve --dry-run --exclude test/integration_test_sets/package_with_inconsistent_dep_spec --verbose
dart bin/main.dart boot --mode=incremental
dart bin/main.dart boot --mode=basic
dart bin/main.dart boot --mode=incremental
dartanalyzer --fatal-hints .
pub run test
# pub run dependency_validator
dev/format_dart_code.sh --set-exit-if-changed
dev/generate_code.sh
pub publish --dry-run
