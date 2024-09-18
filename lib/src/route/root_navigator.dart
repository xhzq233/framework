/// framework - root_navigator
/// Created by xhz on 9/18/24

import 'package:flutter/widgets.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

NavigatorState get rootNavigator {
  assert(rootNavigatorKey.currentState != null, 'rootNavigatorKey.currentState is null');
  return rootNavigatorKey.currentState!;
}
