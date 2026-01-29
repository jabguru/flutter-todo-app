import 'package:fpdart/fpdart.dart';
import 'package:todo_app/core/data/repositories/base_repository.dart';
import 'package:todo_app/core/network/error/failures.dart';
import 'package:todo_app/features/todos/data/datasources/todos_local_data_source.dart';
import 'package:todo_app/features/todos/data/datasources/todos_remote_data_source.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';
import 'package:todo_app/features/todos/domain/repositories/todos_repository.dart';

class TodosRepositoryImpl extends BaseRepository implements TodosRepository {
  TodosRepositoryImpl({
    required TodosRemoteDataSource remoteDataSource,
    required TodosLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final TodosRemoteDataSource _remoteDataSource;
  final TodosLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTodos({
    required int limit,
    required int skip,
  }) async {
    return await handleRequest(() async {
      final response = await _remoteDataSource.getTodos(
        limit: limit,
        skip: skip,
      );

      // Cache the todos
      final todos = (response['todos'] as List)
          .map((json) => TodoItem.fromMap(json))
          .toList();
      await _localDataSource.cacheTodos(todos);

      return response;
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTodosByUser({
    required int userId,
  }) async {
    return await handleRequest(() async {
      final response = await _remoteDataSource.getTodosByUser(userId: userId);

      // Cache the todos
      final todos = (response['todos'] as List)
          .map((json) => TodoItem.fromMap(json))
          .toList();
      await _localDataSource.cacheTodos(todos);

      return response;
    });
  }

  @override
  Future<Either<Failure, TodoItem>> addTodo({
    required String todo,
    required bool completed,
    required int userId,
  }) async {
    return await handleRequest(
      () => _remoteDataSource.addTodo(
        todo: todo,
        completed: completed,
        userId: userId,
      ),
    );
  }

  @override
  Future<Either<Failure, TodoItem>> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  }) async {
    return await handleRequest(
      () => _remoteDataSource.updateTodo(
        id: id,
        todo: todo,
        completed: completed,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteTodo(int id) async {
    return await handleRequest(() async {
      await _remoteDataSource.deleteTodo(id);
    });
  }

  @override
  Future<Either<Failure, List<TodoItem>>> getCachedTodos() async {
    return await handleRequest(() => _localDataSource.getCachedTodos());
  }
}
