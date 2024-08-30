/// framework - state_provider
/// Created by xhz on 8/27/24

import 'package:flutter/material.dart';
import 'package:framework/base.dart';

class _Home1DataProvider extends StatefulWidget {
  const _Home1DataProvider({required this.child});

  final Widget child;

  @override
  State<_Home1DataProvider> createState() => _Home1DataProviderState();
}

class _Home1DataProviderState extends StateProvider<_Home1DataProvider> {
  @override
  Widget build(BuildContext context) {
    return ProviderWidget(provider: this, child: widget.child);
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.read<_Home1DataProviderState>(context);
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
      home: _Home1DataProvider(child: _Home1DataProvider(child: Home())),
    ),
  );
}
