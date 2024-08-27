/// framework - state_provider
/// Created by xhz on 8/27/24

import 'package:flutter/widgets.dart';

mixin _StateNotifier<T extends StatefulWidget> on State<T> {
  @protected
  void stateDispose() {
    super.dispose();
  }
}

abstract class StateProvider<T extends StatefulWidget> extends State<T> with _StateNotifier<T>, ChangeNotifier {
  static StateProvider<T> watch<T extends StatefulWidget>(BuildContext context) {
    final _DataProvider<T>? provider = context.dependOnInheritedWidgetOfExactType<_DataProvider<T>>();
    if (provider == null) {
      throw FlutterError('StateProvider.of() called with a context that does not contain a StateProvider<$T>.');
    }
    return provider.notifier!;
  }

  static StateProvider<T> read<T extends StatefulWidget>(BuildContext context) {
    final _DataProvider<T>? provider = context.getInheritedWidgetOfExactType<_DataProvider<T>>();
    if (provider == null) {
      throw FlutterError('StateProvider.read() called with a context that does not contain a StateProvider<$T>.');
    }
    return provider.notifier!;
  }

  @override
  @mustCallSuper
  void dispose() {
    // ChangeNotifier dispose
    super.dispose();
    // State dispose
    stateDispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DataProvider<T>(notifier: this, child: buildContent() ?? const SizedBox.shrink());
  }

  @protected
  Widget? buildContent() => null;
}

class _DataProvider<T extends StatefulWidget> extends InheritedNotifier<StateProvider<T>> {
  const _DataProvider({required super.child, required super.notifier});
}
