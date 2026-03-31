class RespuestaEntity {
  final String? id;
  final String idEvaluacion;
  final String idEvaluador;
  final String idEvaluado;
  final String idPregunta;
  final String tipo;
  final String valorComentario;

  RespuestaEntity({
    this.id,
    required this.idEvaluacion,
    required this.idEvaluador,
    required this.idEvaluado,
    required this.idPregunta,
    required this.tipo,
    required this.valorComentario,
  });
}