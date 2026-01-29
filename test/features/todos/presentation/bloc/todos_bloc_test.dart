import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/data/models/paginated_response.dart';
import 'package:todo_app/core/network/error/failures.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';
import 'package:todo_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:todo_app/features/todos/presentation/bloc/todos_bloc.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  late MockTodosRepository mockRepository;

  setUp(() {
    mockRepository = MockTodosRepository();
  });

  group('TodosBloc', () {
    const userId = 5;

    // Helper to create fresh todo items for each test
    List<TodoItem> getTodosList() => const [
      TodoItem(
        id: 1,
        todo: 'Complete project documentation',
        completed: false,
        userId: 5,
      ),
      TodoItem(id: 2, todo: 'Write unit tests', completed: true, userId: 5),
      TodoItem(
        id: 3,
        todo: 'Review pull requests',
        completed: false,
        userId: 5,
      ),
    ];

    PaginatedResponseModel<TodoItem> getPaginatedResponse() =>
        PaginatedResponseModel<TodoItem>(
          data: getTodosList(),
          pageNumber: 0,
          pageSize: 10,
          totalElements: 150,
          totalPages: 15,
          last: false,
          numberOfElements: 3,
        );

    test('initial state is TodosInitial', () {
      final bloc = TodosBloc(repository: mockRepository);
      expect(bloc.state, TodosInitial());
      bloc.close();
    });

    blocTest<TodosBloc, TodosState>(
      'emits [TodosLoading, TodosLoaded] when LoadTodosEvent is added with page 0 and success',
      build: () {
        when(
          () => mockRepository.getTodos(page: 0, size: 10, userId: userId),
        ).thenAnswer((_) async => Right(getPaginatedResponse()));
        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) =>
          bloc.add(const LoadTodosEvent(userId: userId, page: 0, size: 10)),
      expect: () => [
        TodosLoading(),
        isA<TodosLoaded>()
            .having((state) => state.todos.data.length, 'todos length', 3)
            .having(
              (state) => state.todos.totalElements,
              'total elements',
              150,
            ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getTodos(page: 0, size: 10, userId: userId),
        ).called(1);
      },
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodosLoadingMore, TodosLoaded] when LoadTodosEvent is added with page > 0',
      build: () {
        final page1Response = PaginatedResponseModel<TodoItem>(
          data: const [
            TodoItem(id: 4, todo: 'New task', completed: false, userId: 5),
          ],
          pageNumber: 1,
          pageSize: 10,
          totalElements: 150,
          totalPages: 15,
          last: false,
          numberOfElements: 1,
        );

        when(
          () => mockRepository.getTodos(page: 1, size: 10, userId: userId),
        ).thenAnswer((_) async => Right(page1Response));

        return TodosBloc(repository: mockRepository);
      },
      seed: () => TodosLoaded(todos: getPaginatedResponse()),
      act: (bloc) =>
          bloc.add(const LoadTodosEvent(userId: userId, page: 1, size: 10)),
      expect: () => [
        isA<TodosLoadingMore>().having(
          (state) => state.currentTodos.length,
          'current todos',
          3,
        ),
        isA<TodosLoaded>()
            .having((state) => state.todos.data.length, 'todos length', 4)
            .having((state) => state.todos.numberOfElements, 'num elements', 4),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodosLoading, TodosError] when LoadTodosEvent fails and no cached todos',
      build: () {
        when(
          () => mockRepository.getTodos(page: 0, size: 10, userId: userId),
        ).thenAnswer((_) async => Left(Failure(message: 'Network error')));

        when(
          () => mockRepository.getCachedTodos(),
        ).thenAnswer((_) async => Left(Failure(message: 'No cache')));

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) =>
          bloc.add(const LoadTodosEvent(userId: userId, page: 0, size: 10)),
      expect: () => [
        TodosLoading(),
        const TodosError(message: 'Network error'),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodosLoading, TodosError with cached todos] when LoadTodosEvent fails but has cached todos',
      build: () {
        when(
          () => mockRepository.getTodos(page: 0, size: 10, userId: userId),
        ).thenAnswer((_) async => Left(Failure(message: 'User not found')));

        when(
          () => mockRepository.getCachedTodos(),
        ).thenAnswer((_) async => Right(getTodosList()));

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) =>
          bloc.add(const LoadTodosEvent(userId: userId, page: 0, size: 10)),
      expect: () => [
        TodosLoading(),
        isA<TodosError>()
            .having((state) => state.message, 'error message', 'User not found')
            .having((state) => state.cachedTodos?.length, 'cached todos', 3),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodoOperationLoading, TodoAddedSuccess] when AddTodoEvent is successful',
      build: () {
        when(
          () => mockRepository.addTodo(
            todo: any(named: 'todo'),
            completed: any(named: 'completed'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => Right(
            const TodoItem(
              id: 4,
              todo: 'New task',
              completed: false,
              userId: 5,
            ),
          ),
        );

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const AddTodoEvent(todo: 'New task', userId: 5)),
      expect: () => [
        const TodoOperationLoading(),
        isA<TodoAddedSuccess>()
            .having((state) => state.todo.id, 'id', 4)
            .having((state) => state.todo.todo, 'todo', 'New task'),
      ],
      verify: (_) {
        verify(
          () => mockRepository.addTodo(
            todo: 'New task',
            completed: false,
            userId: 5,
          ),
        ).called(1);
      },
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodoOperationLoading, TodoOperationError] when AddTodoEvent fails',
      build: () {
        when(
          () => mockRepository.addTodo(
            todo: any(named: 'todo'),
            completed: any(named: 'completed'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => Left(Failure(message: 'Failed to create todo')),
        );

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const AddTodoEvent(todo: 'New task', userId: 5)),
      expect: () => [
        const TodoOperationLoading(),
        const TodoOperationError(message: 'Failed to create todo'),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodoOperationLoading, TodoUpdatedSuccess] when UpdateTodoEvent is successful',
      build: () {
        when(
          () => mockRepository.updateTodo(
            id: any(named: 'id'),
            todo: any(named: 'todo'),
            completed: any(named: 'completed'),
          ),
        ).thenAnswer(
          (_) async => Right(
            const TodoItem(
              id: 1,
              todo: 'Updated task',
              completed: true,
              userId: 5,
            ),
          ),
        );

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const UpdateTodoEvent(id: 1, todo: 'Updated task', completed: true),
      ),
      expect: () => [
        const TodoOperationLoading(),
        isA<TodoUpdatedSuccess>()
            .having((state) => state.todo.id, 'id', 1)
            .having((state) => state.todo.todo, 'todo', 'Updated task')
            .having((state) => state.todo.completed, 'completed', true),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodoOperationLoading, TodoOperationError] when UpdateTodoEvent fails',
      build: () {
        when(
          () => mockRepository.updateTodo(
            id: any(named: 'id'),
            todo: any(named: 'todo'),
            completed: any(named: 'completed'),
          ),
        ).thenAnswer(
          (_) async => Left(Failure(message: 'Failed to update todo')),
        );

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const UpdateTodoEvent(id: 1, todo: 'Updated task', completed: true),
      ),
      expect: () => [
        const TodoOperationLoading(),
        const TodoOperationError(message: 'Failed to update todo'),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodoOperationLoading, TodoOperationSuccess] when DeleteTodoEvent is successful',
      build: () {
        when(
          () => mockRepository.deleteTodo(1),
        ).thenAnswer((_) async => const Right(null));

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const DeleteTodoEvent(id: 1)),
      expect: () => [
        const TodoOperationLoading(),
        const TodoDeletedSuccess(todoId: 1),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteTodo(1)).called(1);
      },
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodoOperationLoading, TodoOperationError] when DeleteTodoEvent fails',
      build: () {
        when(() => mockRepository.deleteTodo(any())).thenAnswer(
          (_) async => Left(Failure(message: 'Failed to delete todo')),
        );

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const DeleteTodoEvent(id: 1)),
      expect: () => [
        const TodoOperationLoading(),
        const TodoOperationError(message: 'Failed to delete todo'),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodosLoading, TodosLoaded] when LoadCachedTodosEvent is successful',
      build: () {
        when(
          () => mockRepository.getCachedTodos(),
        ).thenAnswer((_) async => Right(getTodosList()));

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadCachedTodosEvent()),
      expect: () => [
        TodosLoading(),
        isA<TodosLoaded>()
            .having((state) => state.todos.data.length, 'todos length', 3)
            .having((state) => state.todos.last, 'is last', true),
      ],
      verify: (_) {
        verify(() => mockRepository.getCachedTodos()).called(1);
      },
    );

    blocTest<TodosBloc, TodosState>(
      'emits [TodosLoading, TodosError] when LoadCachedTodosEvent fails',
      build: () {
        when(
          () => mockRepository.getCachedTodos(),
        ).thenAnswer((_) async => Left(Failure(message: 'No cached data')));

        return TodosBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadCachedTodosEvent()),
      expect: () => [
        TodosLoading(),
        const TodosError(message: 'No cached data'),
      ],
    );
  });
}
