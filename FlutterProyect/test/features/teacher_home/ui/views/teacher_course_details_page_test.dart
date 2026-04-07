import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';
import 'package:flutter_prueba/features/cursos/domain/repositories/i_curso_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'package:flutter_prueba/features/teacher_home/ui/views/teacher_course_details_page.dart';
import 'package:flutter_prueba/features/teacher_home/ui/views/teacher_group_details_page.dart';

class FakeCurso implements CursoCurso {
  @override
  String get id => 'curso_1';

  @override
  String get nombre => 'Programación Móvil';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCursoRepository implements ICursoRepository {
  Future<List<Map<String, dynamic>>> Function(String idCurso)?
  getCategoriasByCursoHandler;

  Future<List<Map<String, dynamic>>> Function(String idCat)?
  getDatosDeGruposPorCategoriaHandler;

  @override
  Future<List<Map<String, dynamic>>> getCategoriasByCurso(
    String idCurso,
  ) async {
    if (getCategoriasByCursoHandler != null) {
      return getCategoriasByCursoHandler!(idCurso);
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getDatosDeGruposPorCategoria(
    String idCat,
  ) async {
    if (getDatosDeGruposPorCategoriaHandler != null) {
      return getDatosDeGruposPorCategoriaHandler!(idCat);
    }
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEvaluacionRepository implements IEvaluacionRepository {
  Future<List<EvaluacionEntity>> Function(String idCategoria)?
  getEvaluacionesByProfeHandler;

  List<PreguntaEntity> preguntas = [];
  bool crearEvaluacionCalled = false;

  String? lastIdCategoria;
  String? lastTipo;
  String? lastFechaInicio;
  String? lastFechaFin;
  String? lastNombre;
  bool? lastEsPrivada;

  @override
  Future<void> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  ) async {
    crearEvaluacionCalled = true;
    lastIdCategoria = idCategoria;
    lastTipo = tipo;
    lastFechaInicio = fechaCreacion;
    lastFechaFin = fechaFinalizacion;
    lastNombre = nom;
    lastEsPrivada = esPrivada;
  }

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {}

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

void main() {
  late FakeCursoRepository fakeCursoRepository;
  late FakeEvaluacionRepository fakeEvaluacionRepository;

  final curso = FakeCurso();

  setUp(() {
    Get.testMode = true;
    Get.reset();

    fakeCursoRepository = FakeCursoRepository();
    fakeEvaluacionRepository = FakeEvaluacionRepository();

    Get.put<ICursoRepository>(fakeCursoRepository);
    Get.put<IEvaluacionRepository>(fakeEvaluacionRepository);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('TeacherCourseDetailsPage widget tests', () {
    testWidgets('muestra loading mientras carga categorías', (tester) async {
      final completer = Completer<List<Map<String, dynamic>>>();

      fakeCursoRepository.getCategoriasByCursoHandler = (_) => completer.future;

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherCourseDetailsPage(curso: curso)),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([
        {'idcat': 'cat_1', 'nombre': 'Categoría 1'},
      ]);

      await tester.pumpAndSettle();
    });

    testWidgets('muestra mensaje vacío cuando no hay categorías', (
      tester,
    ) async {
      fakeCursoRepository.getCategoriasByCursoHandler = (_) async => [];

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherCourseDetailsPage(curso: curso)),
      );

      await tester.pumpAndSettle();

      expect(find.text('No hay categorías disponibles'), findsOneWidget);
    });

    testWidgets('muestra categorías cuando existen', (tester) async {
      fakeCursoRepository.getCategoriasByCursoHandler = (_) async => [
        {'idcat': 'cat_1', 'nombre': 'Categoría 1'},
        {'idcat': 'cat_2', 'nombre': 'Categoría 2'},
      ];

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherCourseDetailsPage(curso: curso)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Categoría 1'), findsOneWidget);
      expect(find.text('Categoría 2'), findsOneWidget);
      expect(find.text('Categorías'), findsOneWidget);
    });

    testWidgets('navega al detalle del grupo al tocar una categoría', (
      tester,
    ) async {
      fakeCursoRepository.getCategoriasByCursoHandler = (_) async => [
        {'idcat': 'cat_1', 'nombre': 'Categoría 1'},
      ];

      fakeCursoRepository.getDatosDeGruposPorCategoriaHandler = (_) async => [];

      fakeEvaluacionRepository.getEvaluacionesByProfeHandler = (_) async => [];

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherCourseDetailsPage(curso: curso)),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Categoría 1'));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherGroupDetailsPage), findsOneWidget);
      expect(find.text('Grupos'), findsOneWidget);
      expect(find.text('Evaluaciones'), findsOneWidget);
    });

    testWidgets('abre el diálogo de nueva evaluación al tocar el FAB', (
      tester,
    ) async {
      fakeCursoRepository.getCategoriasByCursoHandler = (_) async => [
        {'idcat': 'cat_1', 'nombre': 'Categoría 1'},
      ];

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherCourseDetailsPage(curso: curso)),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nueva Evaluación'), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Fecha inicio'), findsOneWidget);
      expect(find.text('Fecha fin'), findsOneWidget);
      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('valida campos requeridos en el diálogo', (tester) async {
      fakeCursoRepository.getCategoriasByCursoHandler = (_) async => [
        {'idcat': 'cat_1', 'nombre': 'Categoría 1'},
      ];

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherCourseDetailsPage(curso: curso)),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
      await tester.pumpAndSettle();

      expect(find.text('Seleccione categoría'), findsOneWidget);
      expect(find.text('Requerido'), findsNWidgets(3));
    });
  });
}
