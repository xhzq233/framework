/// framework - clip
/// Created by xhz on 10/11/24

import 'package:flutter/widgets.dart';

// Capsule clip path
class CapsuleClipPath extends CustomClipper<Path> {
  CapsuleClipPath();

  @override
  Path getClip(Size size) {
    final path = Path();
    final shorter = size.width < size.height ? size.width : size.height;
    path.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(shorter / 2)));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
