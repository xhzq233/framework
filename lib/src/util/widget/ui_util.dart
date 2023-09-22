import 'package:flutter/cupertino.dart';
import '../../logger/logger.dart';
import 'app_dialog.dart';
import 'toast.dart';

abstract class UIUtilProxy {
  const UIUtilProxy();

  void showLoading({String? msg});

  void hideLoading();

  void showToast(
    String msg, {
    ToastType toastType = ToastType.success,
    String? customIcon,
  });

  void showAppDialog({
    required String title,
    String? content,
    required BaseAppDialog alertDialog,
    Widget? customContent,
  });

  void showHalfScreenBottomSheet(
    Widget content, {
    required String tag,
    bool showCloseButton = true,
  });

  void showProgressLoadingDialog(ValueNotifier<ProgressLoadingState> state);
}

class UIUtil {
  // 注意加这个不然每次代码提示都会提示构造器
  const UIUtil._();

  static bool isToastInited = false;

  static late UIUtilProxy _instance;

  static void load(UIUtilProxy instance) {
    _instance = instance;
  }

  static void showLoading({String? msg}) => _instance.showLoading(msg: msg);

  static void hideLoading() => _instance.hideLoading();

  static void showToast(String msg, {ToastType toastType = ToastType.success, String? customIcon}) {
    logger.i('toast', 'show toast: $msg $toastType');
    _instance.showToast(msg, toastType: toastType, customIcon: customIcon);
  }

  static void showAppDialog({
    required String title,
    String? content,
    required BaseAppDialog alertDialog,
    Widget? customContent,
  }) {
    _instance.showAppDialog(title: title, content: content, alertDialog: alertDialog, customContent: customContent);
  }

  static void showHalfScreenBottomSheet(
    Widget content, {
    required String tag,
    bool showCloseButton = true,
  }) {
    _instance.showHalfScreenBottomSheet(content, tag: tag, showCloseButton: showCloseButton);
  }

  static void showProgressLoadingDialog(ValueNotifier<ProgressLoadingState> state) {
    _instance.showProgressLoadingDialog(state);
  }

  static String getDynamicPath(String imagePath, bool isDarkModeAware, BuildContext context) {
    final isDarkMode = isDarkModeAware && CupertinoTheme.brightnessOf(context) == Brightness.dark;
    String darkModePath = '';
    if (isDarkMode) {
      final list = imagePath.split('/');
      String pathLast = 'dark_mode/${list.last}';
      list.removeLast();
      for (var element in list) {
        darkModePath += '$element/';
      }
      darkModePath += pathLast;
    }
    return isDarkMode ? darkModePath : imagePath;
  }
}

mixin ProgressLoadingState {
  bool get finish;

  bool get error;

  String get hint;

  String get errorIcon;

  String get successIcon;

  /// null if [finish] is true or have [error], 0.0 ~ 1.0
  double? get loadingProgress;
}

extension RebuildOnElement on BuildContext? {
  void rebuild() {
    if (this != null && this!.mounted) (this as Element).markNeedsBuild();
  }
}
