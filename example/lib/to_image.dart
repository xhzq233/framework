/// framework - to_image
/// Created by xhz on 9/14/24
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:framework/cupertino.dart';
import 'package:framework/util.dart';

void main() {
  runApp(
    const MaterialApp(home: _Home()),
  );
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  ImageProvider? provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          child: CustomCupertinoButton(
            child: const ColoredBox(color: Colors.green, child: Text('Click me')),
            onTap: () async {
              final image = await context.toUiImage(
                Container(color: Colors.green, height: 100, width: 300, child: const Text('Click me')),
              );
              provider = await image.imageProvider(ui.ImageByteFormat.png);
              setState(() {});
            },
          ),
        ),
        if (provider != null) Image(image: provider!),
      ],
    );
  }
}
