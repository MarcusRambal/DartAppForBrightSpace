class ReportePersonalPorEvaluacionEntity {
  final String idReportePersonal;
  final String idEvaluacion;
  final String idEstudiante;
  final double notaPuntualidad;
  final double notaContribucion;
  final double notaActitud;
  final double notaCompromiso;

  ReportePersonalPorEvaluacionEntity({
    required this.idReportePersonal,
    required this.idEvaluacion,
    required this.idEstudiante,
    required this.notaPuntualidad,
    required this.notaContribucion,
    required this.notaActitud,
    required this.notaCompromiso,
  });
}