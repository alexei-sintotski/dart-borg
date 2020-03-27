# Dart borg [![Build Status](https://travis-ci.org/alexei-sintotski/dart-borg.svg?branch=master)](https://travis-ci.org/alexei-sintotski/darf-borg) [![codecov](https://codecov.io/gh/alexei-sintotski/dart-borg/branch/master/graph/badge.svg)](https://codecov.io/gh/alexei-sintotski/dart-borg) [![pubspec_lock version](https://img.shields.io/pub/v/borg?label=borg)](https://pub.dev/packages/borg)

Command-line tool to support consistent configuration management of Dart packages in mono repository

Features available in the current version:

* Consistency check on use of Dart dependencies

Feature roadmap (in the order of priority):

| version | Major feature                                                                      |
|---------|------------------------------------------------------------------------------------|
| 0.2     | Consistency check on use of SDKs (Dart, Flutter, etc.)                             |
| 1.0     | Consistency check on package specifications in pubspec.yaml files                  |
| 1.1     | Consistent upgrade of external dependencies across repository                      |
| 1.2     | Correction of configuration of a Dart package newly added to the mono repository   |

# Installation

The tool is implemented in Dart, please make sure [Dart runtime](https://dart.dev/get-dart) is installed on your system.

Type in the command line `pub global activate borg`

After this, you should be able to execute the tool from command-line: `borg`.

If the tool cannot be found, please make sure that your
[Dart system cache](https://dart.dev/tools/pub/glossary#system-cache) is in your PATH.

# Command-line interface

The tool scans repository for Dart packages and automatically finds them.

The command-line interface provides options to include and exclude locations
for recursive scans (the glob syntax is supported).

The tool is self documented, please execute it to get detailed information on the command-line options:
```
$ borg
Command-line tool to support consistent configuration management of Dart packages in mono repository
STILL UNDER DEVELOPMENT
This version supports the following features
* Consistency check on use of Dart dependencies

Usage: borg <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  probe   Checks consistency of Dart dependendencies across multiple packages

Run "borg help <command>" for more information about a command.
```

# Command: probe

## Inconsistency detection

In case of detected inconsistencies the tool provides aggregated report on detected issues and returns with exit code 1:

```
$ borg probe 
Found 2 pubspec.lock files
Analyzing dependencies...

yaml: inconsistent use detected
        Version 2.2.0 is used by:
                ./pubspec.lock
        Version 2.2.1 is used by:
                ./test/pubspec.lock

FAILUE: Inconsistent use of external dependencies detected!
```

## Output in case of consistent configuration

In case of consistent usage of dependencies the tool returns with exit code 0:

```
$ borg probe 
Found 1 pubspec.lock files
Analyzing dependencies...

SUCCESS: All packages use consistent set of external dependencies
```

## Output in case of suspicious input

The tool issues a warning and exits with code 2 in case scan did not find pubspec.lock files:

```
$ borg probe --exclude .
Found 0 pubspec.lock files

WARNING: No configuration files selected for analysis
```

# API

If the standard command-line tool does not fit your use cases, its essential logic can be accessed via Dart API.
In order to use it, just refer to the package `borg` as a dependency in your `pubspec.yaml`.

## Consistency check on use of Dart dependencies

This check is performed by a single function:

`List<PackageUsageReport> findInconsistentDependencies(Map<String, PubspecLock> pubspecLocks)`.

As input, this function accepts content of `pubspec.lock` files with labels identifying them (e.g., paths).
Checkout the Dart package  [pubspec_lock](https://pub.dev/packages/pubspec_lock) for details on the input data format and
options to import content of `pubspec.lock` files.

After execution, this function produces a report on inconsistent usage of external dependencies.

If the report is empty, the usage of dependencies is consistent across all checked Dart packages.

```
/// Stores report data on dependency usage. Once instance stores data on usage of a single dependency across
/// multiple Dart packages.

@immutable
@FunctionalData()
class PackageUsageReport extends $PackageUsageReport {
  /// The constructor is used to create report
  const PackageUsageReport({@required this.dependencyName, @required this.references});

  final String dependencyName;

  /// Usage map: Dependency version => list of pubspec.lock files using it
  @CustomEquality(DeepCollectionEquality())
  final Map<PackageDependency, List<String>> references;
}
```
See Dart package [pubspec_lock](https://pub.dev/packages/pubspec_lock) for details on PackageDependency data structure.
