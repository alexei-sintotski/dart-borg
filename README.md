# Dart borg [![Build Status](https://travis-ci.org/alexei-sintotski/dart-borg.svg?branch=master)](https://travis-ci.org/alexei-sintotski/darf-borg) [![codecov](https://codecov.io/gh/alexei-sintotski/dart-borg/branch/master/graph/badge.svg)](https://codecov.io/gh/alexei-sintotski/dart-borg) [![pubspec_lock version](https://img.shields.io/pub/v/borg?label=borg)](https://pub.dev/packages/borg)

Dart borg is a command-line tool to support development teams working on large scale Dart and Flutter mono repositories.

Commands available in the latest release:

| Command | Description                                                                                           |
|---------|-------------------------------------------------------------------------------------------------------|
| boot    | Executes `pub get` / `flutter packages get` for multiple packages across repository.                   |
| deps    | Lists external dependencies of multiple packages across repository.                                    |
| evolve  | Upgrades all external dependencies consistently across repository.                                    |
| init    | Creates an initial borg configuration file to automate application of frequently used options.          |
| probe   | Checks consistency of specified and resolved Dart dependencies across repository.                      |

Feature roadmap:

| version | Major feature                                                                                                            |
|---------|--------------------------------------------------------------------------------------------------------------------------|
| 2.1     | Ability to define commands in the configuration file                                                                        |
| 2.2     | Upgrade of only selected (not all) external dependencies consistently across repository                                  |
| 2.3     | List outdated packages                                                                                                   |
| 2.4     | Pinning configuration of a new package with pubspec.lock without upgrading configuration of other packages in repository   |

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
Command-line tool for consistent configuration management of Dart packages in a mono repository

Usage: borg <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  boot     Executes "pub get" for multiple packages in repository
  evolve   Upgrade Dart dependencies consistently across multiple packages
  init     Generates configuration file borg.yaml in current directory
  probe    Checks consistency of Dart dependendencies across multiple packages

Run "borg help <command>" for more information about a command.
```

# Command: borg probe

## Inconsistency detection

In case of detected inconsistencies the tool provides aggregated report on detected issues and returns with exit code 1:

```
$ borg probe
Scanning for pubspec.yaml files... 2 files found
Analyzing dependency specifications...

Scanning for pubspec.lock files... 2 files found
Analyzing dependencies...

yaml: inconsistent use detected
        Version 2.2.0 is used by:
                ./pubspec.lock
        Version 2.2.1 is used by:
                ./test/pubspec.lock

FAILURE: Inconsistent use of external dependencies detected!
         Consider to use the --correct option to fix issues.
```

Inconsistencies found in pubspec.lock files can be corrected in semi-automatic mode using
the `--correct` command-line flag:

`borg probe --correct`

Use the `pick-most-used` flag to automatically pick the version the is used by
most packages:

`borg probe --correct --pick-most-used`

## Output in case of consistent configuration

In case of consistent usage of dependencies the tool returns with exit code 0:

```
$ borg probe 
Scanning for pubspec.yaml files... 2 files found
Analyzing dependency specifications...

Scanning for pubspec.lock files... 2 files found
Analyzing dependencies...

SUCCESS: All packages use consistent set of external dependencies
```

## Output in case of suspicious input

The tool issues a warning and exits with code 2 in case scan did not find pubspec.lock files:

```
$ borg probe --exclude .
Scanning for pubspec.yaml files... 0 files found

WARNING: No configuration files selected for analysis
```

# Command: borg evolve

This command upgrades all external dependencies of all selected packages consistently across repository:

```
$ borg evolve
Scanning for pubspec.yaml files... 3 files found

Resolving 11 direct external dependencies used by all found packages...
        resolved 61 direct and transitive external dependencies

Commencing evolution of 3 Dart packages...
[1/3] Evolving . ...
        json_annotation: 3.0.0 => 3.0.1

[2/3] Evolving test/evolve_integration_test_sets/package_with_pubspec_lock ... => up-to-date
[3/3] Evolving test/evolve_integration_test_sets/package_without_pubspec_lock ...
        pubspec.lock does not exist, creating one... => up-to-date

