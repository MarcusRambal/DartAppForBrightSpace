import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';

class MockEvaluacionRepository extends Mock implements IEvaluacionRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EvaluacionController controller;
  late MockEvaluacionRepository mockRepository;

  final tEvaluacion = EvaluacionEntity(
    id: '1',
    idCategoria: 'cat_1',
    tipo: 'Autoevaluación',
    fechaCreacion: DateTime(2026, 4, 1),
    fechaFinalizacion: DateTime(2026, 4, 10),
    nom: 'Parcial 1',
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

  setUp(() {
    Get.testMode = true;
    Get.reset();

    mockRepository = MockEvaluacionRepository();
    controller = EvaluacionController(repository: mockRepository);
  });

  group('cargarEvaluaciones', () {
    test('debe cargar evaluaciones correctamente', () async {
      when(
        mockRepository.getEvaluacionesByProfe('cat_1'),
      ).thenAnswer((_) async => [tEvaluacion]);

      await controller.cargarEvaluaciones('cat_1');

      expect(controller.isLoading.value, false);
      expect(controller.evaluaciones.length, 1);
      expect(controller.evaluaciones.first, tEvaluacion);

      verify(mockRepository.getEvaluacionesByProfe('cat_1')).called(1);
    });

    test('debe manejar error al cargar evaluaciones', () async {
      when(
        mockRepository.getEvaluacionesByProfe('cat_1'),
      ).thenThrow(Exception('Error cargando'));

      await controller.cargarEvaluaciones('cat_1');

      expect(controller.isLoading.value, false);
      expect(controller.evaluaciones, isEmpty);

      verify(mockRepository.getEvaluacionesByProfe('cat_1')).called(1);
    });
  });

  group('cargarPreguntas', () {
    test('debe cargar preguntas correctamente', () async {
      when(mockRepository.getPreguntas()).thenAnswer((_) async => [tPregunta]);

      await controller.cargarPreguntas();

      expect(controller.isLoadingPreguntas.value, false);
      expect(controller.preguntas.length, 1);
      expect(controller.preguntas.first, tPregunta);

      verify(mockRepository.getPreguntas()).called(1);
    });

    test('debe manejar error al cargar preguntas', () async {
      when(
        mockRepository.getPreguntas(),
      ).thenThrow(Exception('Error preguntas'));

      await controller.cargarPreguntas();

      expect(controller.isLoadingPreguntas.value, false);
      expect(controller.preguntas, isEmpty);

      verify(mockRepository.getPreguntas()).called(1);
    });
  });

  group('crearEvaluacion', () {
    test('debe crear evaluación correctamente', () async {
      when(
        mockRepository.createEvaluacion(
          'cat_1',
          'Autoevaluación',
          '2026-04-01',
          '2026-04-10',
          'Parcial 1',
          false,
        ),
      ).thenAnswer((_) async => null);

      await controller.crearEvaluacion(
        'cat_1',
        'Autoevaluación',
        '2026-04-01',
        '2026-04-10',
        'Parcial 1',
        false,
      );

      expect(controller.isCreating.value, false);

      verify(
        mockRepository.createEvaluacion(
          'cat_1',
          'Autoevaluación',
          '2026-04-01',
          '2026-04-10',
          'Parcial 1',
          false,
        ),
      ).called(1);
    });

    test('debe manejar error al crear evaluación', () async {
      when(
        mockRepository.createEvaluacion(
          'cat_1',
          'Autoevaluación',
          '2026-04-01',
          '2026-04-10',
          'Parcial 1',
          false,
        ),
      ).thenThrow(Exception('Error creando'));

      await controller.crearEvaluacion(
        'cat_1',
        'Autoevaluación',
        '2026-04-01',
        '2026-04-10',
        'Parcial 1',
        false,
      );

      expect(controller.isCreating.value, false);
    });
  });

  group('respuestas', () {
    test('debe agregar y limpiar respuestas', () {
      controller.agregarRespuesta(tRespuesta);
      expect(controller.respuestas.length, 1);

      controller.limpiarRespuestas();
      expect(controller.respuestas, isEmpty);
    });

    test('debe enviar respuestas y limpiar la lista', () async {
      controller.agregarRespuesta(tRespuesta);

      when(
        mockRepository.createRespuestas([tRespuesta]),
      ).thenAnswer((_) async => null);

      await controller.enviarRespuestas();

      expect(controller.isSending.value, false);
      expect(controller.respuestas, isEmpty);

      verify(mockRepository.createRespuestas([tRespuesta])).called(1);
    });

    test('si falla enviarRespuestas, no debe limpiar la lista', () async {
      controller.agregarRespuesta(tRespuesta);

      when(
        mockRepository.createRespuestas([tRespuesta]),
      ).thenThrow(Exception('Error enviando'));

      await controller.enviarRespuestas();

      expect(controller.isSending.value, false);
      expect(controller.respuestas.length, 1);
    });
  });

  group('yaEvaluo', () {
    test('debe retornar true cuando el repositorio responde true', () async {
      when(
        mockRepository.yaEvaluo('1', 'eval_1', 'eval_2'),
      ).thenAnswer((_) async => true);

      final result = await controller.yaEvaluo('1', 'eval_1', 'eval_2');

      expect(result, true);
      verify(mockRepository.yaEvaluo('1', 'eval_1', 'eval_2')).called(1);
    });

    test('debe retornar false cuando el repositorio lanza error', () async {
      when(
        mockRepository.yaEvaluo('1', 'eval_1', 'eval_2'),
      ).thenThrow(Exception('Error validando'));

      final result = await controller.yaEvaluo('1', 'eval_1', 'eval_2');

      expect(result, false);
      verify(mockRepository.yaEvaluo('1', 'eval_1', 'eval_2')).called(1);
    });
  });
}
