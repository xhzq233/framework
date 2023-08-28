import 'package:flutter/widgets.dart';

abstract class BaseAppDialog {
  String tag;

  bool autoDismiss;

  BaseAppDialog({required this.tag, this.autoDismiss = true});

  Widget getActions(BuildContext context);
}
