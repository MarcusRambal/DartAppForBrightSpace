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
import 'package:flutter_prueba/features/teacher_home/ui/views/teacher_alerts_controller.dart';
import 'package:flutter_prueba/features/auth/domain/entities/authentication_user.dart';

class MockNotificationService extends Mock implements INotificationService {}
class MockAuthRepository extends Mock implements IAuthRepository {}

class FakeCurso implements CursoCurso {
  @override String get id => 'curso_1';
  @override String get nombre => 'Programación Móvil';
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCursoController extends GetxController implements CursoController {
  @override var isLoading = false.obs;
  @override var isCreating = false.obs;
  @override var cursos = <CursoCurso>[].obs;
  
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

  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGrupoImportController extends GetxController implements GrupoImportController {
  @override var isImporting = false.obs;
  @override var importProgress = ''.obs;

  @override
  Future<void> importarCSV(String idCurso) async {}
  @override
  Future<void> actualizarCursoConNuevoCSV(String idCurso) async {}

  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthController extends GetxController implements AuthenticationController {
  @override final notificationService = MockNotificationService();
  @override final repository = MockAuthRepository();
  @override var isLoading = false.obs;
  @override var isRegistering = false.obs;
  @override var isWaitingVerification = false.obs;
  @override var isLogged = true.obs;
  @override var loggedUser = Rxn<AuthenticationUser>();

  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override void goToLogin() {}
  @override void goToSignUp() {}
  @override Future<void> resendCode() async {}
  @override Future<void> signUp(String email, String password, String name) async {}
  @override Future<void> login(String email, String password) async {}
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTeacherAlertsController extends GetxController implements TeacherAlertsController {
  @override var isLoading = false.obs;
  @override var cantidadAlertas = 0.obs;
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeCursoController fakeCursoController;
  late FakeGrupoImportController fakeGrupoController;
  late FakeAuthController fakeAuthController;
  late FakeTeacherAlertsController fakeAlertsController;

  setUp(() {
    Get.testMode = true;
    Get.reset();

    fakeCursoController = FakeCursoController();
    fakeGrupoController = FakeGrupoImportController();
    fakeAuthController = FakeAuthController();
    fakeAlertsController = FakeTeacherAlertsController();

    Get.put<CursoController>(fakeCursoController);
    Get.put<GrupoImportController>(fakeGrupoController);
    Get.put<AuthenticationController>(fakeAuthController);
    Get.put<TeacherAlertsController>(fakeAlertsController);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('TeacherHomePage widget tests', () {
    testWidgets('muestra loading cuando cursos está cargando', (tester) async {
      fakeCursoController.isLoading.value = true;
      await tester.pumpWidget(GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')));
      expect(find.byKey(const Key('teacherHomeLoadingIndicator')), findsOneWidget);
    });

    testWidgets('muestra mensaje vacío cuando no hay cursos', (tester) async {
      fakeCursoController.isLoading.value = false;
      fakeCursoController.cursos.clear();
      await tester.pumpWidget(GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')));
      await tester.pump();
      expect(find.text("Aún no has creado ningún curso.\nPresiona el botón '+' para empezar."), findsOneWidget);
    });

    testWidgets('muestra cursos cuando existen', (tester) async {
      fakeCursoController.isLoading.value = false;
      fakeCursoController.cursos.assignAll([FakeCurso()]);
      await tester.pumpWidget(GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')));
      await tester.pump();
      expect(find.text('Programación Móvil'), findsOneWidget);
      expect(find.text('Mis Cursos'), findsOneWidget);
    });

    testWidgets('abre el bottom sheet al tocar el FAB', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Opciones'), findsOneWidget);
      expect(find.text('Crear curso'), findsOneWidget);
    });

    testWidgets('abre diálogo de logout y llama logout', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: TeacherHomePage(email: 'teacher@uninorte.edu.co')));
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      expect(find.text('Cerrar sesión'), findsOneWidget);
      
      final confirmButton = find.byKey(const Key('logoutConfirmButton'));
      expect(confirmButton, findsOneWidget);
      
      await tester.tap(confirmButton);
      await tester.pump();
      expect(fakeAuthController.logoutCalled, true);
    });
  });
}
