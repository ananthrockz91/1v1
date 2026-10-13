import 'package:meta/meta.dart';

enum ConnectFourAction {
  /// Standard gravity drop of a disc into the column.
  drop,

  /// Eject/pop-out player's own disc from the bottom row, dropping discs above.
  popOut,

  /// Once-per-match Heavy Anvil disc that crushes opponent discs.
  powerDrop,
}

@immutable
class ConnectFourMove {
  final int column;
  final ConnectFourAction action;

  const ConnectFourMove({
    required this.column,
    this.action = ConnectFourAction.drop,
  });

  const ConnectFourMove.drop(int column)
    : this(column: column, action: ConnectFourAction.drop);

  const ConnectFourMove.popOut(int column)
    : this(column: column, action: ConnectFourAction.popOut);

  const ConnectFourMove.powerDrop(int column)
    : this(column: column, action: ConnectFourAction.powerDrop);

  Map<String, dynamic> toJson() => {'column': column, 'action': action.name};

  factory ConnectFourMove.fromJson(Map<String, dynamic> json) =>
      ConnectFourMove(
        column: json['column'] as int,
        action: json['action'] != null
            ? ConnectFourAction.values.byName(json['action'] as String)
            : ConnectFourAction.drop,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectFourMove &&
          runtimeType == other.runtimeType &&
          column == other.column &&
          action == other.action;

  @override
  int get hashCode => Object.hash(column, action);

  @override
  String toString() => 'ConnectFourMove(col: $column, action: ${action.name})';
}
