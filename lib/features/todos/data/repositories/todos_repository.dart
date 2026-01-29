import 'package:fpdart/fpdart.dart';
import 'package:todo_app/core/data/models/paginated_response.dart';
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
  Future<Either<Failure, PaginatedResponseModel<TodoItem>>> getTodos({
    required int page,
    required int size,
    required int userId,
  }) async {
    return await handleRequest(() async {
      final paginatedResponse = await _remoteDataSource.getTodos(
        page: page,
        size: size,
        userId: userId,
      );

      // Cache the todos
      await _localDataSource.cacheTodos(paginatedResponse.data);

      return paginatedResponse;
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
