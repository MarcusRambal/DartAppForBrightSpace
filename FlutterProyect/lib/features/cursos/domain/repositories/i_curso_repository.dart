import '../entities/curso_curso.dart';
import '../entities/curso_matriculado.dart';

abstract class ICursoRepository {
  Future<void> createCurso(String idCurso, String nom);

  Future<void> updateCurso(CursoCurso curso, String NomNuevo);

  Future<void> deleteCurso(String idCurso);

  Future<List<CursoCurso>> getCursosByProfe();

  Future<List<CursoMatriculado>> getCursosByEstudiante(String emailEstudiante);

  Future<void> vaciarContenidoCurso(String idCurso);

  Future<List<String>> getCompanerosDeGrupo(String idCat, String nombreGrupo);

  Future<List<Map<String, dynamic>>> getCategoriasByCurso(String idCurso);

  Future<List<Map<String, dynamic>>> getDatosDeGruposPorCategoria(String idCat);
}
