part of 'base_input_field.dart';

abstract mixin class OnTapOutsideMixin {
  /// Called when tap outside the input field.
  ///
  /// Especially, outside the [TextFieldTapRegion].
  void onTapOutside(PointerDownEvent event);
}

abstract mixin class VXTextFieldInputState implements InputState, OnTapOutsideMixin {
  @override
  covariant late final VXInputLayoutMixin<VXTextFieldInputState> viewModel;

  @override
  void finalizeEditing() {
    final input = submit();
    viewModel.controller.clearComposing();
    viewModel._move1to2a();
    if (input == null) return;
    viewModel.submit(input);
  }

  @override
  void onTapOutside(PointerDownEvent event) {
    viewModel.onTapOutside(event);
  }
}

/// 按照vx的逻辑状态:
/// 1. 有键盘(只有文字框)
/// 2. 无键盘
///   a. 无弹出(包括语音、文字框等)
///   b. 有弹出(只有文字框)
///
/// 切换b通过改变showMore。2a切换需要变为文字框。
///
/// 滑动时切换为2a状态。
///
/// 当1与2a切换时，由于2a到1的focus变化是由[EditableTextState.requestKeyboard]引起的，无法改变，所以需要保证目标状态。
/// 而1到2a，也就是回车，是可以替换的。
///
/// The [initVXLayout] must be called.
mixin VXInputLayoutMixin<TextFieldStateType extends InputState>
    on ChangeNotifier, InputViewModelMixin
    implements OnTapOutsideMixin {
  bool _showMore = false;

  bool get showMore => _showMore;

  set showMore(bool n) {
    if (_showMore == n) return;
    _showMore = n;
    notifyListeners();
  }

  final FocusNode node = FocusNode();

  final TextEditingController controller = TextEditingController();

  @override

  /// 使用TextFieldStateType作为初始状态
  TextFieldStateType initState();

  /// Return TextField state
  TextFieldStateType onFocus() => initState();

  bool get _is1 => showMore == false && node.hasFocus == true && state is TextFieldStateType;

  bool get _is2a => showMore == false && node.hasFocus == false;

  bool get _is2aTemp => showMore == false && node.hasFocus == true;

  bool get _is2b => showMore == true && node.hasFocus == false && state is TextFieldStateType;

  bool get _is2bTemp => showMore == true && node.hasFocus == true && state is TextFieldStateType;

  void _move1to2b() {
    debugPrint('1->2b');
    assert(_is1);
    node.unfocus();
    showMore = true;

    assert(() {
      scheduleMicrotask(() {
        assert(_is2b);
      });
      return true;
    }());
  }

  void _move2ato2b() {
    debugPrint('2a->2b');
    assert(_is2a);
    state = onFocus();
    showMore = true;
    assert(_is2b);
  }

  void _move2bto2a() {
    debugPrint('2b->2a');
    assert(_is2b);
    showMore = false;
    assert(_is2a);
  }

  bool _in2b = false;

  void _move2bto1() {
    debugPrint('2b->1');
    assert(_is2b);
    showMore = false;
    _in2b = true;
    node.requestFocus();

    assert(() {
      scheduleMicrotask(() {
        assert(_is1);
      });
      return true;
    }());
  }

  void _when2bto1() {
    debugPrint('2b->1');
    assert(_is2bTemp);
    showMore = false;

    assert(_is1);
  }

  void _when2ato1() {
    debugPrint('2a->1');
    // 不得已的中间状态。。。
    assert(_is2aTemp);
    state = onFocus();
    assert(_is1);
  }

  void _move1to2a() {
    debugPrint('1->2a');
    assert(_is1);
    showMore = false;
    node.unfocus();

    assert(() {
      scheduleMicrotask(() {
        assert(_is2a);
      });
      return true;
    }());
  }

  void initVXLayout() {
    node.addListener(() {
      // Called in microtask.
      if (_in2b) {
        _in2b = false;
      } else if (_is2bTemp) {
        _when2bto1();
      } else if (_is2aTemp) {
        _when2ato1();
      }
    });
  }

  void pressShowMore() {
    if (_is2b) {
      _move2bto1();
    } else if (_is1) {
      _move1to2b();
    } else if (_is2a) {
      _move2ato2b();
    }
  }

  @override
  void onTapOutside(PointerDownEvent event) {
    if (_is2b) {
      _move2bto2a();
    } else if (_is1) {
      _move1to2a();
    }
  }

  @override
  void dispose() {
    super.dispose();
    node.dispose();
    controller.dispose();
  }
}
