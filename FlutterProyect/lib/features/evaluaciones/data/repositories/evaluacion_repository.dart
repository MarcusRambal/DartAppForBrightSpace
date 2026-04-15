//FlutterProyect/lib/features/evaluaciones/data/repositories/evaluacion_repository.dart
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';

import '../../domain/repositories/i_evaluacion_repository.dart';
import '../dataSources/i_evaluacion_source.dart';

class EvluacionRepository implements IEvaluacionRepository {
  final IEvaluacionSource evaluacionSource;

  EvluacionRepository(this.evaluacionSource);

  @override
  Future<void> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  ) async {
    await evaluacionSource.createEvaluacion(
      idCategoria,
      tipo,
      fechaCreacion,
      fechaFinalizacion,
      nom,
      esPrivada,
    );
  }

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(
    String idCategoria,
  ) async => await evaluacionSource.getEvaluacionesByProfe(idCategoria);

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async =>
      await evaluacionSource.createRespuestas(respuestas);

  @override
  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  ) async =>
      await evaluacionSource.yaEvaluo(idEvaluacion, idEvaluador, idEvaluado);

  @override
  Future<List<PreguntaEntity>> getPreguntas() async =>
      await evaluacionSource.getPreguntas();

  @override
  Future<List<String>> getNotasPorEvaluado(
    String idEvaluacion,
    String idEvaluado,
    String tipo,
  ) async =>
      await evaluacionSource.getNotasPorEvaluado(idEvaluacion, idEvaluado, tipo);
}
