class ReportePersonalPorEvaluacionEntity {
  final String idReportePersonal;
  final String idEvaluacion;
  final String idEstudiante;
  final String notaPuntualidad;
  final String notaContribucion;
  final String notaActitud;
  final String notaCompromiso;

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