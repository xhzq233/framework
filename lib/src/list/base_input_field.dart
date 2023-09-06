import 'package:flutter/widgets.dart';

import '../base/disposable.dart';
import '../layout/after_layout.dart';

abstract mixin class InputFieldState {
  /// Return and clear current input.
  String? submit();

  /// Build the InputField with a [submit] method.
  Widget build(BuildContext context, VoidCallback submit);

  /// Called when the [InputFieldState] changed to another.
  void dispose() {}
}

typedef InputFieldDecorationBuilder = Widget Function(Widget child);
typedef _InputHeightPublisher = ValueNotifier<double>;

mixin InputFieldViewModelMixin on Disposable {
  InputFieldState get state;

  final _InputHeightPublisher _inputHeightPublisher = _InputHeightPublisher(0);

  late final Widget inputHeightBox = ValueListenableBuilder(
    valueListenable: _inputHeightPublisher,
    builder: (ctx, val, _) => SizedBox(height: val),
  );

  /// Submit the given [input]
  void submit(String input);

  void _submit() {
    final input = state.submit();
    if (input == null) return;
    submit(input);
  }

  /// Build the InputField.
  ///
  /// Specify the input decoration using [decorationBuilder].
  ///
  /// Write [build] method inside ViewModel is to easily bind viewModel and corresponding widget.
  Widget build({InputFieldDecorationBuilder? decorationBuilder}) {
    final Widget input = Builder(builder: (context) => state.build(context, _submit));
    final Widget res;

    if (decorationBuilder != null) {
      res = decorationBuilder(input);
    } else {
      res = input;
    }
    return _InputFieldScope(res, _inputHeightPublisher);
  }

  @override
  void dispose(BuildContext context) {
    super.dispose(context);
    _inputHeightPublisher.dispose();
  }
}

class _InputFieldScope extends StatelessWidget {
  const _InputFieldScope(this.child, this.publisher);

  final Widget child;

  final _InputHeightPublisher publisher;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AfterLayout(
        callback: (val) => publisher.value = val.size.height,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: child,
        ),
      ),
    );
  }
}
