import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/features/student_home/ui/views/GroupDetailsPage.dart';
import 'package:flutter_prueba/features/student_home/ui/views/student_course_details_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/cursos/domain/repositories/i_curso_repository.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_matriculado.dart';

class FakeCursoRepository extends Fake implements ICursoRepository {
  List<String> resultadosSimulados = [];

  @override
  Future<List<String>> getCompanerosDeGrupo(String idCat, String nombreGrupo) async {
    return resultadosSimulados;
  }

  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(String email) async {
    return [];
  }
}

class MockEvaluacionController extends GetxController with Mock implements EvaluacionController {
  final _evaluaciones = <EvaluacionEntity>[].obs;
  final _isLoading = false.obs;

  @override
  RxList<EvaluacionEntity> get evaluaciones => _evaluaciones;
  @override
  RxBool get isLoading => _isLoading;

  @override
  Future<void> cargarEvaluaciones(String idCat) async {
  }
}

void main() {
  late FakeCursoRepository fakeRepo;
  late MockEvaluacionController mockEvalController;

  const tIdCat = "cat_123";
  const tGroupName = "Grupo de Prueba";

  final grupoMock = NavigationData(
      idCat: tIdCat,
      grupoNombre: tGroupName
  );

  setUp(() {
    Get.testMode = true;

    fakeRepo = FakeCursoRepository();
    mockEvalController = MockEvaluacionController();

    Get.put<ICursoRepository>(fakeRepo);
    Get.put<EvaluacionController>(mockEvalController);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('GroupDetailsPage Widget Tests', () {

    testWidgets('Debe mostrar la lista de compañeros correctamente cuando hay datos', (WidgetTester tester) async {
      fakeRepo.resultadosSimulados = [
        "marcus@ingenieria.com",
        "estudiante.prueba@u.com"
      ];

      await tester.pumpWidget(GetMaterialApp(
        home: GroupDetailsPage(grupo: grupoMock, cursoMatriculado: null,),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 5. Verificaciones
      expect(find.text("marcus@ingenieria.com"), findsOneWidget);
      expect(find.text("estudiante.prueba@u.com"), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNWidgets(2));
    });

    testWidgets('Debe mostrar el estado vacío si el repositorio no devuelve compañeros', (WidgetTester tester) async {
      fakeRepo.resultadosSimulados = [];

      await tester.pumpWidget(GetMaterialApp(
        home: GroupDetailsPage(grupo: grupoMock, cursoMatriculado: null,),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('groupDetailsEmptyCompaneros')), findsOneWidget);
      expect(find.text("No hay compañeros asignados."), findsOneWidget);
    });

    testWidgets('Debe mostrar indicador de carga mientras el mapa de carga es true', (WidgetTester tester) async {
      final controller = Get.put(StudentCourseDetailsController(cursoRepository: fakeRepo));

      controller.isLoadingCategoria[tIdCat] = true;

      await tester.pumpWidget(GetMaterialApp(
        home: GroupDetailsPage(grupo: grupoMock, cursoMatriculado: null,),
      ));

      expect(find.byKey(const Key('groupDetailsLoadingCompaneros')), findsOneWidget);
    });
  });
}

class NavigationData {
  final String idCat;
  final String grupoNombre;
  NavigationData({required this.idCat, required this.grupoNombre});
}