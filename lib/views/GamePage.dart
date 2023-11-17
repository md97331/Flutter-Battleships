import 'package:flutter/material.dart';
import '../models/Game.dart';
import '../services/APIservice.dart';
import '../views/GameShips.dart';
import 'GameView.dart';
import '../views/CompletedGamePage.dart';

class GamePage extends StatefulWidget {
  String token;
  String username;

  GamePage({Key? key, required this.token, required this.username})
      : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final ApiService _apiService = ApiService();
  List<Game> activeGames = [];

  @override
  void initState() {
    super.initState();
    _fetchActiveGames();
  }

  void _fetchActiveGames() async {
    try {
      final response = await _apiService.getGames(widget.token);
      if (response['games'] != null) {
        var gamesList = List<Map<String, dynamic>>.from(response['games']);
        var filteredGames = gamesList.where((gameMap) {
          var game = Game.fromJson(gameMap);
          return game.status == 0 || // Matchmaking
              game.status == 3 || // Active game
              (game.status == 1 &&
                  game.player1 ==
                      widget.token) || // Player1 won and it's the user
              (game.status == 2 &&
                  game.player2 ==
                      widget.token); // Player2 won and it's the user
        }).toList();

        setState(() {
          activeGames =
              filteredGames.map((gameMap) => Game.fromJson(gameMap)).toList();
        });
      } else {
        setState(() => activeGames = []);
      }
    } catch (e) {
      print("Error fetching games: $e");
    }
  }

  void _playAgainstAI() async {
    try {
      final response =
          await _apiService.startGame([], widget.token, ai: 'random');
      Game game = Game.fromJson(response);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameView(game: game, token: widget.token),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start AI game: $e')),
      );
    }
  }

  void _startNewGame() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameShips(token: widget.token),
      ),
    );
    _fetchActiveGames();
  }

  void _logout() async {
    widget.token = '';
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Lobby'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchActiveGames),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Battleships',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0), // Spacing
                  const Text(
                    'Hi,',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  Text(
                    '${widget.username}!', // Use the username passed to the widget
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              title: Text('Show completed games'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CompletedGamesPage(token: widget.token),
                  ),
                );
              },
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
                String gameStatusText = _getGameStatusText(game);
                String gameDetailsText =
                    'Game #${game.id}: ${game.player1} VS ${game.player2}';

                return ListTile(
                  title: Text(gameDetailsText),
                  subtitle: Text(gameStatusText),
                  onTap: () => _onGameTap(game),
                  onLongPress: () => _onGameLongPress(game),
                );
              },
            ),
    );
  }

  String _getGameStatusText(Game game) {
    switch (game.status) {
      case 0:
        return 'Matchmaking';
      case 1:
        return game.player1 + ' won';
      case 2:
        return game.player2 + ' won';
      case 3:
        return (game.turn == game.position) ? 'Your turn' : "Opponent's turn";
      default:
        return 'Status Unknown';
    }
  }

  void _onGameTap(Game game) {
    if (game.status != 0) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => GameView(game: game, token: widget.token),
            ),
          )
          .then((value) => _fetchActiveGames());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Finding a match...')),
      );
    }
  }

  void _onGameLongPress(Game game) async {
    try {
      await _apiService.cancelGame(game.id, widget.token);
      _fetchActiveGames();
    } catch (e) {
      if (game.status == 1 || game.status == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The game is already over!')),
        );
      }
    }
  }
}
