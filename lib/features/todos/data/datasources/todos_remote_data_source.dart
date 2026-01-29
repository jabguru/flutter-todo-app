import 'package:todo_app/core/data/models/paginated_response.dart';
import 'package:todo_app/core/network/endpoints.dart';
import 'package:todo_app/core/network/network_provider.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';

abstract class TodosRemoteDataSource {
  Future<PaginatedResponseModel<TodoItem>> getTodos({
    required int page,
    required int size,
    required int userId,
  });

  Future<TodoItem> addTodo({
    required String todo,
    required bool completed,
    required int userId,
  });

  Future<TodoItem> updateTodo({required int id, String? todo, bool? completed});

  Future<Map<String, dynamic>> deleteTodo(int id);
}

class TodosRemoteDataSourceImpl implements TodosRemoteDataSource {
  final NetworkProvider _networkProvider;

  TodosRemoteDataSourceImpl(this._networkProvider);

  @override
  Future<PaginatedResponseModel<TodoItem>> getTodos({
    required int page,
    required int size,
    required int userId,
  }) async {
    final skip = page * size;
    final response = await _networkProvider.call(
      path: Endpoints.todosByUser(userId),
      method: RequestMethod.get,
      queryParams: {'limit': size, 'skip': skip},
    );

    final data = response?.data as Map<String, dynamic>;
    return PaginatedResponseModel.fromJson(
      data,
      (json) => TodoItem.fromMap(json),
    );
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
      body: {'todo': todo, 'completed': completed, 'userId': userId},
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
