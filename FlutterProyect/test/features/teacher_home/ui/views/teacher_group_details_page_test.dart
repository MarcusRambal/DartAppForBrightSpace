import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_prueba/features/teacher_home/ui/views/teacher_group_details_page.dart';
import 'package:flutter_prueba/features/teacher_home/ui/views/teacher_course_details_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';

class FakeTeacherCourseDetailsController extends GetxController
    implements TeacherCourseDetailsController {
  @override
  var datosGrupos = <String, Map<String, List<String>>>{}.obs;

  @override
  var loadingDetalleCategoria = <String, bool>{}.obs;

  bool fetchDetalleCategoriaCalled = false;
  String? lastCategoriaId;

  @override
  Future<void> fetchDetalleCategoria(String categoriaId) async {
    fetchDetalleCategoriaCalled = true;
    lastCategoriaId = categoriaId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEvaluacionRepository implements IEvaluacionRepository {
  List<EvaluacionEntity> evaluaciones = [];
  String? lastCategoriaId;

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
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {}

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(
    String idCategoria,
  ) async {
    lastCategoriaId = idCategoria;
    return evaluaciones;
  }

  @override
  Future<List<PreguntaEntity>> getPreguntas() async {
    return [];
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
  late FakeTeacherCourseDetailsController fakeController;
  late FakeEvaluacionRepository fakeRepository;
  late EvaluacionController evaluacionController;

  setUp(() {
    Get.testMode = true;
    Get.reset();

    fakeController = FakeTeacherCourseDetailsController();
    fakeRepository = FakeEvaluacionRepository();
    evaluacionController = EvaluacionController(repository: fakeRepository);

    Get.put<TeacherCourseDetailsController>(fakeController);
    Get.put<EvaluacionController>(evaluacionController);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('TeacherGroupDetailsPage widget tests', () {
    testWidgets('muestra loading si la categoría está cargando', (
      tester,
    ) async {
      fakeController.loadingDetalleCategoria['cat_1'] = true;

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TeacherGroupDetailsPage(
            categoriaId: 'cat_1',
            nombreCategoria: 'Categoría 1',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra estados vacíos si no hay grupos ni evaluaciones', (
      tester,
    ) async {
      fakeController.loadingDetalleCategoria['cat_1'] = false;
      fakeController.datosGrupos['cat_1'] = {};
      fakeRepository.evaluaciones = [];

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TeacherGroupDetailsPage(
            categoriaId: 'cat_1',
            nombreCategoria: 'Categoría 1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Grupos'), findsOneWidget);
      expect(find.text('Evaluaciones'), findsOneWidget);
      expect(find.text('No hay grupos disponibles.'), findsOneWidget);
      expect(find.text('No hay evaluaciones creadas.'), findsOneWidget);
      expect(fakeController.fetchDetalleCategoriaCalled, true);
      expect(fakeController.lastCategoriaId, 'cat_1');
      expect(fakeRepository.lastCategoriaId, 'cat_1');
    });

    testWidgets('muestra grupos, integrantes y evaluaciones', (tester) async {
      fakeController.loadingDetalleCategoria['cat_1'] = false;
      fakeController.datosGrupos['cat_1'] = {
        'Grupo 1': ['ana@uninorte.edu.co', 'juan@uninorte.edu.co'],
      };

      fakeRepository.evaluaciones = [
        EvaluacionEntity(
          id: 'eval_1',
          idCategoria: 'cat_1',
          tipo: 'General',
          fechaCreacion: DateTime(2026, 4, 1),
          fechaFinalizacion: DateTime(2026, 4, 10),
          nom: 'Evaluación 1',
          esPrivada: false,
        ),
      ];

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TeacherGroupDetailsPage(
            categoriaId: 'cat_1',
            nombreCategoria: 'Categoría 1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Grupo 1'), findsOneWidget);
      expect(find.text('Evaluación 1'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);

      await tester.tap(find.text('Grupo 1'));
      await tester.pumpAndSettle();

      expect(find.text('ana@uninorte.edu.co'), findsOneWidget);
      expect(find.text('juan@uninorte.edu.co'), findsOneWidget);
    });
  });
}
