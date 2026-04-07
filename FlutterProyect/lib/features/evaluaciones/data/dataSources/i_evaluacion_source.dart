import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';

import '../../domain/entities/evaluacion_entity.dart';
import '../../domain/entities/pregunta_entity.dart';

abstract class IEvaluacionSource {
  Future<String> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  );

  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria);
  Future<List<PreguntaEntity>> getPreguntas();
  Future<void> createRespuestas(List<RespuestaEntity> respuestas);

  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  );
}
