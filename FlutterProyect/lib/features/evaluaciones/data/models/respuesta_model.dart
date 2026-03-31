import '../../domain/entities/respuesta_entity.dart';

class RespuestaModel extends RespuestaEntity {
  RespuestaModel({
    super.id,
    required super.idEvaluacion,
    required super.idEvaluador,
    required super.idEvaluado,
    required super.idPregunta,
    required super.tipo,
    required super.valorComentario,
  });

  factory RespuestaModel.fromJson(Map<String, dynamic> json) {
    return RespuestaModel(
      id: json['idRespuesta']?.toString(),
      idEvaluacion: json['idEvaluacion']?.toString() ?? '',
      idEvaluador: json['idEvaluador']?.toString() ?? '',
      idEvaluado: json['idEvaluado']?.toString() ?? '',
      idPregunta: json['idPregunta']?.toString() ?? '',
      tipo: json['tipo'] ?? '',
      valorComentario: json['valor_comentario'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'idRespuesta': id,
      'idEvaluacion': idEvaluacion,
      'idEvaluador': idEvaluador,
      'idEvaluado': idEvaluado,
      'idPregunta': idPregunta,
      'tipo': tipo,
      'valor_comentario': valorComentario,
    };
  }
}