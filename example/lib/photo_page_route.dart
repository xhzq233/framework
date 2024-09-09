import 'package:flutter/material.dart';
import 'package:framework/route.dart';

/// framework - photo_page_route
/// Created by xhz on 9/8/24

void main() {
  runApp(
    const MaterialApp(home: _Home()),
  );
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.green,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            PhotoPageRoute(
              draggableChild: const Hero(
                  tag: 'null11',
                  child: Icon(
                    Icons.ac_unit,
                    color: Colors.white,
                    size: 100,
                  )),
            ),
          );
        },
        child: const Hero(
            tag: 'null11',
            child: Icon(
              Icons.ac_unit,
              color: Colors.white,
            )),
      ),
    );
  }
}
