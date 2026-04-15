class ReportePromedioPersonalPorCategoriaEntity {
  final String idReportePromedioPersonal;
  final String idEstudiante;
  final String idCategoria;
  final String nota;
  final String idCurso;

  ReportePromedioPersonalPorCategoriaEntity({
    required this.idReportePromedioPersonal,
    required this.idEstudiante,

    required this.idCategoria,
    required this.nota,
    required this.idCurso,
  });
}
