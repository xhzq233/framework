import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final arg = args.isEmpty ? 'format' : args[0];

  switch (arg) {
    case 'clean-hook':
      final preCommitHook = File('.git/hooks/pre-commit');
      if (await preCommitHook.exists()) {
        await preCommitHook.delete();
      }

      final prePushHook = File('.git/hooks/pre-push');
      if (await prePushHook.exists()) {
        await prePushHook.delete();
      }
      _pInfo('Cleaned git hooks');

    case 'setup-hook':
      _setupHook('pre-commit', r'''
#!/usr/bin/env bash

# Dart run pre-commit, if exit code is not 0, exit with error code
dart run tools/format.dart format --add --staged || exit 1
''');

      _setupHook('pre-push', r'''
#!/usr/bin/env bash

# Dart run pre-push, if exit code is not 0, exit with error code
dart run tools/format.dart analyze || exit 1
''');
    case 'format':
      Iterable<String> changedFiles = await _changedFiles(args.contains('--staged'));
      final bool add = args.contains('--add');
      if (File('.format-ignore').existsSync()) {
        String clangIgnore = const Utf8Decoder(allowMalformed: true)
            .convert(File('.format-ignore').readAsBytesSync())
            .trim()
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.startsWith('#') == false)
            .join('|');

        print('Ignoring files: $clangIgnore');

        final ignoreReg = RegExp(clangIgnore.replaceAll('.', '\\.').replaceAll('*', '.*'));
        changedFiles = changedFiles.where((e) => ignoreReg.hasMatch(e) == false);
      }

      await _dartFormat(
        changedFiles.where((element) => element.endsWith('.dart')).toList(growable: false),
        add,
      );
      final clangFiles = changedFiles.where((e) => _clangFileFilter.hasMatch(e)).toList(growable: false);
      await _clangFormat(clangFiles, add);

    case 'analyze':
      _pInfo('Running flutter analyze');
      // await _runCommand('flutter', ['analyze', '--no-pub', '--no-fatal-warnings', '--no-fatal-infos', 'lib']);
      _pInfo('Finished running flutter analyze');

    default:
      print('''
Usage: format.dart <command> [options]

Commands:
  clean-hook: Remove pre-commit and pre-push hooks
  setup-hook: Setup pre-commit and pre-push hooks
  format: Format staged files (default)
  analyze: Run flutter analyze
  
Options:
  --staged: Only format staged files
  --add: Add formatted files to commit
  
Examples:
  dart run tools/format.dart format --add --staged
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

Future<ProcessResult> _runCommand(String command, List<String> args, {bool needStdout = true}) async {
  final result = await Process.run(command, args);
  if (needStdout) {
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

Future<Iterable<String>> _changedFiles([bool staged = true]) async {
  // Filter deleted files
  final ProcessResult changedFiles = await _runCommand(
    'git',
    ['diff', '--name-only', if (staged) '--staged', '--diff-filter=d', 'HEAD'],
    needStdout: false,
  );
  return changedFiles.stdout.toString().split('\n');
}

Future<void> _dartFormat(List<String> files, [bool? add]) async {
  if (files.isEmpty) {
    _pInfo('No Dart files to format');
    return;
  }
  // Run dart format -l120 on the filtered list of file
  final formatRes = await _runCommand('dart', ['format', '-l120', ...files]);
  if (add == true) {
    final tryAddFiles = formatRes.stdout
        .toString()
        .split('\n')
        .where((element) => element.endsWith('.dart'))
        .map((e) => e.replaceFirst('Formatted ', '').trim())
        .toList(growable: false);
    if (tryAddFiles.isNotEmpty) {
      _pInfo('Adding formatted files to commit: $tryAddFiles');
      await _runCommand('git', ['add', ...tryAddFiles]);
    }
  }
  _pInfo('Finished running dart format');
}

Future<void> _clangFormat(List<String> files, [bool? add]) async {
  if (files.isEmpty) {
    _pInfo('No C/C++/Objc files to format');
    return;
  }
  print('Formatting files: $files');

  // Run clang format on the filtered list of file
  await _runCommand('clang-format', ['-i', ...files, '--verbose']);
  if (add == true) {
    _pInfo('Adding formatted files to commit');
    await _runCommand('git', ['add', ...files]);
  }
  _pInfo('Finished running clang format');
}

final _clangFileFilter = RegExp(r'\.(c|cc|cpp|h|hpp|mm|m)$');
