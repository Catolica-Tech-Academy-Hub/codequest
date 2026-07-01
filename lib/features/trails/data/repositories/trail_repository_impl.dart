import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/features/trails/data/dtos/user_trail_progress_dto.dart';
import 'package:codequest/features/trails/data/sources/trail_data_source.dart';
import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:codequest/features/trails/domain/entities/user_trail_progress.dart';
import 'package:codequest/features/trails/domain/errors/trail_failure.dart';
import 'package:codequest/features/trails/domain/repositories/trail_repository_contract.dart';

class TrailRepositoryImpl implements TrailRepositoryContract {
  TrailRepositoryImpl(this._dataSource);

  final TrailDataSource _dataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Trail>> listAll() => _dataSource.fetchAll();

  @override
  Future<Trail> getById(String id) async {
    final trails = await _dataSource.fetchAll();
    for (final trail in trails) {
      if (trail.id == id) return trail;
    }
    throw TrailFailure.notFound(id);
  }

  @override
  Future<UserTrailProgress?> getUserProgress({
    required String userId,
    required String trailId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trailProgress')
          .doc(trailId)
          .get();

      if (!doc.exists) return null;
      return UserTrailProgressDto.fromFirestore(doc.data()!).toDomain();
    } catch (e) {
      throw TrailFailure.unexpected('Erro ao buscar progresso: $e');
    }
  }

  @override
  Future<void> updateUserProgress(UserTrailProgress progress) async {
    try {
      final dto = UserTrailProgressDto.fromDomain(progress);
      await _firestore
          .collection('users')
          .doc(progress.userId)
          .collection('trailProgress')
          .doc(progress.trailId)
          .set(dto.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw TrailFailure.unexpected('Erro ao atualizar progresso: $e');
    }
  }
}
