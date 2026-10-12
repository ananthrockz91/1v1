import 'package:meta/meta.dart';

@immutable
class ConnectFourState {
  static const int rows = 6;
  static const int cols = 7;

  final String player1Id;
  final String player2Id;
  final String activePlayerId;
  final List<List<String?>> grid; // [row][col], row 0 is top, row 5 is bottom
  final int stateVersion;
  final bool isTerminal;
  final String? winnerId;
  final bool isDraw;
  final List<List<int>> winningCoords; // [[r, c], [r, c], [r, c], [r, c]]
  final List<int> moveHistory; // List of column indices dropped

  const ConnectFourState({
    required this.player1Id,
    required this.player2Id,
    required this.activePlayerId,
    required this.grid,
    this.stateVersion = 0,
    this.isTerminal = false,
    this.winnerId,
    this.isDraw = false,
    this.winningCoords = const [],
    this.moveHistory = const [],
  });

  factory ConnectFourState.initial({
    required String player1Id,
    required String player2Id,
    String? startingPlayerId,
  }) {
    return ConnectFourState(
      player1Id: player1Id,
      player2Id: player2Id,
      activePlayerId: startingPlayerId ?? player1Id,
      grid: List.generate(
        rows,
        (_) => List<String?>.filled(cols, null, growable: false),
        growable: false,
      ),
      stateVersion: 0,
      isTerminal: false,
      winnerId: null,
      isDraw: false,
      winningCoords: const [],
      moveHistory: const [],
    );
  }

  /// Returns the lowest unoccupied row in the given column, or null if full.
  int? getLowestOpenRow(int col) {
    if (col < 0 || col >= cols) return null;
    for (int r = rows - 1; r >= 0; r--) {
      if (grid[r][col] == null) return r;
    }
    return null;
  }

  bool isColumnFull(int col) => getLowestOpenRow(col) == null;

  int get totalPiecesPlaced {
    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] != null) count++;
      }
    }
    return count;
  }

  ConnectFourState copyWith({
    String? player1Id,
    String? player2Id,
    String? activePlayerId,
    List<List<String?>>? grid,
    int? stateVersion,
    bool? isTerminal,
    String? winnerId,
    bool? isDraw,
    List<List<int>>? winningCoords,
    List<int>? moveHistory,
  }) {
    return ConnectFourState(
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      activePlayerId: activePlayerId ?? this.activePlayerId,
      grid: grid ?? this.grid,
      stateVersion: stateVersion ?? this.stateVersion,
      isTerminal: isTerminal ?? this.isTerminal,
      winnerId: winnerId ?? this.winnerId,
      isDraw: isDraw ?? this.isDraw,
      winningCoords: winningCoords ?? this.winningCoords,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player1Id': player1Id,
      'player2Id': player2Id,
      'activePlayerId': activePlayerId,
      'grid': grid.map((row) => row.toList()).toList(),
      'stateVersion': stateVersion,
      'isTerminal': isTerminal,
      'winnerId': winnerId,
      'isDraw': isDraw,
      'winningCoords': winningCoords,
      'moveHistory': moveHistory,
    };
  }

  factory ConnectFourState.fromJson(Map<String, dynamic> json) {
    final rawGrid = json['grid'] as List<dynamic>;
    final parsedGrid = rawGrid.map((row) {
      return (row as List<dynamic>).map((cell) => cell as String?).toList();
    }).toList();

    final rawWinning = json['winningCoords'] as List<dynamic>? ?? [];
    final parsedWinning = rawWinning.map((item) {
      final list = item as List<dynamic>;
      return [list[0] as int, list[1] as int];
    }).toList();

    final rawMoves = json['moveHistory'] as List<dynamic>? ?? [];
    final parsedMoves = rawMoves.map((m) => m as int).toList();

    return ConnectFourState(
      player1Id: json['player1Id'] as String,
      player2Id: json['player2Id'] as String? ?? '',
      activePlayerId: json['activePlayerId'] as String,
      grid: parsedGrid,
      stateVersion: json['stateVersion'] as int? ?? 0,
      isTerminal: json['isTerminal'] as bool? ?? false,
      winnerId: json['winnerId'] as String?,
      isDraw: json['isDraw'] as bool? ?? false,
      winningCoords: parsedWinning,
      moveHistory: parsedMoves,
    );
  }
}
