import 'package:flutter/material.dart';
import 'views/Login.dart';
import 'views/GamePage.dart'; // Ensure you have this page for the post-login game lobby

//FOR FORFEIT A GAME: LONG PRESS ON THE GAME YOU WANT TO FORFEIT AND IT WILL BE FORFEITED

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
        },
    );
  }
}
