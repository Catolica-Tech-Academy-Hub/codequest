import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/xp_history_entry.dart';

/// Modelo de dados para serialização/desserialização do [XpHistoryEntry] no Firestore.
class XpHistoryEntryModel extends XpHistoryEntry {
  const XpHistoryEntryModel({
    required super.id,
    required super.userId,
    required super.xpAmount,
    required super.source,
    required super.sourceId,
    required super.earnedAt,
  });

  factory XpHistoryEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return XpHistoryEntryModel(
      id: doc.id,
      userId: data['userId'] as String,
      xpAmount: data['xpAmount'] as int,
      source: XpSource.values.firstWhere(
        (e) => e.name == data['source'],
        orElse: () => XpSource.lessonCompleted,
      ),
      sourceId: data['sourceId'] as String,
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'xpAmount': xpAmount,
        'source': source.name,
        'sourceId': sourceId,
        'earnedAt': Timestamp.fromDate(earnedAt),
      };

  factory XpHistoryEntryModel.fromDomain(XpHistoryEntry entry) {
    return XpHistoryEntryModel(
      id: entry.id,
      userId: entry.userId,
      xpAmount: entry.xpAmount,
      source: entry.source,
      sourceId: entry.sourceId,
      earnedAt: entry.earnedAt,
    );
  }
}
