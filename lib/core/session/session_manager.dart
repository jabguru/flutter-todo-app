import 'package:flutter/foundation.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';

class SessionManager extends ChangeNotifier {
  User? _currentUser;
  String? _authToken;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void setAuthToken(String token) {
    _authToken = token;
    notifyListeners();
  }

  void clearSession() {
    _currentUser = null;
    _authToken = null;
    notifyListeners();
  }

  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;
}
