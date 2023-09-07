import 'package:example/todo_list/todo_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    color: Colors.blue,
    onGenerateRoute: (settings) => TodoListPage.route(),
  ));
}
