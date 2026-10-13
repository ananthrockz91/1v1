import 'package:meta/meta.dart';
import 'reversi_move.dart';

@immutable
class ReversiState {
  static const int defaultSize = 8;

  final int boardSize;
  final List<int> grid; // 0 = empty, 1 = player1, 2 = player2
  final String player1Id;
  final String player2Id;
  final String activePlayerId;
  final int player1Score;
  final int player2Score;
  final int stateVersion;
  final bool isTerminal;
  final String? winnerId;
  final bool isDraw;
  final ReversiMove? lastMove;
  final List<List<int>> lastFlipped; // List of [r, c] for flip animations
  final int consecutivePasses;

  const ReversiState({
    this.boardSize = defaultSize,
    required this.grid,
    required this.player1Id,
    required this.player2Id,
    required this.activePlayerId,
    this.player1Score = 2,
    this.player2Score = 2,
    this.stateVersion = 0,
    this.isTerminal = false,
    this.winnerId,
    this.isDraw = false,
    this.lastMove,
    this.lastFlipped = const [],
    this.consecutivePasses = 0,
  });

  /// Standard initial 8x8 Othello layout with 4 center disks
  factory ReversiState.initial({
    required String player1Id,
    required String player2Id,
    int boardSize = defaultSize,
  }) {
    final grid = List<int>.filled(boardSize * boardSize, 0);
    final mid = boardSize ~/ 2;
    // Standard setup:
    // (mid - 1, mid - 1) = 2 (Light / P2)
    // (mid - 1, mid)     = 1 (Dark / P1)
    // (mid, mid - 1)     = 1 (Dark / P1)
    // (mid, mid)         = 2 (Light / P2)
    grid[(mid - 1) * boardSize + (mid - 1)] = 2;
    grid[(mid - 1) * boardSize + mid] = 1;
    grid[mid * boardSize + (mid - 1)] = 1;
    grid[mid * boardSize + mid] = 2;

    return ReversiState(
      boardSize: boardSize,
      grid: List.unmodifiable(grid),
      player1Id: player1Id,
      player2Id: player2Id,
      activePlayerId: player1Id,
      player1Score: 2,
      player2Score: 2,
      stateVersion: 0,
      isTerminal: false,
      consecutivePasses: 0,
    );
  }

  int cellAt(int r, int c) {
    if (r < 0 || r >= boardSize || c < 0 || c >= boardSize) return -1;
    return grid[r * boardSize + c];
  }

  bool isCellEmpty(int r, int c) => cellAt(r, c) == 0;

  int getPlayerNumber(String playerId) {
    if (playerId == player1Id) return 1;
    if (playerId == player2Id) return 2;
    return 0;
  }

  String getPlayerIdFromNumber(int num) {
    if (num == 1) return player1Id;
    if (num == 2) return player2Id;
    return '';
  }

  int get opponentNumber {
    final curr = getPlayerNumber(activePlayerId);
    return curr == 1 ? 2 : 1;
  }

  String get opponentId {
    return activePlayerId == player1Id ? player2Id : player1Id;
  }

  bool isParticipant(String id) => id == player1Id || id == player2Id;

  ReversiState copyWith({
    int? boardSize,
    List<int>? grid,
    String? player1Id,
    String? player2Id,
    String? activePlayerId,
    int? player1Score,
    int? player2Score,
    int? stateVersion,
    bool? isTerminal,
    String? winnerId,
    bool? isDraw,
    ReversiMove? lastMove,
    List<List<int>>? lastFlipped,
    int? consecutivePasses,
  }) {
    return ReversiState(
      boardSize: boardSize ?? this.boardSize,
      grid: grid ?? this.grid,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      activePlayerId: activePlayerId ?? this.activePlayerId,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      stateVersion: stateVersion ?? this.stateVersion,
      isTerminal: isTerminal ?? this.isTerminal,
      winnerId: winnerId ?? this.winnerId,
      isDraw: isDraw ?? this.isDraw,
      lastMove: lastMove ?? this.lastMove,
      lastFlipped: lastFlipped ?? this.lastFlipped,
      consecutivePasses: consecutivePasses ?? this.consecutivePasses,
    );
  }

  factory ReversiState.fromJson(Map<String, dynamic> json) {
    final rawGrid = json['grid'] as List<dynamic>? ?? [];
    final grid = rawGrid.map((e) => (e as num).toInt()).toList();

    final rawFlipped = json['lastFlipped'] as List<dynamic>? ?? [];
    final flipped = rawFlipped
        .map(
          (e) => (e as List<dynamic>).map((i) => (i as num).toInt()).toList(),
        )
        .toList();

    return ReversiState(
      boardSize: json['boardSize'] as int? ?? defaultSize,
      grid: List.unmodifiable(grid),
      player1Id: json['player1Id'] as String? ?? 'p1',
      player2Id: json['player2Id'] as String? ?? 'p2',
      activePlayerId: json['activePlayerId'] as String? ?? 'p1',
      player1Score: json['player1Score'] as int? ?? 2,
      player2Score: json['player2Score'] as int? ?? 2,
      stateVersion: json['stateVersion'] as int? ?? 0,
      isTerminal: json['isTerminal'] as bool? ?? false,
      winnerId: json['winnerId'] as String?,
      isDraw: json['isDraw'] as bool? ?? false,
      lastMove: json['lastMove'] != null
          ? ReversiMove.fromJson(json['lastMove'] as Map<String, dynamic>)
          : null,
      lastFlipped: List.unmodifiable(flipped),
      consecutivePasses: json['consecutivePasses'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'boardSize': boardSize,
    'grid': grid,
    'player1Id': player1Id,
    'player2Id': player2Id,
    'activePlayerId': activePlayerId,
    'player1Score': player1Score,
    'player2Score': player2Score,
    'stateVersion': stateVersion,
    'isTerminal': isTerminal,
    'winnerId': winnerId,
    'isDraw': isDraw,
    'lastMove': lastMove?.toJson(),
    'lastFlipped': lastFlipped,
    'consecutivePasses': consecutivePasses,
  };
}
