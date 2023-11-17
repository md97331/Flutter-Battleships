class Game {
  final int id;
  final String player1;
  final String player2;
  final int status;
  final int position;
  int turn;
  final List<String> ships;
  final List<String> wrecks;
  final List<String> shots;
  final List<String> sunk;

  Game({
    required this.id,
    required this.player1,
    required this.player2,
    required this.status,
    required this.position,
    required this.turn,
    required this.ships,
    required this.wrecks,
    required this.shots,
    required this.sunk,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
  return Game(
    id: json['id'] as int? ?? 0, // Provide a default value if null
    player1: json['player1'] as String? ?? 'N/A', // Provide a default value if null
    player2: json['player2'] as String? ?? 'N/A', // Provide a default value if null
    status: json['status'] as int? ?? 0, // Provide a default value if null
    position: json['position'] as int? ?? 0, // Provide a default value if null
    turn: json['turn'] as int? ?? 0, // Provide a default value if null
    ships: (json['ships'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    wrecks: (json['wrecks'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    shots: (json['shots'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    sunk: (json['sunk'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  );
}

}
