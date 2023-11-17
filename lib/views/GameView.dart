import 'package:flutter/material.dart';
import '../models/Game.dart';
import '../services/APIservice.dart';

class GameView extends StatefulWidget {
  final Game game;
  final String token;

  GameView({Key? key, required this.game, required this.token})
      : super(key: key);

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late Game _currgame;
  final ApiService _apiService = ApiService();
  final int gridCount = 5; // Set grid count for a 5x5 board

  @override
  void initState() {
    super.initState();
    _currgame = widget.game; // Initialize the current game
  }

  void _playShot(String shot) async {
    if (!_isPlayerTurn()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("It's not your turn")));
      return;
    }

    try {
      final response =
          await _apiService.playShot(_currgame.id, shot, widget.token);
      if (response['message'] != null) {
        // Handle the server response
        bool sunkShip = response['sunk_ship'];
        bool won = response['won'];

        setState(() {
          // Update the game state based on the response
          if (sunkShip) {
            _currgame.sunk.add(shot);
          } else {
            _currgame.shots.add(shot);
          }
          if (won) {
            // Handle the win condition, maybe navigate to a win screen or show a dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Congratulations!'),
                  content: Text('You won the game!'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // Add any additional logic if needed
                      },
                    ),
                  ],
                );
              },
            );
          }
          // Switch turns
          _currgame.turn = _currgame.turn == 1 ? 2 : 1;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to play shot: $e')));
    }
  }

  bool _isPlayerTurn() {
    return _currgame.turn == _currgame.position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game #${_currgame.id}'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1, // To ensure the board is always square
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCount + 1, // Plus one for labels
              ),
              itemCount:
                  (gridCount + 1) * (gridCount + 1), // Account for the labels
              itemBuilder: (context, index) {
                // Create labels for columns and rows
                if (index % (gridCount + 1) == 0) {
                  return Center(
                      child: Text(String.fromCharCode(
                          65 + index ~/ (gridCount + 1) - 1)));
                } else if (index < (gridCount + 1)) {
                  return Center(
                      child: Text((index % (gridCount + 1)).toString()));
                } else {
                  // Calculate the actual row and column for the ships
                  int row =
                      (index ~/ (gridCount + 1)) - 1; // Adjusted for labels
                  int col = index % (gridCount + 1);
                  String cellLabel = '${String.fromCharCode(65 + row)}$col';
                  bool isShip = _currgame.ships.contains(cellLabel);
                  bool isHit = _currgame.sunk.contains(cellLabel);
                  bool isMissed = _currgame.shots.contains(cellLabel) && !isHit;

                  return Card(
                    color: isHit
                        ? Colors.red
                        : (isMissed
                            ? Colors.grey
                            : (isShip ? Colors.blueAccent : Colors.white)),
                    child: InkWell(
                      onTap: () => _playShot(cellLabel),
                      child: Center(
                        child: Text(
                          isShip
                              ? '🚢'
                              : (isHit ? '💥' : (isMissed ? '💣' : '')),
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
