
import 'package:flutter/material.dart';
import '../models/Game.dart';
import '../services/APIservice.dart';
import 'GameView.dart';

class CompletedGamesPage extends StatefulWidget {
  final String token;

  CompletedGamesPage({Key? key, required this.token}) : super(key: key);

  @override
  _CompletedGamesPageState createState() => _CompletedGamesPageState();
}

class _CompletedGamesPageState extends State<CompletedGamesPage> {
  final ApiService _apiService = ApiService();
  List<Game> completedGames = [];

  @override
  void initState() {
    super.initState();
    _fetchCompletedGames();
  }

  void _fetchCompletedGames() async {
    try {
      final response = await _apiService.getGames(widget.token);
      if (response['games'] != null) {
        var gamesList = List<Map<String, dynamic>>.from(response['games']);
        var filteredGames = gamesList.where((gameMap) {
          var game = Game.fromJson(gameMap);
          return game.status == 1 || game.status == 2; // Completed games
        }).toList();

        setState(() {
          completedGames =
              filteredGames.map((gameMap) => Game.fromJson(gameMap)).toList();
        });
      } else {
        setState(() => completedGames = []);
      }
    } catch (e) {
      print("Error fetching completed games: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Games'),
      ),
      body: completedGames.isEmpty
          ? Center(child: Text('No completed games.'))
          : ListView.builder(
              itemCount: completedGames.length,
              itemBuilder: (context, index) {
                final game = completedGames[index];
                String gameStatusText = game.status == 1
                    ? game.player1 + ' won'
                    : game.player2 + ' won';
                String gameDetailsText = 'Game #${game.id}: ${game.player1} VS ${game.player2}';

                return ListTile(
                  title: Text(gameDetailsText),
                  subtitle: Text(gameStatusText),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            GameView(game: game, token: widget.token),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
