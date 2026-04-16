import '../../domain/entities/curso_curso.dart';
import '../../domain/repositories/i_curso_repository.dart';
import '../dataSources/i_curso_source.dart';
import '../dataSources/local_curso_cache_source.dart';
import '../../domain/entities/curso_matriculado.dart';

class CursoRepository implements ICursoRepository {
  final ICursoSource cursoSource;
  final LocalCursoCacheSource cacheSource;

  CursoRepository(this.cursoSource, this.cacheSource);

  @override
  Future<void> createCurso(String idCurso, String nom) async {
    await cursoSource.createCurso(idCurso, nom);
    await cacheSource.clearCache();
  }

  @override
  Future<void> updateCurso(CursoCurso curso, String NomNuevo) async {
    await cursoSource.updateCurso(curso, NomNuevo);
    await cacheSource.clearCache();
  }

  @override
  Future<void> deleteCurso(String idCurso) async {
    await cursoSource.deleteCurso(idCurso);
    await cacheSource.clearCache();
  }

  @override
  Future<List<CursoCurso>> getCursosByProfe() async {
    // 1. Verificamos caché del Profe
    if (await cacheSource.isCacheValidProfe()) {
      try {
        return await cacheSource.getCachedCursosProfeData();
      } catch (e) {}
    }
    // 2. Traemos de la API y guardamos
    final remoteCursos = await cursoSource.getCursosByProfe();
    await cacheSource.cacheCursosProfeData(remoteCursos);
    return remoteCursos;
  }

  // 🚀 MAGIA DEL CACHÉ PARA EL ESTUDIANTE
  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(
    String emailEstudiante,
  ) async {
    // 1. Verificamos caché del Estudiante
    if (await cacheSource.isCacheValidEstudiante()) {
      try {
        return await cacheSource.getCachedCursosEstudianteData();
      } catch (e) {}
    }
    // 2. Traemos de la API y guardamos
    final remoteCursos = await cursoSource.getCursosByEstudiante(
      emailEstudiante,
    );
    await cacheSource.cacheCursosEstudianteData(remoteCursos);
    return remoteCursos;
  }

  @override
  Future<void> vaciarContenidoCurso(String idCurso) async =>
      await cursoSource.vaciarContenidoCurso(idCurso);

  @override
  Future<List<String>> getCompanerosDeGrupo(
    String idCat,
    String nombreGrupo,
  ) async => await cursoSource.getCompanerosDeGrupo(idCat, nombreGrupo);

  @override
  Future<List<Map<String, dynamic>>> getCategoriasByCurso(
    String idCurso,
  ) async => await cursoSource.getCategoriasByCurso(idCurso);

  @override
  Future<List<Map<String, dynamic>>> getDatosDeGruposPorCategoria(
    String idCat,
  ) async => await cursoSource.getDatosDeGruposPorCategoria(idCat);
}
