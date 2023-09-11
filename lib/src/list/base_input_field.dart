import 'package:flutter/widgets.dart';

import '../base/disposable.dart';
import '../layout/after_layout.dart';

/// [dispose] method is called when the [InputFieldState] changed to another.
abstract mixin class InputFieldState implements DisposeMixin {
  /// Return and clear current input.
  String? submit() => null;
}

typedef InputFieldDecorationBuilder = Widget Function(Widget child);
typedef InputHeightPublisher = ValueNotifier<double>;

/// Publishes the current [state].
/// Bind [state] with the corresponding input widget and publish the height of it.
///
/// Must implement [submit] and [initState] method.
mixin InputFieldViewModelMixin on ChangeNotifier {
  InputFieldState get state => _state;

  @protected
  @mustCallSuper
  set state(InputFieldState val) {
    if (state == val) return;
    _state.dispose();
    _state = val;
    notifyListeners();
  }

  late InputFieldState _state = initState();

  late final InputHeightPublisher inputHeightPublisher = InputHeightPublisher(0);

  late final Widget inputHeightBox = ValueListenableBuilder(
    valueListenable: inputHeightPublisher,
    builder: (ctx, val, _) => SizedBox(height: val),
  );

  /// Initialize the [state]
  InputFieldState initState();

  /// Submit with the given [input]
  @protected
  void submit(String input);

  /// Submit the current input.
  void submitUI() {
    final input = state.submit();
    if (input == null) return;
    submit(input);
  }

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
