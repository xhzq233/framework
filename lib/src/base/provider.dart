/// framework - provider
/// Created by xhz on 8/27/24

import 'dart:collection';

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
  Provider() {
    assert(() {
      debugPrint('[D]Provider created: $runtimeType#$hashCode');
      return true;
    }());
  }

  @override
  void dispose() {
    super.dispose();
    assert(() {
      debugPrint('[D]Provider disposed: $runtimeType#$hashCode');
      return true;
    }());
  }

  /// 通过 Provider.watch 获取 Provider 实例，监听 Provider 实例
  /// 建议跟数据相关时使用，比如 UI 层，`Provider.watch<MyProvider>(context).someUIData`
  static T watch<T extends Listenable>(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<ProviderWidget<T>>();
    return read<T>(context);
  }

  /// 通过 Provider.read 获取 Provider 实例，不监听
  /// 建议跟数据无关时使用，比如调用某个方法, `Provider.read<MyProvider>(context).someMethod()`
  static T read<T extends Listenable>(BuildContext context) {
    final _ProviderElement<T>? providerElement =
        context.getElementForInheritedWidgetOfExactType<ProviderWidget<T>>() as _ProviderElement<T>?;
    if (providerElement == null) {
      throw FlutterError('Provider.read/watch() called with a context that does not contain a Provider<$T>.'
          'No Provider<$T> found on context: $context ');
    }
    return providerElement.providerInstance;
  }

  static T selectAspect<T extends AspectProvider>(BuildContext context, Object aspect) {
    context.dependOnInheritedWidgetOfExactType<ProviderWidget<T>>(aspect: aspect);
    return read<T>(context);
  }

  static T? maybeRead<T extends Listenable>(BuildContext context) {
    final _ProviderElement<T>? providerElement =
        context.getElementForInheritedWidgetOfExactType<ProviderWidget<T>>() as _ProviderElement<T>?;
    if (providerElement == null) return null;

    return providerElement.providerInstance;
  }
}

abstract class AspectProvider extends Provider {
  final Set<Object> _aspects = {};

  @protected
  void notifyAspectListeners(Object aspect) {
    _aspects.add(aspect);
    notifyListeners();
  }
}

typedef ProviderBuilder<T> = T Function(BuildContext context);

class ProviderWidget<T extends Listenable> extends InheritedWidget {
  /// Provider 生命周期由外部管理
  const ProviderWidget({
    super.key,
    required T provider,
    required super.child,
  })  : providerBuilder = null,
        providerInstance = provider;

  /// Builder 模式，ProviderBuilder 用于懒加载 Provider 实例
  /// Provider 生命周期由 ProviderWidget 管理
  /// [provider] runtimeType 改变时，会重新初始化 Provider 实例
  const ProviderWidget.owned({
    super.key,
    required ProviderBuilder<T> provider,
    required super.child,
  })  : providerBuilder = provider,
        providerInstance = null;

  final ProviderBuilder<T>? providerBuilder;
  final T? providerInstance;

  @override
  bool updateShouldNotify(covariant ProviderWidget<T> oldWidget) {
    return oldWidget.providerBuilder != providerBuilder || oldWidget.providerInstance != providerInstance;
  }

  @override
  InheritedElement createElement() => _ProviderElement<T>(this);
}

class _ProviderElement<T extends Listenable> extends InheritedElement {
  _ProviderElement(ProviderWidget<T> widget) : super(widget) {
    // If not owned, listen to the provider instance immediately
    widget.providerInstance?.addListener(_handleUpdate);
  }

  @override
  ProviderWidget<T> get widget => super.widget as ProviderWidget<T>;

  T get providerInstance {
    if (widget.providerBuilder != null) {
      if (lazyProviderInstance == null) _initLazyProvider();
      return lazyProviderInstance!;
    } else {
      return widget.providerInstance!;
    }
  }

  bool _dirty = false;

  @visibleForTesting
  T? lazyProviderInstance;

  void _initLazyProvider() {
    assert(lazyProviderInstance == null, 'Provider instance should be null');
    if (widget.providerBuilder != null) {
      lazyProviderInstance = widget.providerBuilder!(this);
    }
    assert(lazyProviderInstance != null, 'Provider instance should not be null');
    lazyProviderInstance?.addListener(_handleUpdate);
  }

  void _tryDisposeLazyProvider() {
    lazyProviderInstance?.removeListener(_handleUpdate);
    if (lazyProviderInstance is ChangeNotifier) {
      (lazyProviderInstance as ChangeNotifier).dispose();
    }
    lazyProviderInstance = null;
  }

  void _tryRemoveListener() {
    widget.providerInstance?.removeListener(_handleUpdate);
  }

  @override
  void update(ProviderWidget<T> newWidget) {
    if (widget.providerBuilder.runtimeType != newWidget.providerBuilder.runtimeType) {
      // ProviderBuilder 变化，重新初始化
      // 释放旧 Provider 实例
      if (widget.providerBuilder != null || lazyProviderInstance != null) _tryDisposeLazyProvider();
    }
    if (widget.providerInstance != newWidget.providerInstance) {
      // Provider 实例变化，重新添加监听
      _tryRemoveListener();
      newWidget.providerInstance?.addListener(_handleUpdate);
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
  void updateDependencies(Element dependent, Object? aspect) {
    if (aspect != null) {
      // No need to clean up aspects
      final Set<Object> dependencies = (getDependencies(dependent) as Set<Object>?) ?? HashSet<Object>();
      setDependencies(dependent, dependencies..add(aspect));
    } else {
      setDependencies(dependent, aspect);
    }
  }

  @override
  void notifyClients(ProviderWidget<T> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
    if (providerInstance is AspectProvider) {
      // (providerInstance as AspectProvider)._aspects.clear();
    }
  }

  @override
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    bool shouldNotify = true;
    if (providerInstance is AspectProvider) {
      final Set<Object>? dependencies = getDependencies(dependent) as Set<Object>?;

      if (dependencies != null && dependencies.isNotEmpty) {
        final Set<Object> aspects = (providerInstance as AspectProvider)._aspects;
        shouldNotify = dependencies.any(aspects.contains);
      }
    }
    if (shouldNotify) {
      dependent.didChangeDependencies();
    }
  }

  @override
  void unmount() {
    _tryDisposeLazyProvider();
    _tryRemoveListener();
    super.unmount();
  }
}
