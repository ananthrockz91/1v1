import 'package:meta/meta.dart';

@immutable
class ConnectFourMove {
  final int column;

  const ConnectFourMove({required this.column});

  Map<String, dynamic> toJson() => {'column': column};

  factory ConnectFourMove.fromJson(Map<String, dynamic> json) =>
      ConnectFourMove(column: json['column'] as int);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectFourMove &&
          runtimeType == other.runtimeType &&
          column == other.column;

  @override
  int get hashCode => column.hashCode;

  @override
  String toString() => 'ConnectFourMove(col: $column)';
}
