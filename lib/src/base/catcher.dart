/// framework - catcher
/// Created by xhz on 8/22/24

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract mixin class Catcher {
  static late final RawReceivePort _recvPort;

  static void init({required Catcher delegate}) {
    // Enable ErrorWidget when release mode
    ErrorWidget.builder = (FlutterErrorDetails details) {
      final Object exception = details.exception;
      return ErrorWidget.withDetails(
        message: details.exceptionAsString(),
        error: exception is FlutterError ? exception : null,
      );
    };
    FlutterError.onError = (FlutterErrorDetails details) {
      // Default error handling
      FlutterError.presentError(details);
      delegate.handleException(
        'Uncaught Flutter error',
        details.exception.toString(),
        (details.stack ?? StackTrace.current).toString(),
      );
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      delegate.handleException(
        'Uncaught platform error',
        error.toString(),
        stack.toString(),
      );
      return true;
    };

    // Enable runZonedGuarded
    runZonedGuarded(
      delegate.main,
      (Object error, StackTrace stack) {
        delegate.handleException(
          'Uncaught zone error',
          error.toString(),
          stack.toString(),
        );
      },
    );

    // Enable Isolate error handling
    _recvPort = RawReceivePort((List<dynamic> errorAndStack) {
      final String error = errorAndStack[0];
      final String? stack = errorAndStack[1];
      delegate.handleException(
        'Uncaught isolate error',
        error.toString(),
        stack ?? StackTrace.empty.toString(),
      );
    });
    Isolate.current.addErrorListener(_recvPort.sendPort);
  }

  void handleException(String name, String reason, String stackTrace);

  FutureOr<void> main();
}
