import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';

import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';

import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';

import '../features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';

class FakeEvaluacionesRepository implements IEvaluacionRepository {

  List<EvaluacionEntity> _evaluaciones = [];
  List<RespuestaEntity> _respuestas = [];


  @override
  Future<void> createEvaluacion (String idCategoria, String tipo, String fechaCreacion, String fechaFinalizacion, String nom, bool esPrivada,) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final nuevaEvaluacion = EvaluacionEntity(
      id: '1775164724851',
      idCategoria: '1774449735424',
      nom: 'priv_priv',
      tipo: 'General',
      fechaCreacion: DateTime.parse("2026-04-02T16:18:00"),
      fechaFinalizacion: DateTime.parse("2026-04-02T17:18:00"),
      esPrivada: true,
    );
    _evaluaciones.add(nuevaEvaluacion);
    print("Evaluación '$nom' agregada al FakeRepository");

  }



  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 4. Guardamos las respuestas en nuestra lista interna
    _respuestas.addAll(respuestas);

    print("Se guardaron ${respuestas.length} respuestas en el FakeRepository");
  }

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Filtramos la lista interna _evaluaciones (donde se agregan las nuevas)
    // + una evaluación base para que siempre haya algo en la UI
    final lista = _evaluaciones.where((e) => e.idCategoria == idCategoria).toList();
    return lista;
  }

  @override
  Future<List<String>> getNotasPorEvaluado(String idEvaluacion, String idEvaluado, String tipo) {
    return Future.value(["5.0", "4.5"]);
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
  Future<void> updatePrivacidad(String idEvaluacion, bool esPrivada) async {
    print("Privacidad actualizada para $idEvaluacion");
  }

}