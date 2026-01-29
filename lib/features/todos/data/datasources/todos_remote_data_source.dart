import 'package:todo_app/core/network/endpoints.dart';
import 'package:todo_app/core/network/network_provider.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';

abstract class TodosRemoteDataSource {
  Future<Map<String, dynamic>> getTodos({
    required int limit,
    required int skip,
  });
  
  Future<Map<String, dynamic>> getTodosByUser({
    required int userId,
  });
  
  Future<TodoItem> addTodo({
    required String todo,
    required bool completed,
    required int userId,
  });
  
  Future<TodoItem> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  });
  
  Future<Map<String, dynamic>> deleteTodo(int id);
}

class TodosRemoteDataSourceImpl implements TodosRemoteDataSource {
  final NetworkProvider _networkProvider;
  
  TodosRemoteDataSourceImpl(this._networkProvider);

  @override
  Future<Map<String, dynamic>> getTodos({
    required int limit,
    required int skip,
  }) async {
    final response = await _networkProvider.call(
      path: Endpoints.todos,
      method: RequestMethod.get,
      queryParams: {
        'limit': limit,
        'skip': skip,
      },
    );
    return response?.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getTodosByUser({
    required int userId,
  }) async {
    final response = await _networkProvider.call(
      path: Endpoints.todosByUser(userId),
      method: RequestMethod.get,
    );
    return response?.data as Map<String, dynamic>;
  }

  @override
  Future<TodoItem> addTodo({
    required String todo,
    required bool completed,
    required int userId,
  }) async {
    final response = await _networkProvider.call(
      path: Endpoints.addTodo,
      method: RequestMethod.post,
      body: {
        'todo': todo,
        'completed': completed,
        'userId': userId,
      },
    );
    return TodoItem.fromMap(response?.data as Map<String, dynamic>);
  }

  @override
  Future<TodoItem> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  }) async {
    final body = <String, dynamic>{};
    if (todo != null) body['todo'] = todo;
    if (completed != null) body['completed'] = completed;

    final response = await _networkProvider.call(
      path: Endpoints.todoById(id),
      method: RequestMethod.put,
      body: body,
    );
    return TodoItem.fromMap(response?.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> deleteTodo(int id) async {
    final response = await _networkProvider.call(
      path: Endpoints.todoById(id),
      method: RequestMethod.delete,
    );
    return response?.data as Map<String, dynamic>;
  }
}
