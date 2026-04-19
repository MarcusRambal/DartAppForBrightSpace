import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';

import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';

import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';

import '../features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';

class FakeEvaluacionesRepository implements IEvaluacionRepository {
  @override
  Future<void> createEvaluacion(String idCategoria, String tipo, String fechaCreacion, String fechaFinalizacion, String nom, bool esPrivada) {
    // TODO: implement createEvaluacion
    throw UnimplementedError();
  }

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) {
    // TODO: implement createRespuestas
    throw UnimplementedError();
  }

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      EvaluacionEntity(
        id: "1775164830699",
        idCategoria: '1774449735424',
        tipo: "General",
        nom: "pub_publica",
        fechaCreacion: DateTime.parse("2026-04-02T16:21:00"),
        fechaFinalizacion: DateTime.parse("2026-04-02T16:23:00"),
        esPrivada: false,
      )
    ];
  }

  @override
  Future<List<String>> getNotasPorEvaluado(String idEvaluacion, String idEvaluado, String tipo) {
    // TODO: implement getNotasPorEvaluado
    throw UnimplementedError();
  }

  @override
  Future<List<PreguntaEntity>> getPreguntas() {
    // TODO: implement getPreguntas
    throw UnimplementedError();
  }

  @override
  Future<bool> yaEvaluo(String idEvaluacion, String idEvaluador, String idEvaluado) {
    // TODO: implement yaEvaluo
    throw UnimplementedError();
  }

  @override
  Future<void> updatePrivacidad(String idEvaluacion, bool esPrivada) {
    // TODO: implement updatePrivacidad
    throw UnimplementedError();
  }

}