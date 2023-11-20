import 'package:flutter/material.dart';
import '../models/Game.dart';
import '../views/GameView.dart';
import '../services/APIservice.dart';
import '../services/SessionManager.dart';

class GameShips extends StatefulWidget {
  final String? aiType;

  GameShips({Key? key, required this.aiType}) : super(key: key);

  @override
  _GameShipsState createState() => _GameShipsState();
}

class _GameShipsState extends State<GameShips> {
  List<String> selectedShips = [];
  final ApiService _apiService = ApiService();
  final int gridCount = 5; // Number of playable grid cells
  final double rightPadding = 16.0; // Right padding for the grid

  void _submitShips({bool aiGame = false}) async {
    try {
      // Log selected ships for debugging
      print('Submitting ships: $selectedShips');

      String token = await SessionManager.getSessionToken();

      final response = await _apiService.startGame(selectedShips, token, ai: widget.aiType);
      
      if (aiGame || response['matched']) {
        // If it's an AI game or the game is immediately matched, navigate to GameView
        Game game = Game.fromJson(response);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => GameView(game: game, token: token),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Ships'),
      ),
      body: Padding(
        padding: EdgeInsets.only(right: rightPadding),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var maxWidth = constraints.maxWidth;
            var maxHeight = constraints.maxHeight;
            var gridSize = maxWidth < maxHeight ? maxWidth : maxHeight;

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: gridSize,
                        height: gridSize,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            childAspectRatio: 1,
                          ),
                          itemCount: 36,
                          itemBuilder: (context, index) {
                            int row = index ~/ 6;
                            int col = index % 6;

                            if (row == 0 || col == 0) {
                              return Center(
                                child: Text(row == 0 && col > 0
                                    ? col.toString()
                                    : (col == 0 && row > 0
                                        ? String.fromCharCode(65 + row - 1)
                                        : '')),
                              );
                            } else {
                              String cellLabel =
                                  '${String.fromCharCode(65 + row - 1)}$col';
                              bool isSelected =
                                  selectedShips.contains(cellLabel);

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
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: selectedShips.length == 5 ? _submitShips : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Submit'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
