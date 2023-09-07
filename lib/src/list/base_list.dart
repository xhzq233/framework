import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

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
mixin BaseListViewModel<ItemType extends BaseItemModel<Key>, Key> {
  @protected
  BuildContext? _listContext;

  @mustCallSuper
  @protected
  void notifyList() {
    if (_listContext != null && _listContext!.mounted) (_listContext as Element).markNeedsBuild();
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
  });

  final ItemBuilder<ItemType> itemBuilder;
  final Widget? topSliver;
  final Widget? bottomSliver;
  final ScrollController? controller;
  final bool reverse;
  final ViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel._listContext = context;
    final list = viewModel.list;
    final first = reverse ? bottomSliver : topSliver;
    final last = reverse ? topSliver : bottomSliver;

    return CustomScrollView(
      controller: controller,
      reverse: reverse,
      slivers: [
        if (first != null) first,
        SliverList.builder(
          itemBuilder: (ctx, index) {
            if (reverse) {
              index = list.length - index - 1;
            }
            final ItemType item = list[index];
            return KeyedSubtree(key: ValueKey(item.key), child: itemBuilder(item, index));
          },
          itemCount: list.length,
        ),
        if (last != null) last,
      ],
    );
  }
}
