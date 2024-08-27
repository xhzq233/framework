/// framework - state_provider
/// Created by xhz on 8/27/24

import 'package:flutter/material.dart';
import 'package:framework/base.dart';

class _HomeDataProvider extends StatefulWidget {
  const _HomeDataProvider({this.child});

  final Widget? child;

  @override
  State<_HomeDataProvider> createState() => _HomeDataProviderState();
}

class _HomeDataProviderState extends StateProvider<_HomeDataProvider> {
  @override
  Widget? buildContent() => widget.child;
}

class _Home1DataProvider extends StatefulWidget {
  const _Home1DataProvider({this.child});

  final Widget? child;

  @override
  State<_Home1DataProvider> createState() => _Home1DataProviderState();
}

class _Home1DataProviderState extends StateProvider<_Home1DataProvider> {
  @override
  Widget? buildContent() => widget.child;
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = StateProvider.read<_Home1DataProvider>(context);
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _Home1DataProvider(child: Home())));
        },
        child: const ColoredBox(
          color: Colors.blue,
          child: Center(
            child: Text('Home'),
          ),
        ));
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: _Home1DataProvider(child: _HomeDataProvider(child: Home())),
    ),
  );
}
