import 'package:flutter/material.dart';
import '../models/Game.dart';
import '../services/APIservice.dart';
import 'dart:math';

class GameView extends StatefulWidget {
  final Game game;
  final String token;

  GameView({Key? key, required this.game, required this.token})
      : super(key: key);

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with WidgetsBindingObserver {
  late Game _currgame;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currgame = widget.game;
    _fetchGameDetails();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchGameDetails();
    }
  }

  void _fetchGameDetails() async {
    try {
      final response =
          await _apiService.getGameDetails(_currgame.id, widget.token);
      setState(() {
        _currgame = Game.fromJson(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch game details: $e')));
    }
  }

  bool _isGameEnded() {
    return _currgame.status == 1 || _currgame.status == 2;
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Game #${_currgame.id}';
    if (_isGameEnded()) {
      String winner =
          _currgame.status == 1 ? _currgame.player1 : _currgame.player2;
      title = '$winner won!';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildGameBoard(),
    );
  }

  Widget _buildGameBoard() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var gridSize = min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: gridSize,
              height: gridSize,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                ),
                itemCount: 36,
                itemBuilder: (context, index) {
                  int row = index ~/ 6;
                  int col = index % 6;

                  if (row == 0 || col == 0) {
                    return _buildLabelCell(row, col);
                  } else {
                    return _buildGameCell(row, col);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabelCell(int row, int col) {
    return Center(
      child: Text(row == 0 && col > 0
          ? col.toString()
          : (col == 0 && row > 0 ? String.fromCharCode(65 + row - 1) : '')),
    );
  }

  Widget _buildGameCell(int row, int col) {
    String cellLabel = '${String.fromCharCode(65 + row - 1)}$col';
    bool isMyShip = _currgame.ships.contains(cellLabel);
    bool isHit = _currgame.sunk.contains(cellLabel);
    bool isMissed = _currgame.shots.contains(cellLabel) && !isHit;
    bool isWrecked = _currgame.wrecks.contains(cellLabel);

    String emoji = '';
    if (isMyShip && isHit) {
      emoji = '💥🚢'; // Hit on own ship
    } else if (isWrecked) {
      emoji = '🫧'; // Wrecked ship
    } else if (isMyShip && isMissed) {
      emoji = '🚢💣'; // Missed shot on own ship
    } else if (isMyShip) {
      emoji = '🚢'; // Own ship
    } else if (isHit) {
      emoji = '💥'; // Hit on opponent's ship
    } else if (isMissed) {
      emoji = '💣'; // Missed shot
    }

    return Card(
      color: _getCellColor(isHit, isMissed, isMyShip, isWrecked),
      child: InkWell(
        onTap: !_isGameEnded() && _isPlayerTurn() && !isHit && !isMissed
            ? () => _playShot(cellLabel)
            : null,
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
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
        bool sunkShip = response['sunk_ship'];
        bool won = response['won'];

        setState(() {
          if (sunkShip) {
            _currgame.sunk.add(shot);
          } else {
            _currgame.shots.add(shot);
          }
          if (won) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Congratulations!'),
                  content: Text('You won the game!'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          }
          _currgame.turn = _currgame.turn == 1 ? 2 : 1;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to play shot: $e')));
    }
    _fetchGameDetails();
  }

  Color _getCellColor(bool isHit, bool isMissed, bool isShip, bool isWrecked) {
    if (isHit && isShip) {
      return Colors.red[300]!;
    } else if (isHit) {
      return Colors.red;
    } else if (isMissed) {
      return Colors.blue[200]!;
    } else if (isShip) {
      return Colors.blueAccent;
    } else if (isWrecked) {
      return Colors.grey[300]!;
    } else {
      return Colors.white;
    }
  }

  bool _isPlayerTurn() {
    return _currgame.position == _currgame.turn;
  }
}
