import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'logger_file_manager.dart';

var logger = TagLogger(Logger());

const testReleaseLog = false; // for local test only, should not commit true value

class TagLogger {
  final Logger instance;

  TagLogger(this.instance);

  void v(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    instance.t('<$tag> $message', error: error, stackTrace: stackTrace);
  }

  void d(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    instance.d('<$tag> $message', error: error, stackTrace: stackTrace);
  }

  void i(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    instance.i('<$tag> $message', error: error, stackTrace: stackTrace);
  }

  void w(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    instance.w('<$tag> $message', error: error, stackTrace: stackTrace);
  }

  void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (error != null) {
      BELogger.errorRecorder?.call(error, stackTrace, tag);
    }
    instance.e('<$tag> $message', error: error, stackTrace: stackTrace);
  }
}

typedef BELoggerErrorRecorder = void Function(dynamic exception, StackTrace? stackTrace, String reason);
typedef BELoggerReleaseMessageOutput = void Function(String message);

class BELogger {
  static BELoggerErrorRecorder? errorRecorder;
  static BELoggerReleaseMessageOutput? releaseMessageOutput;

  static void setupLogger([bool releaseLog = false]) {
    if (!releaseLog && !testReleaseLog && kDebugMode) {
      Logger.level = Level.trace;
      logger = TagLogger(Logger(
          filter: ProductionFilter(),
          printer: _TimePrinter(
            PrefixPrinter(PrettyPrinter(
              methodCount: 0,
              noBoxingByDefault: true,
              errorMethodCount: 8,
              lineLength: 120,
              // Android Studio配合插件显示颜色：https://plugins.jetbrains.com/plugin/7125-grep-console
              colors: false,
              printEmojis: true,
              printTime: false,
            )),
          )));
    } else {
      Logger.level = Level.info;
      logger = TagLogger(Logger(
          filter: ProductionFilter(),
          printer: SimplePrinter(
            colors: false,
            printTime: true,
          ),
          output: ThirdPartyLogOutput()));
    }
  }
}

class ThirdPartyLogOutput extends LogOutput {
  late final ConsoleOutput _consoleOutput = ConsoleOutput()..init();
  FileOutput? _fileOutput;

  ThirdPartyLogOutput() {
    LoggerFileManager.getLoggerFile(false).then((value) {
      _fileOutput = FileOutput(file: value)..init();
      logger.i('log', "====== Logger Init ======");
    });
  }

  @override
  void output(OutputEvent event) {
    if (testReleaseLog || kDebugMode) {
      _consoleOutput.output(event);
    }
    for (var element in event.lines) {
      BELogger.releaseMessageOutput?.call(element);
    }
    _fileOutput?.output(event);
  }

  @override
  Future<void> destroy() async {
    if (testReleaseLog) {
      await _consoleOutput.destroy();
    }
    await _fileOutput?.destroy();
  }
}

extension LogUtil on String {
  String trimLog([length = 100]) {
    return this.length > length ? substring(0, length) : this;
  }
}

class _TimePrinter extends LogPrinter {
  static final _format = DateFormat('MM/dd HH:mm:ss:S');

  final LogPrinter _realPrinter;

  _TimePrinter(this._realPrinter);

  @override
  List<String> log(LogEvent event) {
    final now = DateTime.now();
    var realLogs = _realPrinter.log(event);
    return realLogs.map((s) => '${_format.format(now)}$s').toList();
  }
}
