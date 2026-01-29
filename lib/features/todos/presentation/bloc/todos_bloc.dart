import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/data/models/paginated_response.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';
import 'package:todo_app/features/todos/domain/repositories/todos_repository.dart';

part 'todos_event.dart';
part 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepository _repository;

  List<TodoItem> _currentTodos = [];

  TodosBloc({required TodosRepository repository})
    : _repository = repository,
      super(TodosInitial()) {
    on<LoadTodosEvent>(_handleLoadTodos);
    on<LoadTodosByUserEvent>(_handleLoadTodosByUser);
    on<AddTodoEvent>(_handleAddTodo);
    on<UpdateTodoEvent>(_handleUpdateTodo);
    on<DeleteTodoEvent>(_handleDeleteTodo);
    on<LoadCachedTodosEvent>(_handleLoadCachedTodos);
  }

  Future<void> _handleLoadTodos(
    LoadTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    if (event.page == 0) {
      emit(TodosLoading());
      _currentTodos = [];
    } else {
      emit(TodosLoadingMore(currentTodos: _currentTodos));
    }

    final res = await _repository.getTodos(page: event.page, size: event.size);

    res.fold(
      (failure) async {
        // Try to load cached todos on error
        final cachedResult = await _repository.getCachedTodos();
        cachedResult.fold(
          (_) =>
              emit(TodosError(message: failure.message, title: failure.title)),
          (cachedTodos) => emit(
            TodosError(
              message: failure.message,
              title: failure.title,
              cachedTodos: cachedTodos,
            ),
          ),
        );
      },
      (paginatedResponse) {
        if (event.page == 0) {
          _currentTodos = paginatedResponse.data;
        } else {
          _currentTodos.addAll(paginatedResponse.data);
        }

        final updatedPaginatedResponse = PaginatedResponseModel<TodoItem>(
          data: List.from(_currentTodos),
          pageNumber: paginatedResponse.pageNumber,
          pageSize: paginatedResponse.pageSize,
          totalElements: paginatedResponse.totalElements,
          totalPages: paginatedResponse.totalPages,
          last: paginatedResponse.last,
          numberOfElements: _currentTodos.length,
        );

        emit(TodosLoaded(todos: updatedPaginatedResponse));
      },
    );
  }

  Future<void> _handleLoadTodosByUser(
    LoadTodosByUserEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodosLoading());

    final res = await _repository.getTodosByUser(userId: event.userId);

    res.fold(
      (failure) =>
          emit(TodosError(message: failure.message, title: failure.title)),
      (response) {
        final todos = (response['todos'] as List)
            .map((json) => TodoItem.fromMap(json))
            .toList();

        _currentTodos = todos;

        final paginatedResponse = PaginatedResponseModel<TodoItem>(
          data: todos,
          pageNumber: 0,
          pageSize: todos.length,
          totalElements: response['total'] as int,
          totalPages: 1,
          last: true,
          numberOfElements: todos.length,
        );

        emit(TodosLoaded(todos: paginatedResponse));
      },
    );
  }

  Future<void> _handleAddTodo(
    AddTodoEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodoOperationLoading());

    final res = await _repository.addTodo(
      todo: event.todo,
      completed: false,
      userId: event.userId,
    );

    res.fold(
      (failure) => emit(
        TodoOperationError(message: failure.message, title: failure.title),
      ),
      (todo) => emit(TodoAddedSuccess(todo: todo)),
    );
  }

  Future<void> _handleUpdateTodo(
    UpdateTodoEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodoOperationLoading());

    final res = await _repository.updateTodo(
      id: event.id,
      todo: event.todo,
      completed: event.completed,
    );

    res.fold(
      (failure) => emit(
        TodoOperationError(message: failure.message, title: failure.title),
      ),
      (todo) => emit(TodoUpdatedSuccess(todo: todo)),
    );
  }

  Future<void> _handleDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodoOperationLoading());

    final res = await _repository.deleteTodo(event.id);

    res.fold(
      (failure) => emit(
        TodoOperationError(message: failure.message, title: failure.title),
      ),
      (_) => emit(TodoDeletedSuccess(todoId: event.id)),
    );
  }

  Future<void> _handleLoadCachedTodos(
    LoadCachedTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodosLoading());

    final res = await _repository.getCachedTodos();

    res.fold(
      (failure) =>
          emit(TodosError(message: failure.message, title: failure.title)),
      (todos) {
        _currentTodos = todos;

        final paginatedResponse = PaginatedResponseModel<TodoItem>(
          data: todos,
          pageNumber: 0,
          pageSize: todos.length,
          totalElements: todos.length,
          totalPages: 1,
          last: true,
          numberOfElements: todos.length,
        );

        emit(TodosLoaded(todos: paginatedResponse));
      },
    );
  }
}
