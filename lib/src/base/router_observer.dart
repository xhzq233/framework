import 'package:flutter/widgets.dart';
import '../../logger.dart';

class LoggerRouterObserver extends NavigatorObserver {
  void log(String msg) {
    logger.i('router', msg);
  }

  @override
  void didStopUserGesture() {}

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    log('replace $newRoute $oldRoute');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('remove $route $previousRoute');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('pop $route $previousRoute');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('push $route $previousRoute');
  }
}
