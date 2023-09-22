import 'package:flutter/widgets.dart';
import 'package:framework/base.dart';
import 'package:provider/provider.dart';

import 'base_list.dart';

class Selectable<ItemType extends BaseItemModel<Key>, Key> with ChangeNotifier {
  /// The [selected] items' keys.
  final Set<Key> selected = {};

  bool selectMode = false;

  /// The max count of items can be selected.
  ///
  /// Default is null, which means no limit.
  int? maxSelectCount;

  @protected
  @mustCallSuper
  void setSelectMode(bool val) {
    if (selectMode == val) return;
    selectMode = val;
    notifyListeners();
  }

  void toggle(ItemType item) {
    assert(selectMode);
    if (selectMode) {
      final selected_ = selected.contains(item.key);
      if (selected_) {
        selected.remove(item.key);
      } else {
        if (maxSelectCount == null || selected.length < maxSelectCount!) {
          selected.add(item.key);
        } else {
          selected.remove(selected.first);
          selected.add(item.key);
        }
      }
      notifyListeners();
    }
  }

  void unselectAll() {
    assert(selectMode);
    selected.clear();
    notifyListeners();
  }

  /// Whether it is in the [inSelectMode], which is, items can be selected.
  static bool inSelectMode(BuildContext context) {
    return context.select((Selectable<BaseItemModel<Object>, Object> data) => data.selectMode);
  }

  static void toggleSelect(BuildContext context, BaseItemModel<Object> item) {
    return Provider.of<Selectable<BaseItemModel<Object>, Object>>(context, listen: false).toggle(item);
  }

  /// Whether the [item] is selected.
  static bool isSelected(BuildContext context, BaseItemModel<Object> item) {
    return context.select((Selectable<BaseItemModel<Object>, Object> data) => data.selected.contains(item.key));
  }
}

mixin BaseSelectableListViewModelMixin<ItemType extends BaseItemModel<Key>, Key> on BaseListViewModel<ItemType, Key>
    implements DisposeMixin {
  final Selectable<ItemType, Key> selectableViewModel = Selectable();

  Iterable<ItemType> get selectedItems =>
      selectableViewModel.selected.map((key) => list.firstWhere((item) => item.key == key));

  @mustCallSuper
  void toggleSelectMode() {
    selectableViewModel.setSelectMode(!selectableViewModel.selectMode);
  }

  @override
  void dispose() {
    selectableViewModel.dispose();
  }
}

class BaseSelectableList<ViewModel extends BaseSelectableListViewModelMixin<ItemType, Key>,
    ItemType extends BaseItemModel<Key>, Key> extends BaseList<ViewModel, ItemType, Key> {
  const BaseSelectableList({
    super.key,
    required super.itemBuilder,
    required super.viewModel,
    super.bottomSliver,
    super.controller,
    super.physics,
    super.primary,
    super.reverse,
    super.topSliver,
    super.buildList,
    super.scrollBehavior,
    super.scrollDirection,
    super.shrinkWrap,
  });

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: viewModel.selectableViewModel as Selectable<BaseItemModel<Object>, Object>,
        child: super.build(context),
      );
}
