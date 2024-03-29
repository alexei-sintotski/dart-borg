/*
 * MIT License
 *
 * Copyright (c) 2020 Alexei Sintotski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import 'package:args/command_runner.dart';
import 'package:borg/src/configuration/factory.dart';

import '../options/verbose.dart';
import '../utils/borg_exception.dart';
import 'deps_command_runner.dart';

// ignore_for_file: avoid_print

class DepsCommand extends Command<void> {
  DepsCommand() {
    configurationFactory.populateConfigurationArgs(argParser);
    addVerboseFlag(argParser);
  }

  @override
  String get description =>
      'Lists external dependencies of multiple packages across repository.\n'
      'Considers all packages by default. To select a subset of packages, '
      'please specify package names in command line.';

  @override
  String get name => 'deps';

  @override
  void run() => exitWithMessageOnBorgException(
        action: () => DepsCommandRunner(
          configurationFactory,
          argResults!,
        ).run(),
        exitCode: 255,
      );

  final BorgConfigurationFactory configurationFactory =
      BorgConfigurationFactory();
}
