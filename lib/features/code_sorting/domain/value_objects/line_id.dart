import 'package:equatable/equatable.dart';

class LineId extends Equatable {
  const LineId(this.value);
  final String value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'LineId($value)';
}
