import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/features/teacher_home/ui/views/teacher_home_page.dart';
import 'package:flutter_prueba/features/cursos/ui/viewsmodels/curso_controller.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';
import 'package:flutter_prueba/features/grupos/ui/viewmodels/grupo_import_controller.dart';
import 'package:flutter_prueba/features/auth/ui/viewsmodels/authentication_controller.dart';
import 'package:flutter_prueba/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_prueba/features/shared/domain/services/i_notification_service.dart';

class MockNotificationService extends Mock implements INotificationService {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class FakeCurso implements CursoCurso {
  @override
  String get id => 'curso_1';

  @override
  String get nombre => 'Programación Móvil';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCursoController extends GetxController implements CursoController {
  @override
  var isLoading = false.obs;

  @override
  var isCreating = false.obs;

  @override
  var cursos = <CursoCurso>[].obs;

  bool crearCursoCalled = false;
  String? lastCodigo;
  String? lastNombre;
  String? deletedCourseId;

  @override
  Future<void> crearCurso(String codigo, String nombre) async {
    crearCursoCalled = true;
    lastCodigo = codigo;
    lastNombre = nombre;
  }

  @override
  Future<void> eliminarCurso(String idCurso) async {
    deletedCourseId = idCurso;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGrupoImportController extends GetxController
    implements GrupoImportController {
  @override
  var isImporting = false.obs;

  @override
  var importProgress = ''.obs;

  String? importedCourseId;
  String? updatedCourseId;

  @override
  Future<void> importarCSV(String idCurso) async {
    importedCourseId = idCurso;
  }

  @override
  Future<void> actualizarCursoConNuevoCSV(String idCurso) async {
    updatedCourseId = idCurso;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthController extends GetxController
    implements AuthenticationController {
  @override
  final notificationService = MockNotificationService();

  @override
  final repository = MockAuthRepository();

  @override
  var isLoading = false.obs;

  @override
  var isRegistering = false.obs;

  @override
  var isWaitingVerification = false.obs;

  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  void goToLogin() {}

  @override
  void goToSignUp() {}

  @override
  Future<void> resendCode() async {}

  @override
  Future<void> signUp(String email, String password, String name) async {}

  @override
  Future<void> login(String email, String password) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeCursoController fakeCursoController;
  late FakeGrupoImportController fakeGrupoController;
  late FakeAuthController fakeAuthController;

  setUp(() {
    Get.testMode = true;
    Get.reset();

    fakeCursoController = FakeCursoController();
    fakeGrupoController = FakeGrupoImportController();
    fakeAuthController = FakeAuthController();

    Get.put<CursoController>(fakeCursoController);
    Get.put<GrupoImportController>(fakeGrupoController);
    Get.put<AuthenticationController>(fakeAuthController);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('TeacherHomePage widget tests', () {
    testWidgets('muestra loading cuando cursos está cargando', (tester) async {
      fakeCursoController.isLoading.value = true;

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra mensaje vacío cuando no hay cursos', (tester) async {
      fakeCursoController.isLoading.value = false;
      fakeCursoController.cursos.clear();

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          "Aún no has creado ningún curso.\nPresiona el botón '+' para empezar.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('muestra cursos cuando existen', (tester) async {
      fakeCursoController.isLoading.value = false;
      fakeCursoController.cursos.assignAll([FakeCurso()]);

      await tester.pumpWidget(
        GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')),
      );

      await tester.pumpAndSettle();

      expect(find.text('Programación Móvil'), findsOneWidget);
      expect(find.text('Mis Cursos'), findsOneWidget);
      expect(find.text('RESUMEN ACADÉMICO'), findsOneWidget);
    });

    testWidgets('abre el bottom sheet al tocar el FAB', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Opciones'), findsOneWidget);
      expect(find.text('Crear curso'), findsOneWidget);
    });

    testWidgets('valida campos requeridos al crear curso', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear curso'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
      await tester.pumpAndSettle();

      expect(find.text('Requerido'), findsNWidgets(2));
    });

    testWidgets('llama crearCurso al enviar el formulario', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear curso'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Prog Móvil');
      await tester.enterText(find.byType(TextFormField).at(1), '202610_1852');

      await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
      await tester.pumpAndSettle();

      expect(fakeCursoController.crearCursoCalled, true);
      expect(fakeCursoController.lastCodigo, '202610_1852');
      expect(fakeCursoController.lastNombre, 'Prog Móvil');
    });

    testWidgets('abre diálogo de logout y llama logout', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')),
      );

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('Cerrar sesión'), findsOneWidget);
      expect(find.text('¿Seguro que quieres cerrar sesión?'), findsOneWidget);

      await tester.tap(find.text('Sí'));
      await tester.pumpAndSettle();

      expect(fakeAuthController.logoutCalled, true);
    });
  });
}
