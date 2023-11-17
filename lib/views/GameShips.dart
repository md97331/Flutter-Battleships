import 'package:flutter/material.dart';
import '../models/Game.dart';
import '../views/GameView.dart';
import '../services/APIservice.dart';

class GameShips extends StatefulWidget {
  final String token;

  GameShips({Key? key, required this.token}) : super(key: key);

  @override
  _GameShipsState createState() => _GameShipsState();
}

class _GameShipsState extends State<GameShips> {
  List<String> selectedShips = [];
  final ApiService _apiService = ApiService();
  final int gridCount = 5; // Number of playable grid cells
  final double rightPadding = 16.0; // Right padding for the grid

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Ships'),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            right: rightPadding), // Add right padding to the whole body
        child: Column(
          children: <Widget>[
            Expanded(
              child: GridView.builder(
                itemCount:
                    (gridCount + 1) * (gridCount + 1), // Adjusted for labels
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount + 1,
                ),
                itemBuilder: (context, index) {
                  // Determine the row and column number
                  int row = index ~/ (gridCount + 1);
                  int col = index % (gridCount + 1);

                  if (row == 0 && col > 0) {
                    // Top labels (1-5)
                    return Center(child: Text(col.toString()));
                  } else if (col == 0 && row > 0) {
                    // Side labels (A-E)
                    return Center(child: Text(String.fromCharCode(64 + row)));
                  } else if (row > 0 && col > 0) {
                    // Playable cells
                    final String cellLabel =
                        String.fromCharCode(64 + row) + col.toString();
                    final bool isSelected = selectedShips.contains(cellLabel);
                    return Card(
                      color: isSelected ? Colors.blue : Colors.white,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedShips.remove(cellLabel);
                            } else if (selectedShips.length < 5) {
                              selectedShips.add(cellLabel);
                            }
                          });
                        },
                      ),
                    );
                  } else {
                    // This is the top-left corner, which should be empty
                    return Container();
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: selectedShips.length == 5 ? _submitShips : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                      double.infinity, 50), // Ensures the button is full width
                ),
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitShips({bool aiGame = false}) async {
    try {
      // Log selected ships for debugging
      print('Submitting ships: $selectedShips');

      // Call API to start the game with the selected ships
      final response = await _apiService.startGame(selectedShips, widget.token,
          ai: aiGame ? 'random' : null);

      if (aiGame || response['matched']) {
        // If it's an AI game or the game is immediately matched, navigate to GameView
        Game game = Game.fromJson(response);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => GameView(game: game, token: widget.token),
        ));
      } else {
        // If the game is not matched, pop the current screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle any errors here
      print('Error starting game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start game: $e')),
      );
    }
  }
}
