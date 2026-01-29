// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'todo_item.dart';

class TodoItemMapper extends ClassMapperBase<TodoItem> {
  TodoItemMapper._();

  static TodoItemMapper? _instance;
  static TodoItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TodoItemMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TodoItem';

  static int _$id(TodoItem v) => v.id;
  static const Field<TodoItem, int> _f$id = Field('id', _$id);
  static String _$todo(TodoItem v) => v.todo;
  static const Field<TodoItem, String> _f$todo = Field('todo', _$todo);
  static bool _$completed(TodoItem v) => v.completed;
  static const Field<TodoItem, bool> _f$completed = Field(
    'completed',
    _$completed,
  );
  static int _$userId(TodoItem v) => v.userId;
  static const Field<TodoItem, int> _f$userId = Field('userId', _$userId);

  @override
  final MappableFields<TodoItem> fields = const {
    #id: _f$id,
    #todo: _f$todo,
    #completed: _f$completed,
    #userId: _f$userId,
  };

  static TodoItem _instantiate(DecodingData data) {
    return TodoItem(
      id: data.dec(_f$id),
      todo: data.dec(_f$todo),
      completed: data.dec(_f$completed),
      userId: data.dec(_f$userId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TodoItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TodoItem>(map);
  }

  static TodoItem fromJson(String json) {
    return ensureInitialized().decodeJson<TodoItem>(json);
  }
}

mixin TodoItemMappable {
  String toJson() {
    return TodoItemMapper.ensureInitialized().encodeJson<TodoItem>(
      this as TodoItem,
    );
  }

  Map<String, dynamic> toMap() {
    return TodoItemMapper.ensureInitialized().encodeMap<TodoItem>(
      this as TodoItem,
    );
  }

  TodoItemCopyWith<TodoItem, TodoItem, TodoItem> get copyWith =>
      _TodoItemCopyWithImpl<TodoItem, TodoItem>(
        this as TodoItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TodoItemMapper.ensureInitialized().stringifyValue(this as TodoItem);
  }

  @override
  bool operator ==(Object other) {
    return TodoItemMapper.ensureInitialized().equalsValue(
      this as TodoItem,
      other,
    );
  }

  @override
  int get hashCode {
    return TodoItemMapper.ensureInitialized().hashValue(this as TodoItem);
  }
}

extension TodoItemValueCopy<$R, $Out> on ObjectCopyWith<$R, TodoItem, $Out> {
  TodoItemCopyWith<$R, TodoItem, $Out> get $asTodoItem =>
      $base.as((v, t, t2) => _TodoItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TodoItemCopyWith<$R, $In extends TodoItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? id, String? todo, bool? completed, int? userId});
  TodoItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TodoItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TodoItem, $Out>
    implements TodoItemCopyWith<$R, TodoItem, $Out> {
  _TodoItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TodoItem> $mapper =
      TodoItemMapper.ensureInitialized();
  @override
  $R call({int? id, String? todo, bool? completed, int? userId}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (todo != null) #todo: todo,
      if (completed != null) #completed: completed,
      if (userId != null) #userId: userId,
    }),
  );
  @override
  TodoItem $make(CopyWithData data) => TodoItem(
    id: data.get(#id, or: $value.id),
    todo: data.get(#todo, or: $value.todo),
    completed: data.get(#completed, or: $value.completed),
    userId: data.get(#userId, or: $value.userId),
  );

  @override
  TodoItemCopyWith<$R2, TodoItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TodoItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

