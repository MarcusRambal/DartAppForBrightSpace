import '../../domain/entities/curso_curso.dart';

abstract class ICursoSource {
  Future<void> createCurso(String idCurso, String nom);

  Future<void> updateCurso(CursoCurso curso, String NomNuevo);

  Future<void> deleteCurso(String idCurso);

  Future<List<CursoCurso>> getCursosByProfe();

  Future<List<CursoCurso>> getCursosByEstudiante(String emailEstudiante);

  Future<void> vaciarContenidoCurso(String idCurso);
}
