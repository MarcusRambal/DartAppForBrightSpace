import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/features/student_home/ui/views/student_course_details_page.dart';
import 'package:flutter_prueba/features/cursos/domain/repositories/i_curso_repository.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_matriculado.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';

class FakeCursoRepository extends Fake implements ICursoRepository {
  @override
  Future<List<String>> getCompanerosDeGrupo(String idCat, String nombreGrupo) async => [];

  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(String email) async => [];
}

class MockEvaluacionController extends GetxController with Mock implements EvaluacionController {
  final _evaluaciones = <EvaluacionEntity>[].obs;
  final _isLoading = false.obs;
  final _evaluacionesIncompletas = <EvaluacionEntity>[].obs;

  @override
  RxList<EvaluacionEntity> get evaluaciones => _evaluaciones;
  @override
  RxBool get isLoading => _isLoading;
  @override
  RxList<EvaluacionEntity> get evaluacionesIncompletas => _evaluacionesIncompletas;

  @override
  Future<void> cargarEvaluaciones(String idCat) async {}

  @override
  Future<void> cargarEvaluacionesIncompletasPorGrupos(List<dynamic> grupos) async {}

  @override
  bool estaCompleta(String idEvaluacion) => false;
}

class FakeLocalPreferences extends Fake implements ILocalPreferences {
  @override
  Future<String?> getString(String key) async => "test@test.com";
}

void main() {
  late FakeCursoRepository fakeRepo;

  final cursoSimulado = CursoMatriculado(
    curso: CursoCurso(
      id: "NRC-101",
      nombre: "Ingeniería de Software",
      idProfesor: "PROFE-001",
    ),
    grupos: [
      CategoriaGrupo(
        idCat: "cat_1",
        categoriaNombre: "Proyecto Final",
        grupoNombre: "Grupo Alfa",
      ),
      CategoriaGrupo(
        idCat: "cat_2",
        categoriaNombre: "Laboratorio",
        grupoNombre: "Grupo Beta",
      ),
    ],
  );

  setUp(() {
    Get.testMode = true;
    fakeRepo = FakeCursoRepository();

    Get.put<ICursoRepository>(fakeRepo);
    Get.put<ILocalPreferences>(FakeLocalPreferences());
    Get.put<EvaluacionController>(MockEvaluacionController());
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('StudentCourseDetailsPage Widget Tests', () {

    testWidgets('Debe mostrar la información básica del curso (Nombre y NRC)', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(
        home: StudentCourseDetailsPage(cursoMatriculado: cursoSimulado),
      ));

      expect(find.text("Ingeniería de Software"), findsOneWidget);
      expect(find.text("NRC: NRC-101"), findsOneWidget);
      expect(find.byKey(const Key('studentCourseDetailsHeader')), findsOneWidget);
    });

    testWidgets('Debe listar todos los grupos asignados al curso', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(
        home: StudentCourseDetailsPage(cursoMatriculado: cursoSimulado),
      ));

      expect(find.text("Proyecto Final"), findsOneWidget);
      expect(find.text("Laboratorio"), findsOneWidget);

      expect(find.text("Asignación: Grupo Alfa"), findsOneWidget);
      expect(find.text("Asignación: Grupo Beta"), findsOneWidget);
    });

    testWidgets('Debe navegar a GroupDetailsPage al tocar un grupo', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(
        home: StudentCourseDetailsPage(cursoMatriculado: cursoSimulado),
      ));

      final tileFinder = find.byKey(const Key('groupListTile_cat_1'));
      expect(tileFinder, findsOneWidget);
      
      await tester.tap(tileFinder);
      await tester.pump(); // Inicia la transición
      await tester.pump(const Duration(milliseconds: 500)); // Espera la animación
      
      // Verificamos que llegamos a la página de detalles
      expect(find.text("Detalles del Grupo"), findsOneWidget);
      expect(find.byKey(const Key('groupDetailsScaffold')), findsOneWidget);
    });
  });
}
