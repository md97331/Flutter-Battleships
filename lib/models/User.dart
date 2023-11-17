class User {
  final int id;
  final String username;
  String sessionToken;

  User({
    required this.id,
    required this.username,
    required this.sessionToken,
  });

  void updateSessionToken(String newSessionToken) {
    // Update the session token of the user
    sessionToken = newSessionToken;
  }
  // Additional methods related to user data can be added here.
}