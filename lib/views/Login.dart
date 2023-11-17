import 'package:flutter/material.dart';
import '../services/APIservice.dart';
import '../views/GamePage.dart'; // Adjust the import path

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _handleLogin() async {
    try {
      final response = await _apiService.login(
          _usernameController.text, _passwordController.text);
      // Navigate to GamePage with the token
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GamePage(token: response['access_token']),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleRegister() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Registration'),
          content: Text('Are you sure you want to register?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final response = await _apiService.register(
            _usernameController.text, _passwordController.text);
        // Navigate to the game page if registration is successful
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => GamePage(token: response['access_token'])),
        );
      } catch (e) {
        // More detailed error handling
        debugPrint(
            e.toString()); // Use debugPrint to print the error to console
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Registration Failed: $e'), // Show the error in the snackbar
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: _handleRegister,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
