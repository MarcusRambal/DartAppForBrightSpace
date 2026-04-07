import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/views/responder_evaluacion_page.dart';

class FakeEvaluacionRepository implements IEvaluacionRepository {
  List<PreguntaEntity> preguntas = [];
  List<RespuestaEntity> respuestasEnviadas = [];
  bool failEnviar = false;

  @override
  Future<void> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  ) async {}

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {
    if (failEnviar) {
      throw Exception('Error enviando');
    }
    respuestasEnviadas = List<RespuestaEntity>.from(respuestas);
  }

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(
    String idCategoria,
  ) async {
    return [];
  }

  @override
  Future<List<PreguntaEntity>> getPreguntas() async {
    return preguntas;
  }

  @override
  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  ) async {
    return false;
  }
}

class FakeLocalPreferences implements ILocalPreferences {
  final Map<String, dynamic> storage = {'userId': 'mi_correo@uninorte.edu.co'};

  @override
  Future<String?> getString(String key) async => storage[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    storage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async => storage[key] as int?;

  @override
  Future<void> setInt(String key, int value) async {
    storage[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async => storage[key] as double?;

  @override
  Future<void> setDouble(String key, double value) async {
    storage[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => storage[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    storage[key] = value;
  }

  @override
  Future<List<String>?> getStringList(String key) async =>
      storage[key] as List<String>?;

  @override
  Future<void> setStringList(String key, List<String> value) async {
    storage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    storage.remove(key);
  }

  @override
  Future<void> clear() async {
    storage.clear();
  }
}

void main() {
  late FakeEvaluacionRepository fakeRepository;
  late EvaluacionController controller;
  late FakeLocalPreferences fakePrefs;

  final evaluacion = EvaluacionEntity(
    id: 'eval_1',
    idCategoria: 'cat_1',
    tipo: 'Autoevaluación',
    fechaCreacion: DateTime(2026, 4, 1),
    fechaFinalizacion: DateTime(2026, 4, 10),
    nom: 'Evaluación 1',
    esPrivada: false,
  );

  setUp(() {
    Get.testMode = true;
    Get.reset();

    fakeRepository = FakeEvaluacionRepository();
    fakePrefs = FakeLocalPreferences();

    controller = EvaluacionController(repository: fakeRepository);

    Get.put<EvaluacionController>(controller);
    Get.put<ILocalPreferences>(fakePrefs);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('ResponderEvaluacionPage widget tests', () {
    testWidgets('muestra loading mientras carga preguntas', (tester) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('muestra mensaje si no hay preguntas', (tester) async {
      fakeRepository.preguntas = [];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No hay preguntas'), findsOneWidget);
    });

    testWidgets('muestra la primera pregunta y opciones', (tester) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('¿Cómo fue el trabajo en equipo?'), findsOneWidget);
      expect(find.text('Excelente (5)'), findsOneWidget);
      expect(find.text('Bueno (4)'), findsOneWidget);
      expect(find.text('Adecuado (3)'), findsOneWidget);
      expect(find.text('Podría mejorar (2)'), findsOneWidget);
      expect(find.text('Pregunta 1 de 1'), findsOneWidget);
    });

    testWidgets('activa finalizar al responder la última pregunta', (
      tester,
    ) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
          ),
        ),
      );

      await tester.pumpAndSettle();

      final botonAntes = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Finalizar evaluación'),
      );
      expect(botonAntes.onPressed, isNull);

      await tester.tap(find.text('Excelente (5)'));
      await tester.pump();

      final botonDespues = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Finalizar evaluación'),
      );
      expect(botonDespues.onPressed, isNotNull);
    });

    testWidgets('envía respuestas al finalizar', (tester) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Excelente (5)'));
      await tester.pump();

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Finalizar evaluación'),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(fakeRepository.respuestasEnviadas.length, 1);
      expect(fakeRepository.respuestasEnviadas.first.idEvaluacion, 'eval_1');
      expect(
        fakeRepository.respuestasEnviadas.first.idEvaluado,
        'compa@uninorte.edu.co',
      );
      expect(
        fakeRepository.respuestasEnviadas.first.idEvaluador,
        'mi_correo@uninorte.edu.co',
      );
      expect(fakeRepository.respuestasEnviadas.first.idPregunta, '1');
      expect(fakeRepository.respuestasEnviadas.first.valorComentario, '5');
    });
  });
}
