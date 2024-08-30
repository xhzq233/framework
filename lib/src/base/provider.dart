/// framework - state_provider
/// Created by xhz on 8/27/24

import 'package:flutter/widgets.dart';

mixin _StateNotifier<T extends StatefulWidget> on State<T> {
  @protected
  void stateDispose() {
    super.dispose();
  }
}

/// Provider 类似于 ViewModel，用于绑定数据和 UI，永远使提供的数据保持最新
/// Provider 如何使用可参考 ![](https://docs.flutter.dev/data-and-backend/state-mgmt/simple#changenotifierprovider)
///
/// Example:
/// ```
/// class MyProvider extends Provider {}
/// ProviderWidget(
///  provider: MyProvider(),
///  child: Builder(
///     builder: (context) {
///         // 通过 Provider.watch 监听 Provider 实例
///         final myNotifier = Provider.watch<MyProvider>(context);
///         // 通过 Provider.read 获取 Provider 实例
///         final myNotifier = Provider.read<MyProvider>(context);
///         return Text(myNotifier.someValue);
///     }),
///  )
/// ```
///
/// 最佳实践：
/// ProviderWidget 和 Provider.read 放 Widget 树何处都行，根据 Provider 掌管的 UI 决定
/// 但是 Provider.watch 要尽量往下，避免 rebuild 太大的树
abstract class Provider with ChangeNotifier {
  static T watch<T extends Listenable>(BuildContext context) {
    final ProviderWidget<T>? provider = context.dependOnInheritedWidgetOfExactType<ProviderWidget<T>>();
    if (provider == null) {
      throw FlutterError('Provider.watch() called with a context that does not contain a Provider<$T>.');
    }
    return provider.notifier!;
  }

  static T read<T extends Listenable>(BuildContext context) {
    final ProviderWidget<T>? provider = context.getInheritedWidgetOfExactType<ProviderWidget<T>>();
    if (provider == null) {
      throw FlutterError('Provider.read() called with a context that does not contain a Provider<$T>.');
    }
    return provider.notifier!;
  }
}

abstract class StateProvider<T extends StatefulWidget> extends State<T> with _StateNotifier<T>, ChangeNotifier {
  @override
  @mustCallSuper
  void dispose() {
    // ChangeNotifier dispose
    super.dispose();
    // State dispose
    stateDispose();
  }
}

class ProviderWidget<T extends Listenable> extends InheritedNotifier<T> {
  const ProviderWidget({super.key, required T provider, required super.child}) : super(notifier: provider);
}
