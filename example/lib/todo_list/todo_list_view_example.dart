import 'package:flutter/material.dart';
import 'package:framework/base.dart';
import 'package:framework/list.dart';
import 'package:provider/provider.dart';

import 'todo_list_input_field.dart';
import 'todo_model.dart';

class TodoListPageViewModel with Disposable, BaseListViewModel<Todo, String> {
  final List<Todo> _list = [
    const Todo(content: '111'),
    const Todo(content: '112'),
    const Todo(content: '113'),
    const Todo(content: '114'),
    const Todo(content: '115'),
    const Todo(content: '1145'),
    const Todo(content: '11451'),
  ];

  @override
  List<Todo> get list => _list;
}

class TodoPage extends StatelessWidget {
  const TodoPage({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        child: FractionallySizedBox(
          widthFactor: 0.4,
          child: FittedBox(child: Text(todo.content)),
        ),
      ),
    );
  }
}

class TodoWidget extends StatelessWidget {
  const TodoWidget({super.key, required this.index, required this.todo});

  static Widget itemBuilder(Todo messageModel, int index) {
    return TodoWidget(index: index, todo: messageModel);
  }

  final int index;
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.key),
      onDismissed: (_) {
        context.read<TodoListPageViewModel>().delete(todo.key);
      },
      direction: DismissDirection.endToStart,
      background: const ColoredBox(color: Colors.red),
      child: ListTile(
        title: Text(todo.content),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => TodoPage(todo: todo)),
        ),
        trailing: Checkbox(
          value: todo.done,
          onChanged: (bool? value) {
            context.read<TodoListPageViewModel>().update(todo.copyWith(done: value));
          },
        ),
      ),
    );
  }
}

class TodoListView extends StatelessWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseList<TodoListPageViewModel, Todo, String>(
      itemBuilder: TodoWidget.itemBuilder,
      viewModel: context.read<TodoListPageViewModel>(),
      bottomSliver: SliverToBoxAdapter(
        child: context.read<TodoInputFieldViewModel>().inputHeightBox,
      ),
      reverse: true,
    );
  }
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoInputFieldViewModel inputFieldVM = context.read();
    return Material(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const TodoListView(),
          inputFieldVM.build(
            decorationBuilder: (child) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      onGenerateRoute: (settings) => MaterialPageRoute(
        maintainState: false,
        builder: (_) {
          return DisposableProvider(
            create: (ctx) => TodoListPageViewModel(),
            child: DisposableProvider(
              create: (ctx) => TodoInputFieldViewModel(ctx.read<TodoListPageViewModel>()),
              child: const TodoListPage(),
            ),
          );
        },
      ),
    ),
  );
}
