import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.contains('clean')) {
    _pInfo('Cleaning git hooks');
    final preCommitHook = File('.git/hooks/pre-commit');
    if (await preCommitHook.exists()) {
      await preCommitHook.delete();
    }

    final prePushHook = File('.git/hooks/pre-push');
    if (await prePushHook.exists()) {
      await prePushHook.delete();
    }
    return;
  } else if (args.contains('pre-commit')) {
    _pInfo('Running dart format');
    final ProcessResult changedFiles = await _runCommand('git', ['diff', '--cached', '--name-only'], noStdout: true);
    final Iterable<String> files = changedFiles.stdout
        .toString()
        .split('\n')
        .where((element) => element.endsWith('.dart'))
        .toList(growable: false);
    if (files.isEmpty) {
      _pInfo('No Dart files to format');
      return;
    }

    // Run dart format -l120 on the filtered list of file
    final formatRes = await _runCommand('dart', ['format', '-l120', ...files]);
    final tryAddFiles = formatRes.stdout
        .toString()
        .split('\n')
        .where((element) => element.endsWith('.dart'))
        .map((e) => e.replaceFirst('Formatted ', '').trim())
        .toList(growable: false);
    if (tryAddFiles.isNotEmpty) {
      _pInfo('Adding formatted files to commit:\n$tryAddFiles');
      await _runCommand('git', ['add', ...tryAddFiles]);
    }
    _pInfo('Finished running dart format');
    return;
  } else if (args.contains('pre-push')) {
    _pInfo('Running flutter analyze');
    // await _runCommand('flutter', ['analyze', '--no-pub', '--no-fatal-warnings', '--no-fatal-infos', 'lib']);
    _pInfo('Finished running flutter analyze');
    return;
  } else if (args.contains('setup')) {
    _setupHook('pre-commit', r'''
#!/usr/bin/env bash

# Dart run pre-commit, if exit code is not 0, exit with error code
dart run tools/git_hooks.dart pre-commit || exit 1
''');

    _setupHook('pre-push', r'''
#!/usr/bin/env bash

# Dart run pre-push, if exit code is not 0, exit with error code
dart run tools/git_hooks.dart pre-push || exit 1
''');
  }
}

Future<void> _setupHook(String name, String value) async {
  _pInfo('Setting up $name hook');
  final preCommitHook = File('.git/hooks/$name');
  await preCommitHook.parent.create();
  await preCommitHook.writeAsString(value);

  if (!Platform.isWindows) {
    final result = await Process.run('chmod', ['a+x', preCommitHook.path]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    exitCode = result.exitCode;
  }
}

void _pInfo(String message) {
  print('\x1B[32m$message\x1B[0m');
}

void _pError(String message) {
  print('\x1B[31m$message\x1B[0m');
}

Future<ProcessResult> _runCommand(String command, List<String> args, {bool noStdout = false}) async {
  final result = await Process.run(command, args);
  if (!noStdout) {
    stdout.write(result.stdout);
  }
  exitCode = result.exitCode;
  if (exitCode != 0) {
    _pError('Error running $command ${args.join(' ')}');
    _pError(result.stderr.toString());
    exit(exitCode);
  }
  return result;
}
