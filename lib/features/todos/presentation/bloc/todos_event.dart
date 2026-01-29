part of 'todos_bloc.dart';

abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodosEvent {
  final int page;
  final int size;

  const LoadTodosEvent({this.page = 0, this.size = 10});

  @override
  List<Object?> get props => [page, size];
}

class LoadTodosByUserEvent extends TodosEvent {
  final int userId;

  const LoadTodosByUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddTodoEvent extends TodosEvent {
  final String todo;
  final int userId;

  const AddTodoEvent({required this.todo, required this.userId});

  @override
  List<Object?> get props => [todo, userId];
}

class UpdateTodoEvent extends TodosEvent {
  final int id;
  final String? todo;
  final bool? completed;

  const UpdateTodoEvent({required this.id, this.todo, this.completed});

  @override
  List<Object?> get props => [id, todo, completed];
}

class DeleteTodoEvent extends TodosEvent {
  final int id;

  const DeleteTodoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class LoadCachedTodosEvent extends TodosEvent {
  const LoadCachedTodosEvent();
}
