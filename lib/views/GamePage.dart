import 'package:battleships/models/Game.dart';
import 'package:flutter/material.dart';
import '../services/APIservice.dart';
import '../views/GameShips.dart'; // Ensure this file is created for the New Game screen
import 'GameView.dart'; // Ensure this file is created for the Game View screen

class GamePage extends StatefulWidget {
  String token;

  GamePage({Key? key, required this.token}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final ApiService _apiService = ApiService();
  List<Game> activeGames =
      []; // Assuming 'Game' is a model class for your games

  @override
  void initState() {
    super.initState();
    _fetchActiveGames();
  }

  void _fetchActiveGames() async {
    try {
      final response = await _apiService.getGames(widget.token);
      if (response['games'] != null) {
        setState(() {
          activeGames = List<Game>.from(
              response['games'].map<Game>((json) => Game.fromJson(json)));
        });
      } else {
        print("Response did not contain any 'games' key.");
        setState(() {
          activeGames = []; // Reset the games list if no games were found
        });
      }
    } catch (e) {
      print("Error fetching games: $e");
    }
  }

  void _playAgainstAI() async {
    // Start a new game with AI and navigate directly to GameView
    try {
      final response =
          await _apiService.startGame([], widget.token, ai: 'random');
      Game game = Game.fromJson(response);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => GameView(game: game, token: widget.token),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start AI game: $e')),
      );
    }
  }

  void _startNewGame() async {
    // Navigate to GameShips to select ships and start a new game
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameShips(token: widget.token),
      ),
    );
    // After returning from the GameShips screen, refresh the list of games
    _fetchActiveGames();
  }

  void _logout() async {
    widget.token = ''; // Navigate back to the login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Lobby'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchActiveGames)
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Battleships'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('New game'),
              onTap: _startNewGame,
            ),
            ListTile(
              title: Text('New game (AI)'),
              onTap: _playAgainstAI,
            ),
            ListTile(
              title: Text('Show active games'),
              onTap: _fetchActiveGames,
            ),
            ListTile(
              title: Text('Log out'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: activeGames.isEmpty
          ? Center(child: Text('No active games. Start a new game!'))
          : ListView.builder(
              itemCount: activeGames.length,
              itemBuilder: (context, index) {
                final game = activeGames[index];
                String gameStatusText = 'Matchmaking';
                switch (game.status) {
                  case 0:
                    gameStatusText = 'Matchmaking';
                    break;
                  case 1:
                    gameStatusText = game.player1 + ' won';
                    break;
                  case 2:
                    gameStatusText = game.player2 + ' won';
                    break;
                  case 3:
                    gameStatusText = (game.turn == game.position)
                        ? 'Your turn'
                        : "Opponent's turn";
                    break;
                }

                String gameDetailsText =
                    'Game #${game.id}: ${game.player1} VS ${game.player2}';

                return ListTile(
                  title: Text(gameDetailsText),
                  subtitle: Text(gameStatusText),
                  onTap: () {
                    if (game.status != 0) {
                      // If the game is not in matchmaking
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            GameView(game: game, token: widget.token),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Finding a match...')),
                      );
                    }
                  },
                  onLongPress: () async {
                    try {
                      print(await (_apiService.getGameDetails(
                          game.id, widget.token)));
                      await _apiService.cancelGame(game.id, widget.token);
                      _fetchActiveGames();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete game: $e')),
                      );
                      print(e.toString());
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewGame,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
