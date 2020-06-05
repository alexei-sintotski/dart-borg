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
