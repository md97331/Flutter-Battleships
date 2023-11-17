import 'package:flutter/material.dart';
import '../models/Game.dart'; // Adjust the import path

class GameList extends StatelessWidget {
  final List<Game> games; // This should be fetched from your backend

  GameList({Key? key, required this.games}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game List'),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return ListTile(
            title: Text('Game ${game.id}'),
            subtitle: Text('Status: ${game.status}'),
            onTap: () {
              // Navigate to GameView with the selected game
            },
          );
        },
      ),
    );
  }
}