import 'dart:convert';

import 'package:codequest/features/activities/data/sources/activity_data_source.dart';
import 'package:codequest/features/activities/domain/errors/activity_failure.dart';
import 'package:flutter/services.dart' show rootBundle;

class JsonAssetActivityDataSource implements ActivityDataSource {
  JsonAssetActivityDataSource({
    this.assetPath = 'assets/mocks/activities.json',
  });

  final String assetPath;

  Map<String, dynamic>? _cache;

  @override
  Future<Map<String, dynamic>> fetchRaw(String id) async {
    final all = await _loadAll();
    final raw = all[id];
    if (raw is! Map<String, dynamic>) {
      throw ActivityFailure.notFound(id);
    }
    return raw;
  }

  Future<Map<String, dynamic>> _loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final content = await rootBundle.loadString(assetPath);
    final decoded = json.decode(content);
    if (decoded is! Map<String, dynamic>) {
      throw ActivityFailure.malformedActivity(
        'Raiz de "$assetPath" deve ser um objeto JSON.',
      );
    }
    _cache = decoded;
    return decoded;
  }
}
