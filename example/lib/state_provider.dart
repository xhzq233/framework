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
}

class _Home2DataProvider extends Provider {
  _Home2DataProvider() {
    print('Home2DataProvider created');
  }

  @override
  void dispose() {
    print('Home2DataProvider disposed');
    super.dispose();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      provider: (_) => _Home1DataProvider(),
      child: GestureDetector(
        onTap: () {
          (context as Element).markNeedsBuild();
        },
        child: const ColoredBox(
          color: Colors.blue,
          child: Center(
            child: Text('Home'),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: Home(),
    ),
  );
}
