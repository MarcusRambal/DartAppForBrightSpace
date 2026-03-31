import '../entities/respuesta_entity.dart';
abstract class IRespuestaRepository {
  Future<void> createRespuestas(List<RespuestaEntity> respuestas);

  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  );
}