SUCCESS: 3 packages have been processed
```

The command supports dry mode to preview upgrade without modifying existing pubspec files.

## Path to Dart SDK

Internally, `borg` relies on the Dart `pub` tool to manage configuration of Dart packages. By default, it assumes `pub`
to be available at the path. If this is not the case, path to Dart SDK can be specified as a command-line argument:

```
borg evolve --dartsdk=~/dart
```

## Flutter support

`borg` supports repositories with apps using Flutter. For such repositories, path to Flutter SDK should be supplied
as a command-line argument.

```
borg evolve --fluttersdk=dev/flutter
```

Alternatively, path to Flutter SDK can be set with the environment variable `FLUTTER_ROOT`. Usage of `fluttersdk` in
`borg` command line is not required in this case.

# Command: borg boot

Executes `pub get` for multiple packages in a repository.

Packages to bootstrap can be specified as arguments. If no arguments supplied, the command bootstraps all scanned packages.

Borg supports bootstrapping of both Dart and Flutter packages:

* Flutter packages are bootstrapped using `flutter packages get` command. The tool recognizes Flutter packages by their
dependency on the package `flutter`. If path to the root of Flutter SDK is not specified, bootstrapping of such package
results in fatal errors with message to the user.

* Dart packages are always bootstrapped with `pub get`. The reason for this is that pub get has much higher performance
than its Flutter counterpart.

## Incremental bootstrapping

Execution of `pub get` / `flutter packages get` can take several minutes for large repositories of tens and hundreds of
packages. On the other hand, developer's workspace is updated typically in small steps, only several packages at a
time. Therefore, there should be no need to bootstrap the entire repository all the time, only the packages with
changed pubspec files and packages depending on them.

Every time `borg boot` is finished successfully, it records git commit at the end of its execution and stores to
file `.dart_tool/borg/context.yaml`. When developer executes the command in incremental boostrapping mode
(`borg boot --mode=incremental`), the tool compares the repository changes since the last successful boot and
executes `pub get` / `flutter packages get` only for packages with changed configuration and packages depending on them.

In some cases incremental bootstrapping is not available and basic bootstrapping is enforced:

* Developer uses command line to bootstrap specific packages
* `borg boot` detects Dart version update since the last successful bootstrapping
* `borg boot` detects Flutter SDK update since the last successful bootstrapping

Incremental bootstrapping is the default bootstrapping mode since version 1.4.5.

Please note that `borg boot --mode=basic` switches `borg boot` to basic mode for subsequent runs (The basic mode
executes `pub get` / `flutter packages get` for all found packages). This means that you do not need to specify boot
mode every time you run `borg boot`. `boot borg --mode=incremental` switches back to the incremental bootstrapping mode.

# Configuration file: borg.yaml

In case configuration options have to be specified for every run of the tool, `borg` provides possibility to avoid
long command lines with configuration file `borg.yaml`. Every time `borg` is executed, it checks out whether the file
exists in the current directory, reads it out, and uses its content to provide default values for its arguments.

Since the configuration file defines default values for command-line arguments, it can be overriden by using command line.

The following configuration options can be specified:

| YAML key    | Meaning                                                                         |
|-------------|---------------------------------------------------------------------------------|
| include     | List of locations to include for analysis (glob syntax supported)               |
| exclude     | List of locations to exclude from analysis (glob syntax supported)              |
| dart_sdk    | Path to Dart SDK                                                                |
| flutter_sdk | Path to root directory of Flutter SDK                                           |

The initial configuration file can be generated by using borg init command:

```
$ borg init
Initial configuration file is created.
```

# Command: borg deps

Lists external dependencies of multiple packages across repository.

Packages to analyze can be specified as arguments. If no arguments supplied, the command considers all scanned packages.

The command lists direct and transitive dependencies separately.

Since the notion of production/development dependencies is hard to define for a monorepo, analysis of these categories is
not implemented. Please use `pub deps` per package to distinguish these dependencies. Analysis of production/development
dependencies for the entire repository might be considered in the future.

# API

If the standard command-line tool does not fit your use cases, its essential logic can be accessed via Dart API.
In order to use it, just refer to the package `borg` as a dependency in your `pubspec.yaml`.

Please refer to the generated borg library documentation at
[pub.dev](https://pub.dev/documentation/borg/latest/borg/borg-library.html) for details.
