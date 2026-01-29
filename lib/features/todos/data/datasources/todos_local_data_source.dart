import 'dart:convert';

import 'package:todo_app/core/storage/local_storage.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';

abstract class TodosLocalDataSource {
  Future<void> cacheTodos(List<TodoItem> todos);
  Future<List<TodoItem>> getCachedTodos();
  Future<void> clearCache();
}

class TodosLocalDataSourceImpl implements TodosLocalDataSource {
  TodosLocalDataSourceImpl({required SharedPrefStorage sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPrefStorage _sharedPreferences;

  static const String _todosKey = 'CACHED_TODOS_KEY';

  @override
  Future<void> cacheTodos(List<TodoItem> todos) async {
    final todosJson = todos.map((todo) => todo.toMap()).toList();
    await _sharedPreferences.put(key: _todosKey, value: jsonEncode(todosJson));
  }

  @override
  Future<List<TodoItem>> getCachedTodos() async {
    try {
      final todosJson = await _sharedPreferences.get(_todosKey);
      final List<dynamic> decoded = jsonDecode(todosJson);
      return decoded.map((json) => TodoItem.fromMap(json)).toList();
    } on LocalStorageException {
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    await _sharedPreferences.delete({_todosKey});
  }
}
