import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';


import 'package:flutter_prueba/features/student_home/ui/views/student_home_page.dart';
import 'package:flutter_prueba/features/auth/ui/viewsmodels/authentication_controller.dart';
import 'package:flutter_prueba/features/cursos/domain/repositories/i_curso_repository.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_matriculado.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';

class FakeCursoRepository extends Fake implements ICursoRepository {
  List<CursoMatriculado> cursosSimulados = [];

  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(String email) async {
    return cursosSimulados;
  }
}

class MockAuthController extends GetxController implements AuthenticationController {
  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    return;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeCursoRepository fakeRepo;
  late MockAuthController mockAuth;
  const tEmail = "marcus@uninorte.edu.co";

  // Datos de prueba: Un curso con sus grupos
  final cursoMock = CursoMatriculado(
    curso: CursoCurso(
      id: "NRC-5555",
      nombre: "Diseño de Sistemas",
      idProfesor: "P123",
    ),
    grupos: [
      CategoriaGrupo(
        idCat: "cat_proj",
        categoriaNombre: "Proyecto",
        grupoNombre: "Grupo 04",
      ),
    ],
  );

  setUp(() {
    Get.testMode = true;
    fakeRepo = FakeCursoRepository();
    mockAuth = MockAuthController();

    Get.put<ICursoRepository>(fakeRepo);
    Get.put<AuthenticationController>(mockAuth);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('StudentHomePage Widget Tests', () {

    testWidgets('Debe mostrar indicador de carga mientras busca los cursos', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(
        home: StudentHomePage(email: tEmail),
      ));

      expect(find.byKey(const Key('studentHomeLoadingIndicator')), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje de lista vacía si no hay cursos', (WidgetTester tester) async {
      fakeRepo.cursosSimulados = []; // Aseguramos lista vacía

      await tester.pumpWidget(GetMaterialApp(
        home: StudentHomePage(email: tEmail),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Aún no estás inscrito en ningún curso.'), findsOneWidget);
      expect(find.byKey(const Key('studentHomeEmptyIcon')), findsOneWidget);
    });

    testWidgets('Debe listar los cursos correctamente cuando el repo devuelve datos', (WidgetTester tester) async {
      fakeRepo.cursosSimulados = [cursoMock];

      await tester.pumpWidget(GetMaterialApp(
        home: StudentHomePage(email: tEmail),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text("Diseño de Sistemas"), findsOneWidget);
      expect(find.text("NRC: NRC-5555"), findsOneWidget);

      expect(find.text("Proyecto: "), findsOneWidget);
      expect(find.text("Grupo 04"), findsOneWidget);
    });

    testWidgets('Debe mostrar el diálogo de confirmación al presionar Logout', (WidgetTester tester) async {
      fakeRepo.cursosSimulados = [];

      await tester.pumpWidget(GetMaterialApp(
        home: StudentHomePage(email: tEmail),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('studentHomeLogoutButton')));
      await tester.pump();

      expect(find.text("Cerrar sesión"), findsOneWidget);

      await tester.tap(find.text("Sí"));

      await tester.pumpAndSettle();

      expect(mockAuth.logoutCalled, isTrue);
    });
  });
}