import 'package:meta/meta.dart';

@immutable
class ReversiMove {
  final int row;
  final int col;
  final bool isPass;

  const ReversiMove({
    required this.row,
    required this.col,
    this.isPass = false,
  });

  const ReversiMove.pass() : row = -1, col = -1, isPass = true;

  factory ReversiMove.fromJson(Map<String, dynamic> json) => ReversiMove(
    row: json['row'] as int? ?? -1,
    col: json['col'] as int? ?? -1,
    isPass: json['isPass'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'row': row, 'col': col, 'isPass': isPass};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReversiMove &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col &&
          isPass == other.isPass;

  @override
  int get hashCode => Object.hash(row, col, isPass);

  @override
  String toString() =>
      isPass ? 'ReversiMove.pass()' : 'ReversiMove($row, $col)';
}
