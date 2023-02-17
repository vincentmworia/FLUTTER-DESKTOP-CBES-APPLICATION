class Signin {
  final String localId;
  final String email;
  final String displayName;
  final String idToken;
  final String refreshToken;
  final bool registered;
  final String expiresIn;

  Signin({
    required this.localId,
    required this.email,
    required this.displayName,
    required this.idToken,
    required this.refreshToken,
    required this.registered,
    required this.expiresIn,
  });

  static Signin fromMap(Map<String, dynamic> signedInUser) => Signin(
      localId: signedInUser['localId'],
      email: signedInUser['email'],
      displayName: signedInUser['displayName'],
      idToken: signedInUser['idToken'],
      refreshToken: signedInUser['refreshToken'],
      registered: signedInUser['registered'],
      expiresIn: signedInUser['expiresIn']);
}

