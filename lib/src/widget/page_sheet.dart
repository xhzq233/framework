/// EcsMerchantApp - page_sheet
/// Created by xhz on 8/23/24

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../cupertino.dart';
import '../route/root_navigator.dart';

class CustomPageSheet extends StatelessWidget {
  const CustomPageSheet({super.key, required this.title, this.subTitle, required this.child});

  static Route<T> route<T>({
    required String title,
    String? subTitle,
    required Widget child,
  }) {
    return ModalBottomSheetRoute(
      isScrollControlled: false,
      backgroundColor: CupertinoColors.systemBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (BuildContext context) => CustomPageSheet(title: title, subTitle: subTitle, child: child),
    );
  }

  final String title;
  final String? subTitle;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
      backgroundColor: CupertinoColors.systemBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (BuildContext context) => CustomListPageSheet(sliver: sliver),
    );
  }

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

void _cancelAction() {
  rootNavigator.pop();
}

class NNAlert extends StatelessWidget {
  const NNAlert({
    super.key,
    this.mainActionTitle = '确定',
    this.cancelActionTitle = '取消',
    this.onMainAction = _cancelAction,
    this.onCancelAction = _cancelAction,
    required this.child,
  });

  static Route<T> route<T>({
    String mainActionTitle = '确定',
    String cancelActionTitle = '取消',
    VoidCallback onMainAction = _cancelAction,
    VoidCallback onCancelAction = _cancelAction,
    required Widget child,
  }) {
    return RawDialogRoute<T>(
      pageBuilder: (BuildContext context, _, __) => NNAlert(
        mainActionTitle: mainActionTitle,
        cancelActionTitle: cancelActionTitle,
        onMainAction: onMainAction,
        onCancelAction: onCancelAction,
        child: child,
      ),
    );
  }

  final String mainActionTitle;

  final String cancelActionTitle;

  final VoidCallback onMainAction;

  final VoidCallback onCancelAction;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = CupertinoColors.systemBackground.resolveFrom(context);
    final primaryColor = Theme.of(context).primaryColor;
    final separatorColor = CupertinoColors.separator.resolveFrom(context);
    return Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290, minHeight: 100),
                child: Align(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: child,
                  ),
                ),
              ),
              ColoredBox(
                color: separatorColor,
                child: const SizedBox(width: double.infinity, height: 0.5),
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CustomCupertinoFillButton(
                        onTap: onCancelAction,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                          child: Align(
                            child: Text(
                              cancelActionTitle,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ColoredBox(color: separatorColor, child: const SizedBox(width: 0.5)),
                    Expanded(
                      child: CustomCupertinoFillButton(
                        onTap: onMainAction,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                          child: Align(
                            child: Text(
                              mainActionTitle,
                              style: TextStyle(fontSize: 15, color: primaryColor, fontWeight: FontWeight.w500),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NNDestructiveAlert extends StatelessWidget {
  const NNDestructiveAlert({
    super.key,
    this.mainActionTitle = '确定',
    this.cancelActionTitle = '取消',
    this.onMainAction = _cancelAction,
    this.onCancelAction = _cancelAction,
    this.title = '提示',
  });

  static Route<T> route<T>({
    String mainActionTitle = '确定',
    String cancelActionTitle = '取消',
    String title = '提示',
    VoidCallback onMainAction = _cancelAction,
    VoidCallback onCancelAction = _cancelAction,
  }) {
    return ModalBottomSheetRoute<T>(
      backgroundColor: CupertinoColors.systemBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) => NNDestructiveAlert(
        mainActionTitle: mainActionTitle,
        cancelActionTitle: cancelActionTitle,
        onMainAction: onMainAction,
        onCancelAction: onCancelAction,
        title: title,
      ),
      isScrollControlled: false,
    );
  }

  final String mainActionTitle;

  final String cancelActionTitle;

  final VoidCallback onMainAction;

  final VoidCallback onCancelAction;

  final String title;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final separatorColor = CupertinoColors.separator.resolveFrom(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: secondaryColor),
            textAlign: TextAlign.center,
          ),
        ),
        ColoredBox(color: separatorColor, child: const SizedBox(width: double.infinity, height: 1)),
        CustomCupertinoFillButton(
          onTap: onMainAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Align(
              child: Text(
                mainActionTitle,
                style: const TextStyle(fontSize: 17, color: Color(0xFFFA5151), fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
          ),
        ),
        ColoredBox(color: separatorColor, child: const SizedBox(height: 8, width: double.infinity)),
        CustomCupertinoFillButton(
          onTap: onCancelAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Align(
              child: Text(
                cancelActionTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
      ],
    );
  }
}
