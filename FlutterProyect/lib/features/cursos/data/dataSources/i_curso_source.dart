//FlutterProyect/lib/features/cursos/data/dataSources/i_curso_source.dart
import '../../domain/entities/curso_curso.dart';
import '../../domain/entities/curso_matriculado.dart';

abstract class ICursoSource {
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
