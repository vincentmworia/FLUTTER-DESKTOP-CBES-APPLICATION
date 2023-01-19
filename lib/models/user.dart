class User {
  String? localId;
  String? email;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  String? password;
  String? privilege;
  String? allowed;
  bool? autoLogin = false;

  User({
    this.localId,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.password,
    this.privilege,
    this.allowed,
    this.autoLogin,
  });

  static User fromMap(Map<String, dynamic> user) => User(
        localId: user['localId'] as String,
        email: user['email'] as String,
        phoneNumber: user['phoneNumber'] as String,
        firstName: user['firstname'] as String,
        lastName: user['lastname'] as String,
        password: user['password'] as String,
        privilege: user['password'] as String,
        allowed: user['allowed'] as String,
      );

  static User fromLoginMap(Map<String, dynamic> user) => User(
        email: user['email'] as String,
        password: user['password'] as String,
      );

  Map<String, dynamic> toMap() => {
        "localId": localId,
        "email": email,
        "phoneNumber": phoneNumber,
        "firstname": firstName,
        "lastname": lastName,
        "password": password,
        "privilege": privilege,
        "allowed": allowed,
      };

  Map<String, dynamic> toLoginMap() => {
        "email": email,
        "password": password,
      };
}
