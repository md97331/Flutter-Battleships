import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionTokenKey = 'sessionToken';
  static const String _usernameKey = 'username';

  // Method to check if a user is logged in (has an active session).
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString(_sessionTokenKey);
    return sessionToken != null && sessionToken.isNotEmpty;
  }

  // Method to retrieve the session token.
  static Future<String> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionTokenKey) ?? '';
  }

  // Method to set the session token.
  static Future<void> setSessionToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, token);
  }

  // Method to clear the session token, effectively logging the user out.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_usernameKey); // Also clear the username
  }

  // Method to save the username.
  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Method to get the saved username.
  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? '';
  }
}
