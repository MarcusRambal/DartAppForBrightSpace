import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/features/evaluaciones/data/repositories/evaluacion_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/data/dataSources/i_evaluacion_source.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';

import 'evaluacion_repository_test.mocks.dart';

@GenerateMocks([IEvaluacionSource])
void main() {
  late EvluacionRepository repository;
  late MockIEvaluacionSource mockSource;

  setUp(() {
    mockSource = MockIEvaluacionSource();
    repository = EvluacionRepository(mockSource);
  });

  group('EvluacionRepository - Pasarela de datos', () {
    const tIdCategoria = 'cat_1';
    const tTipo = 'Autoevaluación';
    const tFechaCreacion = '2026-04-01';
    const tFechaFinalizacion = '2026-04-10';
    const tNom = 'Parcial 1';
    const tEsPrivada = false;

    final tEvaluacion = EvaluacionEntity(
      id: '1',
      idCategoria: tIdCategoria,
      tipo: tTipo,
      fechaCreacion: DateTime(2026, 4, 1),
      fechaFinalizacion: DateTime(2026, 4, 10),
      nom: tNom,
      esPrivada: false,
    );

    final tPregunta = PreguntaEntity(
      idPregunta: '10',
      tipo: 'texto',
      pregunta: '¿Cómo fue el desempeño?',
    );

    final tRespuesta = RespuestaEntity(
      idEvaluacion: '1',
      idEvaluador: 'eval_1',
      idEvaluado: 'eval_2',
      idPregunta: '10',
      tipo: 'texto',
      valorComentario: 'Muy bien',
    );

    test(
      'Debe llamar a createEvaluacion en el Source y retornar void',
      () async {
        when(
          mockSource.createEvaluacion(
            tIdCategoria,
            tTipo,
            tFechaCreacion,
            tFechaFinalizacion,
            tNom,
            tEsPrivada,
          ),
        ).thenAnswer((_) async => 'id_creado');

        await repository.createEvaluacion(
          tIdCategoria,
          tTipo,
          tFechaCreacion,
          tFechaFinalizacion,
          tNom,
          tEsPrivada,
        );

        verify(
          mockSource.createEvaluacion(
            tIdCategoria,
            tTipo,
            tFechaCreacion,
            tFechaFinalizacion,
            tNom,
            tEsPrivada,
          ),
        ).called(1);
      },
    );

    test(
      'Debe retornar lista de evaluaciones cuando getEvaluacionesByProfe es exitoso',
      () async {
        when(
          mockSource.getEvaluacionesByProfe(tIdCategoria),
        ).thenAnswer((_) async => [tEvaluacion]);

        final result = await repository.getEvaluacionesByProfe(tIdCategoria);

        expect(result, [tEvaluacion]);
        verify(mockSource.getEvaluacionesByProfe(tIdCategoria)).called(1);
      },
    );

    test(
      'Debe retornar lista de preguntas cuando getPreguntas es exitoso',
      () async {
        when(mockSource.getPreguntas()).thenAnswer((_) async => [tPregunta]);

        final result = await repository.getPreguntas();

        expect(result, [tPregunta]);
        verify(mockSource.getPreguntas()).called(1);
      },
    );

    test(
      'Debe llamar a createRespuestas en el Source y retornar void',
      () async {
        when(
          mockSource.createRespuestas([tRespuesta]),
        ).thenAnswer((_) async => Future.value());

        await repository.createRespuestas([tRespuesta]);

        verify(mockSource.createRespuestas([tRespuesta])).called(1);
      },
    );

    test('Debe retornar true cuando yaEvaluo es exitoso', () async {
      when(
        mockSource.yaEvaluo('1', 'eval_1', 'eval_2'),
      ).thenAnswer((_) async => true);

      final result = await repository.yaEvaluo('1', 'eval_1', 'eval_2');

      expect(result, true);
      verify(mockSource.yaEvaluo('1', 'eval_1', 'eval_2')).called(1);
    });

    test(
      'Debe propagar la excepción si el Source falla en getEvaluacionesByProfe',
      () async {
        when(
          mockSource.getEvaluacionesByProfe(tIdCategoria),
        ).thenThrow(Exception('Error de servidor'));

        expect(
          () => repository.getEvaluacionesByProfe(tIdCategoria),
          throwsException,
        );

        verify(mockSource.getEvaluacionesByProfe(tIdCategoria)).called(1);
      },
    );
  });
}
