import 'package:equatable/equatable.dart';

class PendingPromotion extends Equatable {
  const PendingPromotion({
    required this.id,
    required this.userId,
    required this.oldTier,
    required this.newTier,
    required this.createdAt,
    this.seen = false,
  });

  final String id;
  final String userId;
  final String oldTier;
  final String newTier;
  final DateTime createdAt;
  final bool seen;

  @override
  List<Object?> get props => [id, userId, oldTier, newTier, createdAt, seen];
}
