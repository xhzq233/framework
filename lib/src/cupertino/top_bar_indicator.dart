import 'package:flutter/widgets.dart';

class BottomSheetTopBarIndicator extends StatelessWidget {
  const BottomSheetTopBarIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 4),
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFC7C7CC),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
