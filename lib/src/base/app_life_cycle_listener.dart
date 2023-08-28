import 'package:flutter/widgets.dart';

mixin BEAppLifecycleListener {
  void onAppResume();

  void onAppPause();
}

class AppLifecycleManager with WidgetsBindingObserver {
  final Set<BEAppLifecycleListener> _listeners = {};

  void addListener(BEAppLifecycleListener listener) {
    assert(!_listeners.contains(listener), 'listener already added');
    _listeners.add(listener);
  }

  void removeListener(BEAppLifecycleListener listener) {
    assert(_listeners.contains(listener), 'listener not added');
    _listeners.remove(listener);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        for (var element in _listeners) {
          element.onAppResume();
        }
        break;
      case AppLifecycleState.paused:
        for (var element in _listeners) {
          element.onAppPause();
        }
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
