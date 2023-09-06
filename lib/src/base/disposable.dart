import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

abstract mixin class Disposable {
  @mustCallSuper
  void dispose(BuildContext context) {
    assert(() {
      log('$runtimeType disposed', name: 'Disposable');
      return true;
    }());
  }
}

class DisposableProvider<T extends Disposable> extends Provider<T> {
  DisposableProvider({super.key, required super.create, super.builder, super.child, super.lazy})
      : super(dispose: (ctx, t) => t.dispose(ctx));
}
