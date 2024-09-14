import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/route.dart';

import 'package:framework/widgets.dart';

class PreviewImage extends StatelessWidget {
  const PreviewImage({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = hashCode;
    final child = NNImage(
      'https://lh3.googleusercontent.com/a/ACg8ocL4WP-p7O2QFVE5QEt5LrTPSr34ZmIpir2zxHIVryT2LYNoIzo=s96-c',
    );
    return GestureDetector(
      onTap: () => Navigator.of(context).push(PhotoPageRoute(draggableChild: child, heroTag: tag)),
      child: Hero(
        tag: tag,
        child: child,
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
    return const AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: Colors.green,
        child: Align(child: PreviewImage()),
      ),
    );
  }
}
