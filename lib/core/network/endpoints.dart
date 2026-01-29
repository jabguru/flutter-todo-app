class Endpoints {
  Endpoints._();

  static late final String baseUrl;

  // Authentication
  static const String login = 'https://dummyjson.com/auth/login';
  static const String currentUser = 'https://dummyjson.com/auth/me';

  // Todos
  static String todosByUser(int userId) =>
      'https://dummyjson.com/todos/user/$userId';
  static String todoById(int id) => 'https://dummyjson.com/todos/$id';
  static const String addTodo = 'https://dummyjson.com/todos/add';
}
