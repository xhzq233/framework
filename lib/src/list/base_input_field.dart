import 'dart:ui';

import 'package:flutter/material.dart';

import '../base/disposable.dart';
import '../layout/after_layout.dart';
import 'dart:async';

part '_vx_input_layout.dart';

typedef InputHeightPublisher = ValueNotifier<double>;

abstract mixin class InputState implements DisposeMixin {
  covariant late final InputViewModelMixin viewModel;

  /// Return and clear current input.
  String? submit() => null;

  /// Submit the current input.
  ///
  /// Pass it to UI. e.g. [TextField].
  void finalizeEditing() {
    final input = submit();
    if (input == null) return;
    viewModel.submit(input);
  }
}

/// Publishes the current [state].
/// Bind [state] with the corresponding input widget and publish the height of it.
///
/// Must implement [submit] and [initState] method.
mixin InputViewModelMixin on ChangeNotifier {
  InputState get state => _state;

  @protected
  @mustCallSuper
  set state(InputState val) {
    if (state.runtimeType == val.runtimeType) return;
    _state.dispose();
    _state = val;
    _state.viewModel = this;
    notifyListeners();
  }

  late InputState _state = initState()..viewModel = this;

  late final InputHeightPublisher inputHeightPublisher = InputHeightPublisher(0);

  late final Widget inputHeightBox = ValueListenableBuilder(
    valueListenable: inputHeightPublisher,
    builder: (ctx, val, _) => SizedBox(height: val),
  );

  /// Initialize the [state]
  InputState initState();

  /// Submit with the given [input].
  @protected
  void submit(String input);

  /// Build the InputField.
  ///
  /// Specify the input decoration using [decorationBuilder].
  ///
  /// Write [build] method inside ViewModel is to easily bind viewModel and corresponding widget.
  @mustCallSuper
  Widget buildWith({Key? key, Widget? child}) => _InputFieldScope(child, inputHeightPublisher, key: key);

  @override
  void dispose() {
    super.dispose();
    inputHeightPublisher.dispose();
  }
}

class _InputFieldScope extends StatelessWidget {
  const _InputFieldScope(this.child, this.publisher, {super.key});

  final Widget? child;

  final InputHeightPublisher publisher;

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AfterLayout(
          callback: (val) => publisher.value = val.size.height,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The small horizontal bar at the bottom of iPhone and iPad is called `Home Indicator`
class HomeIndicatorPadding extends StatelessWidget {
  const HomeIndicatorPadding({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: child,
    );
  }
}

class BlurredInputField extends StatelessWidget {
  const BlurredInputField({super.key, this.child, required this.maskColor});

  final Widget? child;

  final Color maskColor;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: ColoredBox(
          color: maskColor,
          child: child,
        ),
      ),
    );
  }
}
