import 'package:flutter/material.dart';
import 'package:framework/route.dart';

import 'package:framework/cupertino.dart';

import 'package:framework/widgets.dart';

class NNAvatar extends StatelessWidget {
  const NNAvatar({super.key, required this.imageUrl, this.size = 200});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tag = hashCode.toString();
    return CustomCupertinoButton(
      onTap: () => Navigator.push(context, PhotoPageRoute(draggableChild: NNImage(imageUrl), heroTag: tag)),
      child: Hero(
        tag: tag,
        child: NNImage(imageUrl, fit: BoxFit.contain, width: size),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(home: _Home()),
  );
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.green,
      child: Align(
        child: NNAvatar(
          imageUrl: 'https://lh3.googleusercontent.com/a/ACg8ocL4WP-p7O2QFVE5QEt5LrTPSr34ZmIpir2zxHIVryT2LYNoIzo=s96-c',
        ),
      ),
    );
  }
}
