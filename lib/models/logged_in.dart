class LoggedIn {
  final String localId;
  final String email;
  final String phoneNumber;
  final String firstname;
  final String lastname;
  final String privilege;
  final String allowed;

  LoggedIn(
      {required this.localId,
      required this.email,
      required this.phoneNumber,
      required this.firstname,
      required this.lastname,
      required this.privilege,
      required this.allowed});

  static LoggedIn fromMap(Map<String, dynamic> loggedInUser) => LoggedIn(
      localId: loggedInUser['localId'],
      email: loggedInUser['email'],
      phoneNumber: loggedInUser['phoneNumber'],
      firstname: loggedInUser['firstname'],
      lastname: loggedInUser['lastname'],
      privilege: loggedInUser['privilege'],
      allowed: loggedInUser['allowed']);

}
