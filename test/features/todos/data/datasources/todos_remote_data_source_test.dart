import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/data/models/paginated_response.dart';
import 'package:todo_app/core/network/endpoints.dart';
import 'package:todo_app/core/network/network_provider.dart';
import 'package:todo_app/features/todos/data/datasources/todos_remote_data_source.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';

import '../../../../fixtures/fixture_helper.dart';

class MockNetworkProvider extends Mock implements NetworkProvider {}

class MockResponse extends Mock implements Response {}

void main() {
  late TodosRemoteDataSourceImpl remoteDataSource;
  late MockNetworkProvider mockNetworkProvider;

  setUpAll(() {
    Endpoints.baseUrl = '';
    mockNetworkProvider = MockNetworkProvider();
    remoteDataSource = TodosRemoteDataSourceImpl(mockNetworkProvider);
  });

  group('TodosRemoteDataSource', () {
    const userId = 5;

    test(
      'getTodos should return PaginatedResponseModel<TodoItem> on success',
      () async {
        const page = 0;
        const size = 10;
        final todosData = FixtureHelper.loadJsonMap('todos');

        final response = MockResponse();
        when(() => response.data).thenReturn(todosData);

        when(
          () => mockNetworkProvider.call(
            path: Endpoints.todosByUser(userId),
            method: RequestMethod.get,
            queryParams: {'limit': size, 'skip': 0},
          ),
        ).thenAnswer((_) async => response);

        final result = await remoteDataSource.getTodos(
          page: page,
          size: size,
          userId: userId,
        );

        expect(result, isA<PaginatedResponseModel<TodoItem>>());
        expect(result.data.length, 3);
        expect(result.data[0].todo, 'Complete project documentation');
        expect(result.totalElements, 150);
        verify(
          () => mockNetworkProvider.call(
            path: Endpoints.todosByUser(userId),
            method: RequestMethod.get,
            queryParams: {'limit': size, 'skip': 0},
          ),
        ).called(1);
      },
    );

    test('getTodos should calculate skip correctly for page > 0', () async {
      const page = 2;
      const size = 10;
      final todosData = FixtureHelper.loadJsonMap('todos');

      final response = MockResponse();
      when(() => response.data).thenReturn(todosData);

      when(
        () => mockNetworkProvider.call(
          path: Endpoints.todosByUser(userId),
          method: RequestMethod.get,
          queryParams: {'limit': size, 'skip': 20},
        ),
      ).thenAnswer((_) async => response);

      await remoteDataSource.getTodos(page: page, size: size, userId: userId);

      verify(
        () => mockNetworkProvider.call(
          path: Endpoints.todosByUser(userId),
          method: RequestMethod.get,
          queryParams: {'limit': size, 'skip': 20},
        ),
      ).called(1);
    });

    test('addTodo should return TodoItem on success', () async {
      const todo = 'New task';
      const completed = false;
      const userId = 5;
      final todoItemData = FixtureHelper.loadJsonMap('todo_item');

      final response = MockResponse();
      when(() => response.data).thenReturn(todoItemData);

      when(
        () => mockNetworkProvider.call(
          path: Endpoints.addTodo,
          method: RequestMethod.post,
          body: {'todo': todo, 'completed': completed, 'userId': userId},
        ),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.addTodo(
        todo: todo,
        completed: completed,
        userId: userId,
      );

      expect(result, isA<TodoItem>());
      expect(result.todo, 'Complete project documentation');
      expect(result.userId, userId);
      verify(
        () => mockNetworkProvider.call(
          path: Endpoints.addTodo,
          method: RequestMethod.post,
          body: {'todo': todo, 'completed': completed, 'userId': userId},
        ),
      ).called(1);
    });

    test('updateTodo should return TodoItem on success', () async {
      const id = 1;
      const todo = 'Updated task';
      const completed = true;
      final todoItemData = FixtureHelper.loadJsonMap('todo_item');

      final response = MockResponse();
      when(() => response.data).thenReturn(todoItemData);

      when(
        () => mockNetworkProvider.call(
          path: Endpoints.todoById(id),
          method: RequestMethod.put,
          body: {'todo': todo, 'completed': completed},
        ),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.updateTodo(
        id: id,
        todo: todo,
        completed: completed,
      );

      expect(result, isA<TodoItem>());
      verify(
        () => mockNetworkProvider.call(
          path: Endpoints.todoById(id),
          method: RequestMethod.put,
          body: {'todo': todo, 'completed': completed},
        ),
      ).called(1);
    });

    test('updateTodo should only include non-null fields in body', () async {
      const id = 1;
      const completed = true;
      final todoItemData = FixtureHelper.loadJsonMap('todo_item');

      final response = MockResponse();
      when(() => response.data).thenReturn(todoItemData);

      when(
        () => mockNetworkProvider.call(
          path: Endpoints.todoById(id),
          method: RequestMethod.put,
          body: {'completed': completed},
        ),
      ).thenAnswer((_) async => response);

      await remoteDataSource.updateTodo(id: id, completed: completed);

      verify(
        () => mockNetworkProvider.call(
          path: Endpoints.todoById(id),
          method: RequestMethod.put,
          body: {'completed': completed},
        ),
      ).called(1);
    });

    test('deleteTodo should return Map<String, dynamic> on success', () async {
      const id = 1;
      final deleteResponse = {'success': true, 'isDeleted': true};

      final response = MockResponse();
      when(() => response.data).thenReturn(deleteResponse);

      when(
        () => mockNetworkProvider.call(
          path: Endpoints.todoById(id),
          method: RequestMethod.delete,
        ),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.deleteTodo(id);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['success'], true);
      verify(
        () => mockNetworkProvider.call(
          path: Endpoints.todoById(id),
          method: RequestMethod.delete,
        ),
      ).called(1);
    });
  });
}
