import 'package:flutter/widgets.dart';

/// Control not only visibility but also pointer events.
class Disappear extends StatelessWidget {
  const Disappear({super.key, required this.child, this.visible = true});

  final Widget child;

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: Visibility.maintain(
        visible: visible,
        child: child,
      ),
    );
  }
}
