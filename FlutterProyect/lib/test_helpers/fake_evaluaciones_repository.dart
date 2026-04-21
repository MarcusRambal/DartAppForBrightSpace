import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import '../features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';

class FakeEvaluacionesRepository implements IEvaluacionRepository {
  final List<EvaluacionEntity> _evaluaciones = [];
  final List<RespuestaEntity> _respuestas = [];
  final Set<String> _evaluacionesRealizadas = {};

  static final EvaluacionEntity _evaluacionVigente = EvaluacionEntity(
    id: '1775164724851',
    idCategoria: '1774449735424',
    nom: 'Examen Final de Flutter',
    tipo: 'General',
    fechaCreacion: DateTime.now().subtract(const Duration(hours: 1)),
    fechaFinalizacion: DateTime.now().add(const Duration(hours: 2)),
    esPrivada: false,
  );

  @override
  Future<void> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));

    // Evita duplicar la evaluación si ya existe una con el mismo id/categoría.
    final yaExiste = _evaluaciones.any(
      (e) => e.id == '1775164724851' && e.idCategoria == idCategoria,
    );

    if (!yaExiste) {
      final nuevaEvaluacion = EvaluacionEntity(
        id: '1775164724851',
        idCategoria: idCategoria,
        nom: nom,
        tipo: tipo,
        fechaCreacion: DateTime.now().subtract(const Duration(hours: 1)),
        fechaFinalizacion: DateTime.now().add(const Duration(hours: 2)),
        esPrivada: esPrivada,
      );

      _evaluaciones.add(nuevaEvaluacion);
    }
  }

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _respuestas.addAll(respuestas);

    for (final r in respuestas) {
      final key = '${r.idEvaluacion}|${r.idEvaluador}|${r.idEvaluado}';
      _evaluacionesRealizadas.add(key);
    }
  }

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(
    String idCategoria,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final creadas = _evaluaciones
        .where((e) => e.idCategoria == idCategoria)
        .toList();

    // Si el profesor ya creó una evaluación para esa categoría, devolvemos solo esa(s).
    if (creadas.isNotEmpty) {
      return creadas;
    }

    // Si no hay creadas y es la categoría del estudiante, devolvemos la fija
    // para que el flujo del estudiante tenga una evaluación vigente.
    if (idCategoria == _evaluacionVigente.idCategoria) {
      return [_evaluacionVigente];
    }

    return [];
  }

  @override
  Future<List<String>> getNotasPorEvaluado(
    String idEvaluacion,
    String idEvaluado,
    String tipo,
  ) async {
    return ['5.0', '4.5'];
  }

  @override
  Future<List<PreguntaEntity>> getPreguntas() async {
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      PreguntaEntity(
        idPregunta: 'p1',
        tipo: 'puntualidad',
        pregunta: '¿Cómo evalúas la puntualidad de tu compañero?',
      ),
      PreguntaEntity(
        idPregunta: 'p2',
        tipo: 'contribucion',
        pregunta: '¿Cómo evalúas la contribución de tu compañero al grupo?',
      ),
      PreguntaEntity(
        idPregunta: 'p3',
        tipo: 'actitud',
        pregunta: '¿Cómo evalúas la actitud de tu compañero?',
      ),
      PreguntaEntity(
        idPregunta: 'p4',
        tipo: 'compromiso',
        pregunta: '¿Cómo evalúas el compromiso de tu compañero?',
      ),
    ];
  }

  @override
  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final key = '$idEvaluacion|$idEvaluador|$idEvaluado';
    return _evaluacionesRealizadas.contains(key);
  }

  @override
  Future<void> updatePrivacidad(String idEvaluacion, bool esPrivada) async {
    for (int i = 0; i < _evaluaciones.length; i++) {
      final e = _evaluaciones[i];
      if (e.id == idEvaluacion) {
        _evaluaciones[i] = EvaluacionEntity(
          id: e.id,
          idCategoria: e.idCategoria,
          nom: e.nom,
          tipo: e.tipo,
          fechaCreacion: e.fechaCreacion,
          fechaFinalizacion: e.fechaFinalizacion,
          esPrivada: esPrivada,
        );
        return;
      }
    }
  }
}
