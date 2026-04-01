// features/preguntas/data/models/pregunta_model.dart

import '../../../evaluaciones/domain/entities/pregunta_entity.dart';

class PreguntaModel extends PreguntaEntity {
  PreguntaModel({
    required String idPregunta,
    required String tipo,
    required String pregunta,
  }) : super(
          idPregunta: idPregunta,
          tipo: tipo,
          pregunta: pregunta,
        );

  factory PreguntaModel.fromJson(Map<String, dynamic> json) {
    return PreguntaModel(
      idPregunta: json['idPregunta'].toString(),
      tipo: json['tipo'].toString(),
      pregunta: json['pregunta'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPregunta': idPregunta,
      'tipo': tipo,
      'pregunta': pregunta,
    };
  }

  factory PreguntaModel.fromEntity(PreguntaEntity pregunta) {
    return PreguntaModel(
      idPregunta: pregunta.idPregunta,
      tipo: pregunta.tipo,
      pregunta: pregunta.pregunta,
    );
  }
}