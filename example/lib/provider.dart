/// framework - state_provider
/// Created by xhz on 8/27/24

import 'package:flutter/material.dart';
import 'package:framework/base.dart';

class _Home1DataProvider extends Provider {
  _Home1DataProvider() {
    print('Home1DataProvider created');
  }

  @override
  void dispose() {
    print('Home1DataProvider disposed');
    super.dispose();
  }

  void notify() {
    notifyListeners();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Provider.watch<_Home1DataProvider>(context).notify();
      },
      child: const ColoredBox(
        color: Colors.blue,
        child: Center(
          child: Text('Home'),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ProviderWidget(
      provider: _Home1DataProvider(),
      child: const MaterialApp(
        home: Home(),
      ),
    ),
  );
}
