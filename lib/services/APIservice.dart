import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'http://165.227.117.48'; // Replace with your server IP and port

  Future<Map<String, dynamic>> register(
      String username, String password) async {
    if (username.length < 3 || username.contains(' ')) {
      throw Exception(
          'Username must be at least 3 characters long and cannot contain spaces.');
    }
    if (password.length < 3 || password.contains(' ')) {
      throw Exception(
          'Password must be at least 3 characters long and cannot contain spaces.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      // Parse the error message from the API response if available
      final responseBody = jsonDecode(response.body);
      final errorMessage = responseBody['message'] ?? 'Unknown error occurred.';
      throw Exception('Failed to register user: $errorMessage');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> getGames(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve games');
    }
  }

  Future<Map<String, dynamic>> startGame(List<String> ships, String accessToken,
      {String? ai}) async {
        String? aitype = ai;
    if (ai == null) {
      aitype = null;
    } else {
      aitype = ai;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/games'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'ships': ships,
        'ai': aitype,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      print('Failed to start game: ${response.statusCode}');
      print('Response body: ${response.body}');
      // If the server sends a response body, use it to throw a more specific error
      final responseBody = jsonDecode(response.body);
      final errorMessage = responseBody['message'] ?? 'Unknown error occurred.';
      throw Exception('Failed to start game: $errorMessage');
    }
  }

  Future<Map<String, dynamic>> getGameDetails(
      int gameId, String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get game details');
    }
  }

  Future<Map<String, dynamic>> playShot(
      int gameId, String shot, String accessToken) async {
    final response = await http.put(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'shot': shot}),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to play shot');
    }
  }

  Future<Map<String, dynamic>> cancelGame(
      int gameId, String accessToken) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      print(response.body);
      throw Exception('Failed to cancel game');
    }
  }
}
