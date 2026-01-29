import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';
import 'package:todo_app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:todo_app/features/todos/presentation/widgets/app_header.dart';
import 'package:todo_app/features/todos/presentation/widgets/custom_text_field.dart';
import 'package:todo_app/features/todos/presentation/widgets/primary_button.dart';
import 'package:todo_app/global/extensions/context_extension.dart';
import 'package:todo_app/global/theme/colors.dart';
import 'package:todo_app/global/widgets/space.dart';

class AddUpdateTodoScreen extends StatefulWidget {
  final TodoItem? todo;
  final User user;

  const AddUpdateTodoScreen({super.key, this.todo, required this.user});

  @override
  State<AddUpdateTodoScreen> createState() => _AddUpdateTodoScreenState();
}

class _AddUpdateTodoScreenState extends State<AddUpdateTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _todoController = TextEditingController();
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.todo != null;
    if (_isEditMode) {
      _todoController.text = widget.todo!.todo;
    }
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isEditMode) {
        context.read<TodosBloc>().add(
          UpdateTodoEvent(
            id: widget.todo!.id,
            todo: _todoController.text.trim(),
          ),
        );
      } else {
        context.read<TodosBloc>().add(
          AddTodoEvent(
            todo: _todoController.text.trim(),
            userId: widget.user.id,
          ),
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
          if (state is TodoAddedSuccess || state is TodoUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Todo updated successfully'
                      : 'Todo added successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
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
              title: _isEditMode ? 'Edit Task' : 'Add New Task',
              canPop: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const VerticalSpacing(24),
                      CustomTextField(
                        label: 'Task',
                        hintText: 'Enter your task',
                        controller: _todoController,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task';
                          }
                          return null;
                        },
                      ),
                      const VerticalSpacing(24),
                      Text(
                        'Note: DummyJSON API simulates operations but doesn\'t persist data permanently.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const VerticalSpacing(100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<TodosBloc, TodosState>(
        builder: (context, state) {
          return PrimaryButton(
            text: _isEditMode ? 'Update' : 'Save',
            onPressed: state is TodoOperationLoading ? null : _handleSave,
            isLoading: state is TodoOperationLoading,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
