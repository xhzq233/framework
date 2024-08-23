/// framework - catcher
/// Created by xhz on 8/23/24

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/base.dart';

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Material(
        color: CupertinoColors.systemRed,
        child: TextButton(
          onPressed: () => throw StateError('test error'),
          child: const Text('click me'),
        ));
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _Home(),
    );
  }
}

class _CatcherImpl with Catcher {
  @override
  void handleException(String name, String reason, String stackTrace) {
    print('name: $name, reason: $reason, stackTrace: $stackTrace');
  }

  @override
  void main() {
    runApp(const _App());
  }
}

void main() {
  Catcher.init(delegate: _CatcherImpl());
}
