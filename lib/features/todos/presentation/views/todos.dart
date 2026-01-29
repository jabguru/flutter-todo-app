import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';
import 'package:todo_app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:todo_app/features/todos/presentation/widgets/app_header.dart';
import 'package:todo_app/features/todos/presentation/widgets/primary_button.dart';
import 'package:todo_app/features/todos/presentation/widgets/todo_checkbox.dart';
import 'package:todo_app/global/extensions/context_extension.dart';
import 'package:todo_app/global/routes/app_routes.dart';
import 'package:todo_app/global/theme/colors.dart';
import 'package:todo_app/global/widgets/space.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final ScrollController _scrollController = ScrollController();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Get current user and load todos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthenticationBloc>().state;
      if (authState is AuthenticationAuthenticated) {
        _currentUser = authState.user;
        context.read<TodosBloc>().add(const LoadTodosEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<TodosBloc>().state;
      if (state is TodosLoaded && !state.todos.last) {
        context.read<TodosBloc>().add(
          LoadTodosEvent(page: state.todos.nextPage),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state is TodoAddedSuccess ||
              state is TodoUpdatedSuccess ||
              state is TodoDeletedSuccess) {
            // Reload todos after successful operation
            context.read<TodosBloc>().add(const LoadTodosEvent());
          } else if (state is TodoOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            AppHeader(
              title: 'My Todo List',
              trailing: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthenticationBloc>().add(const LogoutEvent());
                  context.go(AppRoutes.login);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<TodosBloc, TodosState>(
                builder: (context, state) {
                  if (state is TodosLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TodosError) {
                    if (state.cachedTodos != null &&
                        state.cachedTodos!.isNotEmpty) {
                      return _buildTodosList(
                        state.cachedTodos!,
                        showOfflineBanner: true,
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          const VerticalSpacing(16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TodosBloc>().add(
                                const LoadTodosEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TodosLoaded || state is TodosLoadingMore) {
                    final todos = state is TodosLoaded
                        ? state.todos.data
                        : (state as TodosLoadingMore).currentTodos;

                    return _buildTodosList(
                      todos,
                      isLoadingMore: state is TodosLoadingMore,
                      hasMore: state is TodosLoaded ? !state.todos.last : false,
                    );
                  }

                  return const Center(child: Text('No todos yet'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: PrimaryButton(
        text: 'Add New Task',
        onPressed: () {
          if (_currentUser != null) {
            context.push(AppRoutes.addTodo, extra: _currentUser);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTodosList(
    List<TodoItem> todos, {
    bool showOfflineBanner = false,
    bool isLoadingMore = false,
    bool hasMore = false,
  }) {
    final activeTodos = todos.where((todo) => !todo.completed).toList();
    final completedTodos = todos.where((todo) => todo.completed).toList();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (showOfflineBanner)
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange),
                HorizontalSpacing(8),
                Expanded(
                  child: Text(
                    'Showing cached data. Please check your connection.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        const VerticalSpacing(24),
        if (activeTodos.isNotEmpty) ...[
          Text('Active Tasks', style: context.textTheme.titleMedium),
          const VerticalSpacing(8),
          _buildTodoList(activeTodos, false),
          const VerticalSpacing(24),
        ],
        if (completedTodos.isNotEmpty) ...[
          Text('Completed', style: context.textTheme.titleMedium),
          const VerticalSpacing(8),
          _buildTodoList(completedTodos, true),
          const VerticalSpacing(24),
        ],
        if (isLoadingMore)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
        if (!isLoadingMore && hasMore)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Scroll for more...'),
            ),
          ),
        const VerticalSpacing(100),
      ],
    );
  }

  Widget _buildTodoList(List<TodoItem> todos, bool isCompleted) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: todos.asMap().entries.map((entry) {
          final index = entry.key;
          final todo = entry.value;
          return _buildTodoItem(todo, index < todos.length - 1);
        }).toList(),
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo, bool showDivider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              )
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TodoCheckbox(
            isChecked: todo.completed,
            onTap: () {
              context.read<TodosBloc>().add(
                UpdateTodoEvent(id: todo.id, completed: !todo.completed),
              );
            },
          ),
          const HorizontalSpacing(12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_currentUser != null) {
                  context.push(
                    '${AppRoutes.editTodo}/${todo.id}',
                    extra: {'todo': todo, 'user': _currentUser},
                  );
                }
              },
              child: Text(
                todo.todo,
                style: context.textTheme.titleMedium?.copyWith(
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.completed
                      ? AppColors.textPrimary.withValues(alpha: 0.5)
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const HorizontalSpacing(12),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmation(todo.id);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int todoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TodosBloc>().add(DeleteTodoEvent(id: todoId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
