import '../../domain/entities/evaluacion_entity.dart';
abstract class IEvaluacionSource {
  Future<String> createEvaluacion(String idCategoria, String tipo, String fechaCreacion, String fechaFinalizacion);

  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria);
}
