## [1.5.1] - Bootstrapping performance improvement
* Optimization: Much faster dependency analysis for incremental bootstrapping
* Kudos to @werediver and @spkersten for finding and fixing it!

## [1.5.0] - Deps
* Feature: "borg deps" lists external dependencies for multiple packages across repository
* Improvement: Packages without pubspec.lock are always bootstrapped in all modes

## [1.4.6] - Dart 2.12+ expects SDK specification in pubspec.yaml

## [1.4.5+1] - Dart 2.10 and upgraded dependencies

## [1.4.5] - 2020-09-20
* Feature: Incremental bootstrapping is the default bootstrapping mode
* Optimization: Massive improvement of performance of dependency analysis during incremental bootstrapping
* Bugfix: Incremental bootstrapping ignores deleted packages

## [1.4.4] - 2020-07-05
* Production-grade incremental bootstrapping
* Bootstrapping dependency analysis takes dependency overrides into account
* Unit test coverage improvements

## [1.4.3] - 2020-06-28
* Improved performance of incremental bootstrapping for massive changes of packages configuration

## [1.4.2] - 2020-06-08
Maturing of incremental bootstrapping implementation:
* Correct handling of rolled back changes of pubspec files
* Incremental bootstrapping is ignored when Dart version is changed between runs of borg boot
* Incremental bootstrapping is ignored when Flutter SDK version is changed between runs of borg boot
* Incremental bootstrapping is ignored when command line specifies packages to bootstrap
* Incremental bootstrapping ignores previous bootstrapping of specific (not all) packages
* Boot mode switch is persistent

## [1.4.1] - 2020-06-04
* Incremental bootstrapping takes dependencies between packages in the mono repository into account

## [1.4.0] - 2020-06-04
* Experimental support for incremental bootstrapping

## [1.3.2] - 2020-06-01
* Optimization: probe scans repository for packages only once
* Optimization: more efficient scan of Flutter repositories by built-in filtering of
  generated Flutter plug-in packages in .symlinks directories
* Optimization: Automatic detection of Dart packages in Flutter repositories and
  using faster `pub get` to bootstrap them i.s.o. `flutter packages get`

## [1.3.1] - 2020-05-23
* Bugfix: Incorrect bootstrapping of Flutter packages

## [1.3.0] - 2020-05-23
* borg boot -- Command to execute `pub get` for multiple packages across repository

## [1.2.0+1] - 2020-05-20
* README.md formatting fix

## [1.2.0] - 2020-05-20
* Configuration file support: borg.yaml

## [1.1.0] - 2020-04-19
* borg evolve -- command for consistent upgrade of all external dependencies across repository

## [1.0.0] - 2020-04-02
* Consistency check on package specifications in pubspec.yaml files

## [0.1.2+1] - 2020-03-27
* Dependency on args is relaxed to make compatible with stable Flutter release

## [0.1.2] - 2020-03-27
* Bugfix: Incorrect report generation

## [0.1.1] - 2020-03-27
* Bugfix: Dependency types are ignored during consistency analysis

## [0.1.0] - 2020-03-27
* Consistency check on use of Dart dependencies
