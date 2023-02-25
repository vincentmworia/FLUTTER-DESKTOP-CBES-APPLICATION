enum OnlineConnectionState { online, offline }

class OnlineUser {
  final String platform;
  final String email;
  final String firstName;
  final String lastName;
  final OnlineConnectionState onlineState;

  OnlineUser({
    required this.platform,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.onlineState,
  });
}
