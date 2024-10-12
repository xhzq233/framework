import 'package:flutter/material.dart';
import 'package:framework/layout.dart';

// 向外扩展红点
class ExtendOutTextBadge extends StatelessWidget {
  const ExtendOutTextBadge({
    Key? key,
    required this.count,
    required this.child,
    this.offset = const Offset(-10, 14),
  }) : super(key: key);
  final int count;
  final Widget child;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return child;
    }

    final countString = count <= 99 ? count.toString() : "99+";

    final countText = Text(
      countString,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: const TextStyle(
        inherit: false,
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      strutStyle: const StrutStyle(
        forceStrutHeight: true,
      ),
      textScaleFactor: 1,
    );

    return SurroundingOverlay(
      alignment: Alignment.topRight,
      offset: offset,
      children: [
        child,
        IntrinsicWidth(
          child: IntrinsicHeight(
            child: IgnorePointer(
              ignoring: true,
              child: ClipPath(
                clipper: CapsuleClipPath(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.red),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Align(child: countText)),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
