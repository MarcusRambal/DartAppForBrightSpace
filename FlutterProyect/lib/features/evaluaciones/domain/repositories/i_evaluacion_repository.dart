import '../entities/evaluacion_entity.dart';
abstract class IEvaluacionRepository {
  Future<String> createEvaluacion(String idCategoria, String tipo, String fechaCreacion, String fechaFinalizacion);

  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria);
}
