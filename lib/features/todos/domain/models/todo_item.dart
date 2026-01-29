import 'package:dart_mappable/dart_mappable.dart';

part 'todo_item.mapper.dart';

@MappableClass()
class TodoItem with TodoItemMappable {
  final int id;
  final String todo;
  final bool completed;
  final int userId;

  const TodoItem({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  factory TodoItem.fromJson(String json) => TodoItemMapper.fromJson(json);

  factory TodoItem.fromMap(Map<String, dynamic> map) =>
      TodoItemMapper.fromMap(map);
}
