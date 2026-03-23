import '../entities/curso_curso.dart';

abstract class ICursoRepository {
  Future<void> createCurso(String idCurso, String nom);

  Future<void> updateCurso(CursoCurso curso,  String NomNuevo);

  Future<void> deleteCurso(String idCurso);

  Future<List<CursoCurso>> getCursosByProfe();
}
