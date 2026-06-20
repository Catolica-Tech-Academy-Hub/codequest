import 'dart:convert';

import 'package:codequest/features/levels/data/sources/level_data_source.dart';
import 'package:codequest/features/levels/domain/errors/level_failure.dart';
import 'package:flutter/services.dart' show rootBundle;

class JsonAssetLevelDataSource implements LevelDataSource {
  JsonAssetLevelDataSource({
    this.assetPath = 'assets/mocks/levels.json',
  });

  final String assetPath;

  Map<String, dynamic>? _cache;

  @override
  Future<Map<String, dynamic>> fetchRaw(String id) async {
    final all = await _loadAll();
    final raw = all[id];
    if (raw is! Map<String, dynamic>) {
      throw LevelFailure.notFound(id);
    }
    return raw;
  }

  Future<Map<String, dynamic>> _loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final content = await rootBundle.loadString(assetPath);
    final decoded = json.decode(content);
    if (decoded is! Map<String, dynamic>) {
      throw LevelFailure.malformedLevel(
        'Raiz de "$assetPath" deve ser um objeto JSON.',
      );
    }
    _cache = decoded;
    return decoded;
  }
}
