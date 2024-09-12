/// EcsMerchantApp - page_sheet
/// Created by xhz on 8/23/24

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPageSheet extends StatelessWidget {
  const CustomPageSheet({super.key, required this.title, this.subTitle, required this.child});

  static Route<T> route<T>({
    required String title,
    String? subTitle,
    required Widget child,
  }) {
    return ModalBottomSheetRoute(
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => CustomPageSheet(title: title, subTitle: subTitle, child: child),
    );
  }

  final String title;
  final String? subTitle;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 42, left: 24, right: 24, bottom: 48 + MediaQuery.viewPaddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            if (subTitle != null) const SizedBox(height: 17),
            if (subTitle != null)
              Text(
                subTitle!,
                style: const TextStyle(fontSize: 15),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class CustomListPageSheet extends StatelessWidget {
  const CustomListPageSheet({super.key, required this.sliver});

  static Route<T> route<T>({
    required Widget sliver,
  }) {
    return ModalBottomSheetRoute(
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => CustomListPageSheet(sliver: sliver),
    );
  }

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 12,
          left: 8,
          right: 8,
          bottom: 21 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: CustomScrollView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                slivers: [sliver],
              ),
            ),
            // 扩大 drag 区域
            AbsorbPointer(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey2.resolveFrom(context),
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
