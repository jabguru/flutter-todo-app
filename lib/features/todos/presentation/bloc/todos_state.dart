part of 'todos_bloc.dart';

abstract class TodosState extends Equatable {
  const TodosState();

  @override
  List<Object?> get props => [];
}

class TodosInitial extends TodosState {}

class TodosLoading extends TodosState {}

class TodosLoadingMore extends TodosState {
  final List<TodoItem> currentTodos;

  const TodosLoadingMore({required this.currentTodos});

  @override
  List<Object?> get props => [currentTodos];
}

class TodosLoaded extends TodosState {
  final PaginatedResponseModel<TodoItem> todos;

  const TodosLoaded({required this.todos});

  @override
  List<Object?> get props => [todos];
}

class TodosError extends TodosState {
  final String message;
  final String? title;
  final List<TodoItem>? cachedTodos;

  const TodosError({required this.message, this.title, this.cachedTodos});

  @override
  List<Object?> get props => [message, title, cachedTodos];
}

class TodoOperationLoading extends TodosState {}

class TodoAddedSuccess extends TodosState {
  final TodoItem todo;

  const TodoAddedSuccess({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class TodoUpdatedSuccess extends TodosState {
  final TodoItem todo;

  const TodoUpdatedSuccess({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class TodoDeletedSuccess extends TodosState {
  final int todoId;

  const TodoDeletedSuccess({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

class TodoOperationError extends TodosState {
  final String message;
  final String? title;

  const TodoOperationError({required this.message, this.title});

  @override
  List<Object?> get props => [message, title];
}
