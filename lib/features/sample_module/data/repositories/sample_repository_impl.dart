import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/features/sample_module/domain/entities/sample_item.dart';
import 'package:codequest/features/sample_module/domain/repositories/sample_repository_contract.dart';

class SampleRepositoryImpl implements SampleRepositoryContract {
  SampleRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection('sampleItems');
  }

  @override
  Future<SampleItem> create({required String title}) async {
    final doc = _collection.doc();
    final now = DateTime.now().toUtc();

    await doc.set({
      'title': title,
      'createdAt': Timestamp.fromDate(now),
    });

    return SampleItem(id: doc.id, title: title, createdAt: now);
  }

  @override
  Stream<List<SampleItem>> watchAll() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['createdAt'] as Timestamp?;
        return SampleItem(
          id: doc.id,
          title: (data['title'] as String?) ?? '',
          createdAt: timestamp?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
        );
      }).toList();
    });
  }
}
