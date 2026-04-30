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
import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';

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
  final _incompletas = <EvaluacionEntity>[].obs;

  @override RxList<EvaluacionEntity> get evaluaciones => _evaluaciones;
  @override RxBool get isLoading => _isLoading;
  @override RxList<EvaluacionEntity> get evaluacionesIncompletas => _incompletas;

  @override Future<void> cargarEvaluaciones(String idCat) async {}
  @override Future<void> cargarEvaluacionesIncompletasPorGrupos(List<dynamic> grupos) async {}
  @override bool estaCompleta(String idEvaluacion) => false;
}

class FakeLocalPreferences extends Fake implements ILocalPreferences {
  @override
  Future<String?> getString(String key) async => "test@uninorte.edu.co";
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

  final cursoMatriculadoMock = CursoMatriculado(
    curso: CursoCurso(id: "NRC-1", nombre: "Curso de Prueba", idProfesor: "P1"),
    grupos: [],
  );

  setUp(() {
    Get.testMode = true;
    Get.reset();

    fakeRepo = FakeCursoRepository();
    mockEvalController = MockEvaluacionController();

    Get.put<ICursoRepository>(fakeRepo);
    Get.put<EvaluacionController>(mockEvalController);
    Get.put<ILocalPreferences>(FakeLocalPreferences());
    
    Get.put(StudentCourseDetailsController(cursoRepository: fakeRepo));
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('GroupDetailsPage Widget Tests', () {

    testWidgets('Debe mostrar la lista de compañeros correctamente cuando hay datos', (WidgetTester tester) async {
      fakeRepo.resultadosSimulados = [
        "marcus@ingenieria.com",
      ];

      await tester.pumpWidget(GetMaterialApp(
        home: GroupDetailsPage(
          grupo: grupoMock, 
          cursoMatriculado: cursoMatriculadoMock,
        ),
      ));

      // 1. Esperamos a que el loading inicial de la pantalla termine
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text("marcus@ingenieria.com"), findsOneWidget);
    });

    testWidgets('Debe mostrar el estado vacío si el repositorio no devuelve compañeros', (WidgetTester tester) async {
      fakeRepo.resultadosSimulados = [];

      await tester.pumpWidget(GetMaterialApp(
        home: GroupDetailsPage(
          grupo: grupoMock, 
          cursoMatriculado: cursoMatriculadoMock,
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('groupDetailsEmptyCompaneros')), findsOneWidget);
      expect(find.text("No hay compañeros asignados."), findsOneWidget);
    });

    testWidgets('Debe mostrar indicador de carga mientras el mapa de carga es true', (WidgetTester tester) async {
      final controller = Get.find<StudentCourseDetailsController>();

      await tester.pumpWidget(GetMaterialApp(
        home: GroupDetailsPage(
          grupo: grupoMock, 
          cursoMatriculado: cursoMatriculadoMock,
        ),
      ));

      // Pasamos el loading inicial de la pantalla
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100));

      // Activamos el loading específico de la categoría
      controller.isLoadingCategoria[tIdCat] = true;
      await tester.pump(); // Reconstruimos para ver el Obx

      expect(find.byKey(const Key('groupDetailsObxLoadingIndicator')), findsOneWidget);
    });
  });
}

class NavigationData {
  final String idCat;
  final String grupoNombre;
  NavigationData({required this.idCat, required this.grupoNombre});
}
