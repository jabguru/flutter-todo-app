import 'package:go_router/go_router.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/authentication/presentation/views/login.dart';
import 'package:todo_app/features/authentication/presentation/views/splash_screen.dart';
import 'package:todo_app/features/todos/domain/models/todo_item.dart';
import 'package:todo_app/features/todos/presentation/views/add_update_todo.dart';
import 'package:todo_app/features/todos/presentation/views/todos.dart';

class AppRoutes {
  static String splash = '/';
  static String login = '/login';
  static String todos = '/todos';
  static String addTodo = '/add-todo';
  static String editTodo = '/edit-todo';

  static GoRouter router() {
    return GoRouter(
      initialLocation: splash,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
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
