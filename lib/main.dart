import 'package:flutter/material.dart';
import 'views/Login.dart';
import 'views/GamePage.dart'; // Ensure you have this page for the post-login game lobby

void main() {
  runApp(BattleShips());
}

class BattleShips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battleships',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(), // Starting with the Login screen
      routes: {
        '/login': (context) => Login(), // Login route
        // Assuming '/gamepage' takes a token, you'll have to pass it dynamically in the code
        // '/gamepage': (context) => GamePage(token: "Your token here"), // This will be handled differently
        // Other routes for different screens can be added here
      },
    );
  }
}
