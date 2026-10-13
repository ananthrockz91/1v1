import 'package:meta/meta.dart';

@immutable
class ConnectFourState {
  static const int defaultRows = 6;
  static const int defaultCols = 7;

  // Preserved static aliases for backwards compatibility
  static const int rows = defaultRows;
  static const int cols = defaultCols;

  final String player1Id;
  final String player2Id;
  final String activePlayerId;
  final List<List<String?>> grid; // [row][col], row 0 is top
  final int targetStreak; // 4 in standard/tactical, 5 in grand arena
  final List<List<int>> obstacles; // [[r, c], ...] immovable blocker pegs
  final bool
  p1PowerUsed; // Has player 1 used their once-per-match heavy breaker disc
  final bool
  p2PowerUsed; // Has player 2 used their once-per-match heavy breaker disc
  final int stateVersion;
  final bool isTerminal;
  final String? winnerId;
  final bool isDraw;
  final List<List<int>> winningCoords; // [[r, c], ...]
  final List<int> moveHistory; // List of column indices affected

  const ConnectFourState({
    required this.player1Id,
    required this.player2Id,
    required this.activePlayerId,
    required this.grid,
    this.targetStreak = 4,
    this.obstacles = const [],
    this.p1PowerUsed = false,
    this.p2PowerUsed = false,
    this.stateVersion = 0,
    this.isTerminal = false,
    this.winnerId,
    this.isDraw = false,
    this.winningCoords = const [],
    this.moveHistory = const [],
  });

  /// Dynamic dimensions based on grid structure
  int get numRows => grid.isNotEmpty ? grid.length : defaultRows;
  int get numCols => grid.isNotEmpty ? grid[0].length : defaultCols;

  factory ConnectFourState.initial({
    required String player1Id,
    required String player2Id,
    String? startingPlayerId,
    int rows = defaultRows,
    int cols = defaultCols,
    int targetStreak = 4,
    List<List<int>> obstacles = const [],
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
      targetStreak: targetStreak,
      obstacles: obstacles,
      p1PowerUsed: false,
      p2PowerUsed: false,
      stateVersion: 0,
      isTerminal: false,
      winnerId: null,
      isDraw: false,
      winningCoords: const [],
      moveHistory: const [],
    );
  }

  /// Whether a specific cell is blocked by an immovable obstacle hazard.
  bool isObstacle(int r, int c) {
    for (final obs in obstacles) {
      if (obs[0] == r && obs[1] == c) return true;
    }
    return false;
  }

  /// Returns the row where a dropped disc into [col] will land under gravity,
  /// or null if the column is full or blocked from entering.
  int? getLowestOpenRow(int col) {
    if (col < 0 || col >= numCols) return null;
    if (grid[0][col] != null || isObstacle(0, col)) return null;

    int r = 0;
    while (r + 1 < numRows &&
        grid[r + 1][col] == null &&
        !isObstacle(r + 1, col)) {
      r++;
    }
    return r;
  }

  bool isColumnFull(int col) => getLowestOpenRow(col) == null;

  /// Whether the specified player has already used their special power disc.
  bool isPowerUsed(String playerId) =>
      playerId == player1Id ? p1PowerUsed : p2PowerUsed;

  /// Whether [playerId] can pop out their piece from the bottom of [col].
  bool canPopOut(int col, String playerId) {
    if (col < 0 || col >= numCols) return false;
    final bottomRow = numRows - 1;
    if (isObstacle(bottomRow, col)) return false;
    return grid[bottomRow][col] == playerId;
  }

  /// Whether [playerId] can use their heavy breaker disc in [col].
  bool canPowerDrop(int col, String playerId) {
    if (isPowerUsed(playerId)) return false;
    if (col < 0 || col >= numCols) return false;
    if (isObstacle(0, col)) return false;
    // Can drop if column has open space or top piece belongs to opponent
    return !isColumnFull(col) ||
        (grid[0][col] != null && grid[0][col] != playerId);
  }

  int get totalPiecesPlaced {
    int count = 0;
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
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
    int? targetStreak,
    List<List<int>>? obstacles,
    bool? p1PowerUsed,
    bool? p2PowerUsed,
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
      targetStreak: targetStreak ?? this.targetStreak,
      obstacles: obstacles ?? this.obstacles,
      p1PowerUsed: p1PowerUsed ?? this.p1PowerUsed,
      p2PowerUsed: p2PowerUsed ?? this.p2PowerUsed,
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
      'targetStreak': targetStreak,
      'obstacles': obstacles,
      'p1PowerUsed': p1PowerUsed,
      'p2PowerUsed': p2PowerUsed,
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

    final rawObstacles = json['obstacles'] as List<dynamic>? ?? [];
    final parsedObstacles = rawObstacles.map((item) {
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
      targetStreak: json['targetStreak'] as int? ?? 4,
      obstacles: parsedObstacles,
      p1PowerUsed: json['p1PowerUsed'] as bool? ?? false,
      p2PowerUsed: json['p2PowerUsed'] as bool? ?? false,
      stateVersion: json['stateVersion'] as int? ?? 0,
      isTerminal: json['isTerminal'] as bool? ?? false,
      winnerId: json['winnerId'] as String?,
      isDraw: json['isDraw'] as bool? ?? false,
      winningCoords: parsedWinning,
      moveHistory: parsedMoves,
    );
  }
}
