import '../entities/evaluacion_entity.dart';
import '../entities/respuesta_entity.dart';

abstract class IEvaluacionRepository {
  Future<void> createRespuestas(List<RespuestaEntity> respuestas);

  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  );
  Future<String> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
  );

  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria);
}
