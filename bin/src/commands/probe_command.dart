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

import '../options/correct.dart';
import '../options/lock.dart';
import '../options/verbose.dart';
import '../options/yaml.dart';
import '../utils/borg_exception.dart';
import 'probe_command_runner.dart';

// ignore_for_file: avoid_print

class ProbeCommand extends Command<void> {
  ProbeCommand() {
    configurationFactory.populateConfigurationArgs(argParser);
    addPubspecYamlFlag(argParser);
    addPubspecLockFlag(argParser);
    addVerboseFlag(argParser);
    addCorrectFlag(argParser);
  }

  @override
  String get description =>
      'Checks consistency of Dart dependendencies across multiple packages.';

  @override
  String get name => 'probe';

  @override
  void run() => exitWithMessageOnBorgException(
        action: () => ProbeCommandRunner(
          configurationFactory,
          argResults!,
        ).run(),
        exitCode: 255,
      );

  final BorgConfigurationFactory configurationFactory =
      BorgConfigurationFactory();
}
