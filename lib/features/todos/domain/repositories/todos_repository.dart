import 'package:fpdart/fpdart.dart';
import 'package:todo_app/core/network/error/failures.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';

abstract class TodosRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTodos({
    required int limit,
    required int skip,
  });

  Future<Either<Failure, Map<String, dynamic>>> getTodosByUser({
    required int userId,
  });

  Future<Either<Failure, TodoItem>> addTodo({
    required String todo,
    required bool completed,
    required int userId,
  });

  Future<Either<Failure, TodoItem>> updateTodo({
    required int id,
    String? todo,
    bool? completed,
  });

  Future<Either<Failure, void>> deleteTodo(int id);

  Future<Either<Failure, List<TodoItem>>> getCachedTodos();
}
