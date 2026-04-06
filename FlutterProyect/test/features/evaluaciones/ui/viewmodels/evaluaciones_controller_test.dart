import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';

class FakeEvaluacionRepository implements IEvaluacionRepository {
  Future<List<EvaluacionEntity>> Function(String idCategoria)?
  getEvaluacionesByProfeHandler;

  Future<List<PreguntaEntity>> Function()? getPreguntasHandler;

  Future<void> Function(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  )?
  createEvaluacionHandler;

  Future<void> Function(List<RespuestaEntity> respuestas)?
  createRespuestasHandler;

  Future<bool> Function(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  )?
  yaEvaluoHandler;

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(
    String idCategoria,
  ) async {
    if (getEvaluacionesByProfeHandler != null) {
      return getEvaluacionesByProfeHandler!(idCategoria);
    }
    return [];
  }

  @override
  Future<List<PreguntaEntity>> getPreguntas() async {
    if (getPreguntasHandler != null) {
      return getPreguntasHandler!();
    }
    return [];
  }

  @override
  Future<void> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  ) async {
    if (createEvaluacionHandler != null) {
      return createEvaluacionHandler!(
        idCategoria,
        tipo,
        fechaCreacion,
        fechaFinalizacion,
        nom,
        esPrivada,
      );
    }
  }

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {
    if (createRespuestasHandler != null) {
      return createRespuestasHandler!(respuestas);
    }
  }

  @override
  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  ) async {
    if (yaEvaluoHandler != null) {
      return yaEvaluoHandler!(idEvaluacion, idEvaluador, idEvaluado);
    }
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Get.testMode = true;
  });

  late EvaluacionController controller;
  late FakeEvaluacionRepository fakeRepository;

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
    Get.reset();
    Get.testMode = true;

    fakeRepository = FakeEvaluacionRepository();
    controller = EvaluacionController(repository: fakeRepository);
  });

  group('cargarEvaluaciones', () {
    test('debe cargar evaluaciones correctamente', () async {
      fakeRepository.getEvaluacionesByProfeHandler = (idCategoria) async => [
        tEvaluacion,
      ];

      await controller.cargarEvaluaciones('cat_1');

      expect(controller.isLoading.value, false);
      expect(controller.evaluaciones.length, 1);
      expect(controller.evaluaciones.first, tEvaluacion);
    });

    testWidgets('debe manejar error al cargar evaluaciones', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );

      fakeRepository.getEvaluacionesByProfeHandler = (_) async =>
          throw Exception('Error cargando');

      await controller.cargarEvaluaciones('cat_1');
      await tester.pump();

      expect(controller.isLoading.value, false);
      expect(controller.evaluaciones, isEmpty);
    });
  });

  group('cargarPreguntas', () {
    test('debe cargar preguntas correctamente', () async {
      fakeRepository.getPreguntasHandler = () async => [tPregunta];

      await controller.cargarPreguntas();

      expect(controller.isLoadingPreguntas.value, false);
      expect(controller.preguntas.length, 1);
      expect(controller.preguntas.first, tPregunta);
    });

    testWidgets('debe manejar error al cargar preguntas', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );

      fakeRepository.getPreguntasHandler = () async =>
          throw Exception('Error preguntas');

      await controller.cargarPreguntas();
      await tester.pump();

      expect(controller.isLoadingPreguntas.value, false);
      expect(controller.preguntas, isEmpty);
    });
  });

  group('crearEvaluacion', () {
    test('debe crear evaluación correctamente', () async {
      bool fueLlamado = false;

      fakeRepository.createEvaluacionHandler =
          (
            idCategoria,
            tipo,
            fechaCreacion,
            fechaFinalizacion,
            nom,
            esPrivada,
          ) async {
            fueLlamado = true;
            expect(idCategoria, 'cat_1');
            expect(tipo, 'Autoevaluación');
            expect(fechaCreacion, '2026-04-01');
            expect(fechaFinalizacion, '2026-04-10');
            expect(nom, 'Parcial 1');
            expect(esPrivada, false);
          };

      await controller.crearEvaluacion(
        'cat_1',
        'Autoevaluación',
        '2026-04-01',
        '2026-04-10',
        'Parcial 1',
        false,
      );

      expect(controller.isCreating.value, false);
      expect(fueLlamado, true);
    });

    testWidgets('debe manejar error al crear evaluación', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );

      fakeRepository.createEvaluacionHandler =
          (_, __, ___, ____, _____, ______) async {
            throw Exception('Error creando');
          };

      await controller.crearEvaluacion(
        'cat_1',
        'Autoevaluación',
        '2026-04-01',
        '2026-04-10',
        'Parcial 1',
        false,
      );
      await tester.pump();

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
      List<RespuestaEntity>? respuestasRecibidas;

      controller.agregarRespuesta(tRespuesta);

      fakeRepository.createRespuestasHandler = (respuestas) async {
        respuestasRecibidas = List<RespuestaEntity>.from(respuestas);
      };

      await controller.enviarRespuestas();

      expect(controller.isSending.value, false);
      expect(controller.respuestas, isEmpty);
      expect(respuestasRecibidas, isNotNull);
      expect(respuestasRecibidas!.length, 1);
      expect(respuestasRecibidas!.first, tRespuesta);
    });

    testWidgets('si falla enviarRespuestas, no debe limpiar la lista', (
      tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox())),
      );

      controller.agregarRespuesta(tRespuesta);

      fakeRepository.createRespuestasHandler = (_) async =>
          throw Exception('Error enviando');

      await controller.enviarRespuestas();
      await tester.pump();

      expect(controller.isSending.value, false);
      expect(controller.respuestas.length, 1);
    });
  });

  group('yaEvaluo', () {
    test('debe retornar true cuando el repositorio responde true', () async {
      fakeRepository.yaEvaluoHandler = (_, __, ___) async => true;

      final result = await controller.yaEvaluo('1', 'eval_1', 'eval_2');

      expect(result, true);
    });

    test('debe retornar false cuando el repositorio lanza error', () async {
      fakeRepository.yaEvaluoHandler = (_, __, ___) async =>
          throw Exception('Error validando');

      final result = await controller.yaEvaluo('1', 'eval_1', 'eval_2');

      expect(result, false);
    });
  });
}
