import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/data/models/paginated_response.dart';
import 'package:todo_app/core/network/error/api_error.dart';
import 'package:todo_app/features/todos/data/datasources/todos_local_data_source.dart';
import 'package:todo_app/features/todos/data/datasources/todos_remote_data_source.dart';
import 'package:todo_app/features/todos/data/repositories/todos_repository.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';

class MockTodosRemoteDataSource extends Mock implements TodosRemoteDataSource {}

class MockTodosLocalDataSource extends Mock implements TodosLocalDataSource {}

void main() {
  late TodosRepositoryImpl repository;
  late MockTodosRemoteDataSource mockRemoteDataSource;
  late MockTodosLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockTodosRemoteDataSource();
    mockLocalDataSource = MockTodosLocalDataSource();
    repository = TodosRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('TodosRepository', () {
    const userId = 5;
    final todosList = [
      const TodoItem(
        id: 1,
        todo: 'Complete project documentation',
        completed: false,
        userId: 5,
      ),
      const TodoItem(
        id: 2,
        todo: 'Write unit tests',
        completed: true,
        userId: 5,
      ),
      const TodoItem(
        id: 3,
        todo: 'Review pull requests',
        completed: false,
        userId: 5,
      ),
    ];

    final paginatedResponse = PaginatedResponseModel<TodoItem>(
      data: todosList,
      pageNumber: 0,
      pageSize: 10,
      totalElements: 150,
      totalPages: 15,
      last: false,
      numberOfElements: 3,
    );

    test('getTodos should return PaginatedResponseModel on success', () async {
      when(
        () => mockRemoteDataSource.getTodos(page: 0, size: 10, userId: userId),
      ).thenAnswer((_) async => paginatedResponse);

      when(
        () => mockLocalDataSource.cacheTodos(any()),
      ).thenAnswer((_) async {});

      final result = await repository.getTodos(
        page: 0,
        size: 10,
        userId: userId,
      );

      expect(result.isRight(), true);
      result.fold((_) => fail('Should return Right'), (response) {
        expect(response, isA<PaginatedResponseModel<TodoItem>>());
        expect(response.data.length, 3);
        expect(response.totalElements, 150);
      });

      verify(
        () => mockRemoteDataSource.getTodos(page: 0, size: 10, userId: userId),
      ).called(1);
      verify(() => mockLocalDataSource.cacheTodos(todosList)).called(1);
    });

    test('getTodos should return Failure on ApiError', () async {
      when(
        () => mockRemoteDataSource.getTodos(page: 0, size: 10, userId: userId),
      ).thenThrow(
        ApiError(
          errorMessage: 'Network error',
          errorTitle: 'Connection Failed',
        ),
      );

      final result = await repository.getTodos(
        page: 0,
        size: 10,
        userId: userId,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Network error');
        expect(failure.title, 'Connection Failed');
      }, (_) => fail('Should return Left'));

      verify(
        () => mockRemoteDataSource.getTodos(page: 0, size: 10, userId: userId),
      ).called(1);
      verifyNever(() => mockLocalDataSource.cacheTodos(any()));
    });

    test('getTodos should return generic Failure on Exception', () async {
      when(
        () => mockRemoteDataSource.getTodos(page: 0, size: 10, userId: userId),
      ).thenThrow(Exception('Unexpected error'));

      final result = await repository.getTodos(
        page: 0,
        size: 10,
        userId: userId,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'An error occurred'),
        (_) => fail('Should return Left'),
      );
    });

    test('addTodo should return TodoItem on success', () async {
      const todo = 'New task';
      const completed = false;
      const userId = 5;
      const newTodo = TodoItem(
        id: 10,
        todo: todo,
        completed: completed,
        userId: userId,
      );

      when(
        () => mockRemoteDataSource.addTodo(
          todo: todo,
          completed: completed,
          userId: userId,
        ),
      ).thenAnswer((_) async => newTodo);

      final result = await repository.addTodo(
        todo: todo,
        completed: completed,
        userId: userId,
      );

      expect(result.isRight(), true);
      result.fold((_) => fail('Should return Right'), (todoItem) {
        expect(todoItem.todo, todo);
        expect(todoItem.userId, userId);
      });

      verify(
        () => mockRemoteDataSource.addTodo(
          todo: todo,
          completed: completed,
          userId: userId,
        ),
      ).called(1);
    });

    test('addTodo should return Failure on ApiError', () async {
      when(
        () => mockRemoteDataSource.addTodo(
          todo: any(named: 'todo'),
          completed: any(named: 'completed'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(
        ApiError(errorMessage: 'Failed to create todo', errorTitle: 'Error'),
      );

      final result = await repository.addTodo(
        todo: 'New task',
        completed: false,
        userId: 5,
      );

      expect(result.isLeft(), true);
    });

    test('updateTodo should return TodoItem on success', () async {
      const id = 1;
      const updatedTodo = 'Updated task';
      const completed = true;
      const updated = TodoItem(
        id: id,
        todo: updatedTodo,
        completed: completed,
        userId: 5,
      );

      when(
        () => mockRemoteDataSource.updateTodo(
          id: id,
          todo: updatedTodo,
          completed: completed,
        ),
      ).thenAnswer((_) async => updated);

      final result = await repository.updateTodo(
        id: id,
        todo: updatedTodo,
        completed: completed,
      );

      expect(result.isRight(), true);
      result.fold((_) => fail('Should return Right'), (todoItem) {
        expect(todoItem.todo, updatedTodo);
        expect(todoItem.completed, completed);
      });

      verify(
        () => mockRemoteDataSource.updateTodo(
          id: id,
          todo: updatedTodo,
          completed: completed,
        ),
      ).called(1);
    });

    test('updateTodo should return Failure on ApiError', () async {
      when(
        () => mockRemoteDataSource.updateTodo(
          id: any(named: 'id'),
          todo: any(named: 'todo'),
          completed: any(named: 'completed'),
        ),
      ).thenThrow(
        ApiError(errorMessage: 'Failed to update todo', errorTitle: 'Error'),
      );

      final result = await repository.updateTodo(
        id: 1,
        todo: 'Updated task',
        completed: true,
      );

      expect(result.isLeft(), true);
    });

    test('deleteTodo should return void on success', () async {
      const id = 1;

      when(
        () => mockRemoteDataSource.deleteTodo(id),
      ).thenAnswer((_) async => {'success': true});

      final result = await repository.deleteTodo(id);

      expect(result.isRight(), true);
      verify(() => mockRemoteDataSource.deleteTodo(id)).called(1);
    });

    test('deleteTodo should return Failure on ApiError', () async {
      const id = 1;

      when(() => mockRemoteDataSource.deleteTodo(id)).thenThrow(
        ApiError(errorMessage: 'Failed to delete todo', errorTitle: 'Error'),
      );

      final result = await repository.deleteTodo(id);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Failed to delete todo');
      }, (_) => fail('Should return Left'));
    });

    test(
      'getCachedTodos should return list of cached todos on success',
      () async {
        when(
          () => mockLocalDataSource.getCachedTodos(),
        ).thenAnswer((_) async => todosList);

        final result = await repository.getCachedTodos();

        expect(result.isRight(), true);
        result.fold((_) => fail('Should return Right'), (todos) {
          expect(todos.length, 3);
          expect(todos[0].todo, 'Complete project documentation');
        });

        verify(() => mockLocalDataSource.getCachedTodos()).called(1);
      },
    );

    test(
      'getCachedTodos should return empty list when cache is empty',
      () async {
        when(
          () => mockLocalDataSource.getCachedTodos(),
        ).thenAnswer((_) async => []);

        final result = await repository.getCachedTodos();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should return Right'),
          (todos) => expect(todos, isEmpty),
        );
      },
    );

    test('getCachedTodos should return Failure on Exception', () async {
      when(
        () => mockLocalDataSource.getCachedTodos(),
      ).thenThrow(Exception('Cache error'));

      final result = await repository.getCachedTodos();

      expect(result.isLeft(), true);
    });
  });
}
