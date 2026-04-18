//FlutterProyect/lib/features/cursos/data/dataSources/local_curso_cache_source.dart
import 'dart:convert';
import 'package:loggy/loggy.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';
import '../../domain/entities/curso_curso.dart';
import '../../domain/entities/curso_matriculado.dart';

class LocalCursoCacheSource {
  final ILocalPreferences prefs;

  // Llaves separadas para no mezclar datos
  static const String _cacheKeyProfe = 'cache_cursos_profe';
  static const String _cacheTimestampKeyProfe = 'cache_cursos_profe_timestamp';

  static const String _cacheKeyEstudiante = 'cache_cursos_estudiante';
  static const String _cacheTimestampKeyEstudiante =
      'cache_cursos_estudiante_timestamp';

  static const int _cacheTTLMinutes = 10;

  LocalCursoCacheSource(this.prefs);

  // ==========================================
  // CACHÉ DEL PROFESOR
  // ==========================================
  Future<bool> isCacheValidProfe() async {
    try {
      final timestampStr = await prefs.getString(_cacheTimestampKeyProfe);
      if (timestampStr == null) return false;
      final difference = DateTime.now()
          .difference(DateTime.parse(timestampStr))
          .inMinutes;
      final isValid = difference < _cacheTTLMinutes;
      logInfo(
        '⏱️ [PROFESOR] Cache age: ${difference}m / TTL: ${_cacheTTLMinutes}m → ${isValid ? "VALID" : "EXPIRED"}',
      );
      return isValid;
    } catch (e) {
      return false;
    }
  }

  Future<void> cacheCursosProfeData(List<CursoCurso> cursos) async {
    final jsonList = cursos.map((c) => c.toJson()).toList();
    await prefs.setString(_cacheKeyProfe, jsonEncode(jsonList));
    await prefs.setString(
      _cacheTimestampKeyProfe,
      DateTime.now().toIso8601String(),
    );
    logInfo('💾 [PROFE] Cursos cache saved: ${cursos.length}');
  }

  Future<List<CursoCurso>> getCachedCursosProfeData() async {
    final encoded = await prefs.getString(_cacheKeyProfe);
    if (encoded == null || encoded.isEmpty) throw Exception('No cache');
    final decoded = jsonDecode(encoded) as List;
    logInfo('📦 [PROFE] Cache loaded: ${decoded.length} cursos');
    return decoded
        .map((x) => CursoCurso.fromJson(x as Map<String, dynamic>))
        .toList();
  }

  // ==========================================
  // CACHÉ DEL ESTUDIANTE
  // ==========================================
  Future<bool> isCacheValidEstudiante() async {
    try {
      final timestampStr = await prefs.getString(_cacheTimestampKeyEstudiante);
      if (timestampStr == null) return false;
      final difference = DateTime.now()
          .difference(DateTime.parse(timestampStr))
          .inMinutes;
      final isValid = difference < _cacheTTLMinutes;
      logInfo(
        '⏱️ [ESTUDIANTE] Cache age: ${difference}m / TTL: ${_cacheTTLMinutes}m → ${isValid ? "VALID" : "EXPIRED"}',
      );
      return isValid;
    } catch (e) {
      return false;
    }
  }

  Future<void> cacheCursosEstudianteData(List<CursoMatriculado> cursos) async {
    final jsonList = cursos.map((c) => c.toJson()).toList();
    await prefs.setString(_cacheKeyEstudiante, jsonEncode(jsonList));
    await prefs.setString(
      _cacheTimestampKeyEstudiante,
      DateTime.now().toIso8601String(),
    );
    logInfo('💾 [ESTUDIANTE] Cursos cache saved: ${cursos.length}');
  }

  Future<List<CursoMatriculado>> getCachedCursosEstudianteData() async {
    final encoded = await prefs.getString(_cacheKeyEstudiante);
    if (encoded == null || encoded.isEmpty) throw Exception('No cache');
    final decoded = jsonDecode(encoded) as List;
    logInfo('📦 [ESTUDIANTE] Cache loaded: ${decoded.length} cursos');
    return decoded
        .map((x) => CursoMatriculado.fromJson(x as Map<String, dynamic>))
        .toList();
  }

  // LIMPIAR CACHE GENERAL
  Future<void> clearCache() async {
    await prefs.remove(_cacheKeyProfe);
    await prefs.remove(_cacheTimestampKeyProfe);
    await prefs.remove(_cacheKeyEstudiante);
    await prefs.remove(_cacheTimestampKeyEstudiante);
    logInfo('🗑️ All Cursos cache invalidated');
  }
}
