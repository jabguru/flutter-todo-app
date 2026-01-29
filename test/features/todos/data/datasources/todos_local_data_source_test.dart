import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/storage/local_storage.dart';
import 'package:todo_app/features/todos/data/datasources/todos_local_data_source.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';

class MockSharedPrefStorage extends Mock implements SharedPrefStorage {}

void main() {
  late TodosLocalDataSourceImpl localDataSource;
  late MockSharedPrefStorage mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPrefStorage();
    localDataSource = TodosLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('TodosLocalDataSource', () {
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
    ];

    test('cacheTodos should save todos to shared preferences', () async {
      when(
        () => mockSharedPreferences.put(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => true);

      await localDataSource.cacheTodos(todosList);

      verify(
        () => mockSharedPreferences.put(
          key: 'CACHED_TODOS_KEY',
          value: any(named: 'value'),
        ),
      ).called(1);
    });

    test(
      'getCachedTodos should return list of todos from shared preferences',
      () async {
        final todosJson = jsonEncode([
          {
            'id': 1,
            'todo': 'Complete project documentation',
            'completed': false,
            'userId': 5,
          },
          {'id': 2, 'todo': 'Write unit tests', 'completed': true, 'userId': 5},
        ]);

        when(
          () => mockSharedPreferences.get('CACHED_TODOS_KEY'),
        ).thenAnswer((_) async => todosJson);

        final result = await localDataSource.getCachedTodos();

        expect(result, isA<List<TodoItem>>());
        expect(result.length, 2);
        expect(result[0].todo, 'Complete project documentation');
        expect(result[1].completed, true);
        verify(() => mockSharedPreferences.get('CACHED_TODOS_KEY')).called(1);
      },
    );

    test(
      'getCachedTodos should return empty list when cache is empty',
      () async {
        when(
          () => mockSharedPreferences.get('CACHED_TODOS_KEY'),
        ).thenThrow(const LocalStorageException('No data found'));

        final result = await localDataSource.getCachedTodos();

        expect(result, isEmpty);
        verify(() => mockSharedPreferences.get('CACHED_TODOS_KEY')).called(1);
      },
    );

    test('clearCache should delete cached todos', () async {
      when(
        () => mockSharedPreferences.delete(any()),
      ).thenAnswer((_) async => true);

      await localDataSource.clearCache();

      verify(
        () => mockSharedPreferences.delete({'CACHED_TODOS_KEY'}),
      ).called(1);
    });
  });
}
