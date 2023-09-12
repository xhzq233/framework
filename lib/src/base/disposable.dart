import 'dart:developer';

abstract mixin class DisposeMixin {
  void dispose() {
    assert(() {
      log('$runtimeType disposed');
      return true;
    }());
  }
}
