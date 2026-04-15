import '../entities/evaluacion_entity.dart';
import '../entities/respuesta_entity.dart';
import '../entities/pregunta_entity.dart';

abstract class IEvaluacionRepository {
  Future<void> createRespuestas(List<RespuestaEntity> respuestas);

  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  );

  Future<void> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  );

  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria);
  Future<List<PreguntaEntity>> getPreguntas();
  Future<List<String>> getNotasPorEvaluado(
    String idEvaluacion,
    String idEvaluado,
    String tipo,
  );
}
