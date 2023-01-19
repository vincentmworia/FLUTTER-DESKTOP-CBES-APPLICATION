import 'package:flutter/foundation.dart';

import '../models/logged_in.dart';

class LoginUserData with ChangeNotifier {
  LoggedIn? _loggedInUser;

  LoggedIn get loggedInUser => _loggedInUser!;
  static LoggedIn? getLoggedUser;

  void setLoggedInUser(LoggedIn loggedIn) {
    _loggedInUser = loggedIn;
    getLoggedUser = loggedIn;
    notifyListeners();
  }

  void resetLoggedInUser() {
    _loggedInUser = null;
  }
}
