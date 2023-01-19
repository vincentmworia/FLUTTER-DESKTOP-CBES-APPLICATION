class SignUp {
  final String idToken;
  final String email;
  final String refreshToken;
  final String expiresIn;
  final String localId;

  SignUp(
      {required this.idToken,
      required this.email,
      required this.refreshToken,
      required this.expiresIn,
      required this.localId});

  static SignUp fromMap(Map<String, dynamic> signedUpUser) => SignUp(
        idToken: signedUpUser["idToken"],
        email: signedUpUser["email"],
        refreshToken: signedUpUser["refreshToken"],
        expiresIn: signedUpUser["expiresIn"],
        localId: signedUpUser["localId"],
      );
}
