import '../../domain/entities/curso_curso.dart';
import '../../domain/repositories/i_curso_repository.dart';
import '../dataSources/i_curso_source.dart';
import '../../domain/entities/curso_matriculado.dart';

class CursoRepository implements ICursoRepository {
  late ICursoSource cursoSource;

  CursoRepository(this.cursoSource);

  @override
  Future<void> createCurso(String idCurso, String nom) async =>
      await cursoSource.createCurso(idCurso, nom);

  @override
  Future<void> updateCurso(CursoCurso curso, String NomNuevo) async =>
      await cursoSource.updateCurso(curso, NomNuevo);

  @override
  Future<void> deleteCurso(String idCurso) async =>
      await cursoSource.deleteCurso(idCurso);
  @override
  Future<List<CursoCurso>> getCursosByProfe() async =>
      await cursoSource.getCursosByProfe();

  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(
    String emailEstudiante,
  ) async => await cursoSource.getCursosByEstudiante(emailEstudiante);

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
