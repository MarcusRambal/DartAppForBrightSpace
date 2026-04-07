import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/features/student_home/ui/views/EvaluacionDetailPage.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/student_home/ui/views/student_course_details_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';


class MockStudentCourseController extends GetxController with Mock implements StudentCourseDetailsController {
  @override
  RxMap<String, List<String>> get companerosPorCategoria => {
    "cat_1": ["marcus@uninorte.edu.co", "companero@uninorte.edu.co"]
  }.obs;
}

class MockEvaluacionController extends GetxController with Mock implements EvaluacionController {
  @override
  Future<bool> yaEvaluo(String idEval, String algo, String correo) async => false;
}

class FakeLocalPreferences extends Fake implements ILocalPreferences {
  String? returnEmail;
  @override
  Future<String?> getString(String key) async => returnEmail;
}

void main() {
  late MockStudentCourseController mockStudentController;
  late MockEvaluacionController mockEvalController;
  late FakeLocalPreferences fakePrefs;

  final testEval = EvaluacionEntity(
    id: "eval_123",
    idCategoria: "cat_1",
    tipo: "AUTO",
    nom: "Evaluación de Desempeño",
    fechaCreacion: DateTime.now().subtract(const Duration(hours: 1)),
    fechaFinalizacion: DateTime.now().add(const Duration(hours: 1)),
    esPrivada: false,
  );

  final grupoSimulado = NavigationData(idCat: "cat_1");

  setUp(() {
    Get.testMode = true;
    mockStudentController = MockStudentCourseController();
    mockEvalController = MockEvaluacionController();
    fakePrefs = FakeLocalPreferences();

    Get.put<StudentCourseDetailsController>(mockStudentController);
    Get.put<EvaluacionController>(mockEvalController);
    Get.put<ILocalPreferences>(fakePrefs);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('EvaluacionDetailPage Widget Tests', () {

    testWidgets('Debe mostrar indicador de carga si miCorreo es null', (WidgetTester tester) async {
      fakePrefs.returnEmail = null;

      await tester.pumpWidget(GetMaterialApp(
        home: EvaluacionDetailPage(evaluacion: testEval, grupo: grupoSimulado),
      ));

      expect(find.byKey(const Key('evaluacionDetailLoadingScaffold')), findsOneWidget);
    });

    testWidgets('Debe mostrar la lista de compañeros correctamente', (WidgetTester tester) async {
      fakePrefs.returnEmail = "marcus@uninorte.edu.co";

      await tester.pumpWidget(GetMaterialApp(
        home: EvaluacionDetailPage(evaluacion: testEval, grupo: grupoSimulado),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text("companero@uninorte.edu.co"), findsOneWidget);
    });

    testWidgets('Debe mostrar banner de CERRADO si la fecha ya pasó', (WidgetTester tester) async {
      fakePrefs.returnEmail = "marcus@uninorte.edu.co";

      final evalCerrada = EvaluacionEntity(
        id: "eval_old",
        idCategoria: "cat_1",
        tipo: "CO",
        nom: "Evaluación Pasada",
        fechaCreacion: DateTime.now().subtract(const Duration(hours: 2)),
        fechaFinalizacion: DateTime.now().subtract(const Duration(hours: 1)),
        esPrivada: false,
      );

      await tester.pumpWidget(GetMaterialApp(
        home: EvaluacionDetailPage(evaluacion: evalCerrada, grupo: grupoSimulado),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('evaluacionStatusBanner_cerrado')), findsOneWidget);
      expect(find.byKey(const Key('lockAction_companero@uninorte.edu.co')), findsOneWidget);
    });
  });
}

class NavigationData {
  final String idCat;
  NavigationData({required this.idCat});
}