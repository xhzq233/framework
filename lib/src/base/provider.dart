/// framework - state_provider
/// Created by xhz on 8/27/24

import 'package:flutter/widgets.dart';

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
    context.dependOnInheritedWidgetOfExactType<ProviderWidget<T>>();
    return read<T>(context);
  }

  static T read<T extends Listenable>(BuildContext context) {
    final _ProviderElement<T>? providerElement =
        context.getElementForInheritedWidgetOfExactType<ProviderWidget<T>>() as _ProviderElement<T>?;
    if (providerElement == null) {
      throw FlutterError('Provider.read/watch() called with a context that does not contain a Provider<$T>.');
    }
    if (providerElement._providerInstance == null) {
      // lazy init provider
      providerElement._initProvider();
    }
    return providerElement._providerInstance!;
  }

  static T? maybeRead<T extends Listenable>(BuildContext context) {
    final _ProviderElement<T>? providerElement =
        context.getElementForInheritedWidgetOfExactType<ProviderWidget<T>>() as _ProviderElement<T>?;
    if (providerElement == null) {
      return null;
    }
    if (providerElement._providerInstance == null) {
      // lazy init provider
      providerElement._initProvider();
    }
    return providerElement._providerInstance;
  }
}

typedef ProviderBuilder<T> = T Function(BuildContext context);

class ProviderWidget<T extends Listenable> extends InheritedWidget {
  const ProviderWidget({
    super.key,
    required this.provider,
    required super.child,
  });

  final ProviderBuilder<T> provider;

  @override
  bool updateShouldNotify(covariant ProviderWidget<T> oldWidget) {
    return oldWidget.provider != provider;
  }

  @override
  InheritedElement createElement() => _ProviderElement<T>(this);
}

class _ProviderElement<T extends Listenable> extends InheritedElement {
  _ProviderElement(ProviderWidget<T> widget) : super(widget);

  @override
  ProviderWidget<T> get widget => super.widget as ProviderWidget<T>;

  bool _dirty = false;

  T? _providerInstance;

  void _initProvider() {
    _providerInstance = widget.provider.call(this);
    assert(_providerInstance != null, 'ProviderBuilder should not return null');
    _providerInstance?.addListener(_handleUpdate);
  }

  void _tryDispose() {
    _providerInstance?.removeListener(_handleUpdate);
    if (_providerInstance is ChangeNotifier) {
      (_providerInstance as ChangeNotifier).dispose();
    }
    _providerInstance = null;
  }

  @override
  void update(ProviderWidget<T> newWidget) {
    if (widget.provider != newWidget.provider) {
      _tryDispose();
    }
    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_dirty) {
      notifyClients(widget);
    }
    return super.build();
  }

  void _handleUpdate() {
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void notifyClients(ProviderWidget<T> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  void unmount() {
    _tryDispose();
    super.unmount();
  }
}
