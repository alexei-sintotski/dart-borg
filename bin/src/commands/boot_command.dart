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
import 'package:borg/src/boot_mode.dart';
import 'package:borg/src/configuration/factory.dart';
import 'package:borg/src/context/borg_context.dart';
import 'package:borg/src/context/borg_context_factory.dart';

import '../options/boot_mode.dart';
import '../options/verbose.dart';
import '../utils/borg_exception.dart';
import 'boot_command_runner.dart';

// ignore_for_file: avoid_print

class BootCommand extends Command<void> {
  BootCommand() : context = contextFactory.createBorgContext() {
    configurationFactory.populateConfigurationArgs(argParser);
    addBootModeOption(argParser,
        defaultsTo: context.bootContext.iif(
          some: (ctx) => ctx.bootMode,
          none: () => BootMode.incremental,
        ));
    addVerboseFlag(argParser);
  }

  @override
  String get description =>
      'Executes "pub get" for multiple packages in repository.\n\n'
      'Packages to bootstrap can be specified as arguments. If no arguments '
      'are supplied, the command bootstraps all scanned packages.\n'
      '"flutter packages get" is used to resolve dependencies for Flutter '
      'packages.';

  @override
  String get name => 'boot';

  @override
  void run() => exitWithMessageOnBorgException(
      action: () => BootCommandRunner(
            configurationFactory,
            contextFactory,
            argResults!,
          ).run(),
      exitCode: 255);

  static final BorgConfigurationFactory configurationFactory =
      BorgConfigurationFactory();
  // ignore: prefer_const_constructors
  static final BorgContextFactory contextFactory = BorgContextFactory();
  final BorgContext context;
}
