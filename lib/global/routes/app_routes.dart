import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:todo_app/features/authentication/presentation/views/login.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';
import 'package:todo_app/features/todos/presentation/views/add_update_todo.dart';
import 'package:todo_app/features/todos/presentation/views/todos.dart';

class AppRoutes {
  static String login = '/login';
  static String todos = '/todos';
  static String addTodo = '/add-todo';
  static String editTodo = '/edit-todo';

  static GoRouter router(AuthenticationBloc? authBloc) {
    return GoRouter(
      initialLocation: login,
      redirect: (context, state) {
        if (authBloc != null) {
          final authState = authBloc.state;
          final isAuthenticated =
              authState is AuthenticationAuthenticated ||
              authState is LoginSuccess;
          final isLoggingIn = state.matchedLocation == login;

          if (!isAuthenticated && !isLoggingIn) {
            return login;
          }

          if (isAuthenticated && isLoggingIn) {
            return todos;
          }
        }

        return null;
      },
      refreshListenable: authBloc != null
          ? GoRouterRefreshStream(authBloc.stream)
          : null,
      routes: [
        GoRoute(path: login, builder: (context, state) => const LoginScreen()),
        GoRoute(path: todos, builder: (context, state) => const TodosScreen()),
        GoRoute(
          path: addTodo,
          builder: (context, state) {
            final user = state.extra as User;
            return AddUpdateTodoScreen(user: user);
          },
        ),
        GoRoute(
          path: '$editTodo/:id',
          builder: (context, state) {
            final params = state.extra as Map<String, dynamic>;
            final todo = params['todo'] as TodoItem;
            final user = params['user'] as User;
            return AddUpdateTodoScreen(todo: todo, user: user);
          },
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
