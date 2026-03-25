import 'curso_curso.dart';

class CategoriaGrupo {
  final String idCat;
  final String categoriaNombre;
  final String grupoNombre;

  CategoriaGrupo({
    required this.idCat,
    required this.categoriaNombre,
    required this.grupoNombre,
  });
}

class CursoMatriculado {
  final CursoCurso curso;
  final List<CategoriaGrupo> grupos;
  final int evaluacionesPendientes;

  CursoMatriculado({
    required this.curso,
    required this.grupos,
    this.evaluacionesPendientes = 0,
  });
}
