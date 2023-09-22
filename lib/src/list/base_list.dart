import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../util/widget/ui_util.dart';

@immutable
abstract class BaseItemModel<Key> with EquatableMixin {
  const BaseItemModel();

  Key get key;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [key];
}

/// Notify others only if the [list] changed.
abstract mixin class BaseListViewModel<ItemType extends BaseItemModel<Key>, Key> {
  @protected
  BuildContext? _listContext;

  @mustCallSuper
  @protected
  void notifyList() {
    _listContext.rebuild();
  }

  /// Provides all items.
  List<ItemType> get list;

  /// Saves an [item].
  ///
  /// If a [item] with the same key already exists, it will be replaced.
  Future<void> add(ItemType item) async {
    notifyList();
    list.add(item);
  }

  /// Update the [item].
  ///
  /// Throwing error when [item] not found.
  Future<void> update(ItemType item) async {
    final index = list.indexWhere((element) => element.key == item.key);
    if (index != -1) {
      list.removeAt(index);
      list.insert(index, item);
      notifyList();
    } else {
      throw 'Item not found.';
    }
  }

  /// replace all list items with list
  void replaceList(List<ItemType> newList) {
    list.clear();
    list.addAll(newList);
    notifyList();
  }

  /// Deletes the `item` with the given id.
  ///
  /// If no `item` with the given id exists, a error is thrown.
  Future<void> delete(Key key) async {
    list.removeWhere((element) => element.key == key);
  }
}

typedef ItemBuilder<Model> = Widget Function(Model messageModel, int index);

class BaseList<ViewModel extends BaseListViewModel<ItemType, Key>, ItemType extends BaseItemModel<Key>, Key>
    extends StatelessWidget {
  const BaseList({
    super.key,
    required this.itemBuilder,
    this.reverse = false,
    required this.viewModel,
    this.topSliver,
    this.bottomSliver,
    this.controller,
    this.primary = true,
    this.physics,
    this.buildList = _defaultBuildList,
    this.scrollDirection = Axis.vertical,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.scrollViewWrapper,
  });

  static Widget _defaultBuildList(SliverChildDelegate delegate) => SliverList(delegate: delegate);

  final ItemBuilder<ItemType> itemBuilder;
  final Widget? topSliver;
  final Widget? bottomSliver;
  final ScrollController? controller;
  final bool reverse;
  final ViewModel viewModel;
  final bool primary;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollBehavior? scrollBehavior;
  final Widget Function(SliverChildDelegate delegate) buildList;
  final Widget Function(CustomScrollView scrollView)? scrollViewWrapper;

  @override
  Widget build(BuildContext context) {
    viewModel._listContext = context;
    final list = viewModel.list;
    final first = reverse ? bottomSliver : topSliver;
    final last = reverse ? topSliver : bottomSliver;

    final delegate = SliverChildBuilderDelegate(
      (ctx, index) {
        if (reverse) {
          index = list.length - index - 1;
        }
        final ItemType item = list[index];
        return KeyedSubtree(key: ValueKey(item.key), child: itemBuilder(item, index));
      },
      childCount: list.length,
    );

    final scrollView = CustomScrollView(
      controller: controller,
      reverse: reverse,
      physics: physics,
      primary: primary,
      scrollDirection: scrollDirection,
      scrollBehavior: scrollBehavior,
      shrinkWrap: shrinkWrap,
      slivers: [
        if (first != null) first,
        buildList(delegate),
        if (last != null) last,
      ],
    );
    return scrollViewWrapper?.call(scrollView) ?? scrollView;
  }
}
