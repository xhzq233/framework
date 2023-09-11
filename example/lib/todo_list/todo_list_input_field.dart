import 'package:flutter/material.dart';
import 'package:framework/base.dart';
import 'package:framework/list.dart';

import 'todo_model.dart';

class KeyboardInputFieldState extends ChangeNotifier with InputFieldState {
  KeyboardInputFieldState({this.controller, this.focusNode}) {
    if (controller != null) {
      controller!.addListener(notifyListeners);
    }
  }

  final TextEditingController? controller;

  final FocusNode? focusNode;

  bool get submitEnabled => controller?.text.trim().isNotEmpty ?? false;

  @override
  String? submit() {
    final text = controller?.text;
    controller?.clear();
    return text;
  }

  @override
  void dispose() {
    super.dispose();
    controller?.removeListener(notifyListeners);
  }
}

class LockInputFieldState with InputFieldState {
  LockInputFieldState(this.text);

  final String? text;

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

class TodoInputFieldViewModel extends ChangeNotifier with DisposeMixin, InputFieldViewModelMixin {
  TodoInputFieldViewModel(this.api);

  final BaseListViewModel<dynamic, dynamic> api;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  void submit(String input) {
    api.add(Todo(content: input));
  }

  @override
  InputFieldState initState() {
    return KeyboardInputFieldState(controller: _textEditingController);
  }

  void lock() {
    state = LockInputFieldState(_textEditingController.text);
  }

  void unlock() {
    state = KeyboardInputFieldState(controller: _textEditingController);
  }
}
