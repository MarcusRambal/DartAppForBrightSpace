import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';

import '../../domain/repositories/i_evaluacion_repository.dart';
import '../dataSources/i_evaluacion_source.dart';

class EvluacionRepository implements IEvaluacionRepository {
  final IEvaluacionSource evaluacionSource;
  EvluacionRepository(this.evaluacionSource);
  @override
  Future<String> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
  ) async => await evaluacionSource.createEvaluacion(
    idCategoria,
    tipo,
    fechaCreacion,
    fechaFinalizacion,
  );

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(
    String idCategoria,
  ) async => await evaluacionSource.getEvaluacionesByProfe(idCategoria);
}
