import 'package:flutter/material.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_prueba/test_helpers/fake_authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_prueba/main.dart' as app;
import 'package:flutter_prueba/test_helpers/fake_local_preferences.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  void setupFakes({required String id, required String role, required String email}) {
    Get.reset();
    Get.put<IAuthRepository>(
        FakeAuthenticationRepository(id: id, role: role, email: email),
        permanent: true
    );
    final fakePrefs = FakeLocalPreferences();
    fakePrefs.injectToken("fake_token_valido");
    Get.put<ILocalPreferences>(fakePrefs, permanent: true);
  }
  group('Pruebas de Flujo desde login hasta hacer evaluaciones desde usuario de estudiante', () {
    testWidgets('Validar inicio de sesión, carga de cursos y clic en curso', (tester) async {
      setupFakes(id: 'bce0313f-611a-43b8-9e6d-23b5e7fe3f18', role: 'estudiante', email: 'mpreston@uninorte.edu.co');
      app.main();

      await tester.pumpAndSettle();

      const String testEmail = 'mpreston@uninorte.edu.co';
      const String testPass = 'ThePassword!1.';


      // 1. LOGIN
      final emailField = find.byKey(const Key('loginEmailField'));
      final passwordField = find.byKey(const Key('loginPasswordField'));
      final loginButton = find.byKey(const Key('loginSubmitButton'));

      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPass);
      await tester.tap(loginButton);

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('studentHomeScaffold')), findsOneWidget);

      // 2. ESPERAR CARGA DE CURSOS
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('studentHomeLoadingIndicator')), findsNothing);

      // 3. CLIC EN EL CURSO
      final courseFinder = find.byKey(const Key('courseCardContainer_202610_1852'));
      expect(courseFinder, findsOneWidget);
      await tester.tap(courseFinder);

      // Esperar a que la navegación ocurra
      await tester.pumpAndSettle();

      // 4. VERIFICAR NAVEGACIÓN Y ESPERAR CONTENIDO
      final detailsHeader = find.byKey(const Key('studentCourseDetailsHeader'));
      expect(detailsHeader, findsOneWidget);
      expect(find.byKey(const Key('studentCourseDetailsScaffold')), findsOneWidget);

      // --- NUEVO: CLIC EN EL GRUPO "CategoríaPyFlutter" ---
      // Usamos el ID que pusiste en el Fake para CategoriaPyFlutter: "1774449735424"
      final groupFinder = find.byKey(const Key('groupListTile_1774449735424'));

      expect(groupFinder, findsOneWidget);
      await tester.tap(groupFinder);

      // Esperar la navegación a la pantalla de detalle del grupo
      await tester.pumpAndSettle();

      // 5. VERIFICAR QUE ESTAMOS EN LA PANTALLA DE GRUPO
      // Aquí verificas que el título o algún componente de la nueva pantalla existe
      expect(find.byKey(const Key('groupDetailsScaffold')), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Validar inicio de sesión de profesro', (tester) async {
      
      setupFakes(id: 'f66b8ad3-9e8e-49ac-a745-573206f64466', role: 'profesor', email: 'augustosalazar@uninorte.edu.co');
      app.main();

      await tester.pumpAndSettle();

      const String testEmail = 'augustosalazar@uninorte.edu.co';
      const String testPass = 'ThePassword!1.';


      // 1. LOGIN
      final emailField = find.byKey(const Key('loginEmailField'));
      final passwordField = find.byKey(const Key('loginPasswordField'));
      final loginButton = find.byKey(const Key('loginSubmitButton'));

      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPass);
      await tester.tap(loginButton);

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('teacherHomeScaffold')), findsOneWidget);

      // 1. Abrir el menú de opciones (BottomSheet)
      await tester.tap(find.byKey(const Key('teacherHomeFAB')));
      await tester.pumpAndSettle();

// 2. Seleccionar "Crear curso"
      await tester.tap(find.byKey(const Key('teacherCreateCourseOption')));
      await tester.pumpAndSettle();

// 3. Escribir en el formulario
      final nameField = find.byKey(const Key('createCourseNameField'));
      final codeField = find.byKey(const Key('createCourseCodeField'));
      final submitButton = find.byKey(const Key('createCourseSubmitButton'));
      await tester.pumpAndSettle();

      await tester.enterText(nameField, "Movil");
      await tester.enterText(codeField, "202610_1852");
      await tester.pumpAndSettle();

// 4. Guardar
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
// 5. Verificación crítica:
// Si el curso se creó, el diálogo debería cerrarse y el nuevo curso debería estar en la lista
      expect(find.byKey(const Key('createCourseDialog')), findsNothing);
      expect(find.text("Movil"), findsOneWidget);

      // 6. CLIC EN EL CURSO CREADO
      final courseCardFinder = find.byKey(const Key('teacherCourseGesture_202610_1852'));
      expect(courseCardFinder, findsOneWidget);
      await tester.tap(courseCardFinder);

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('teacherCourseDetailsScaffold')), findsOneWidget);
      await tester.pumpAndSettle();

      // 7. ABRIR DIÁLOGO DE CREAR EVALUACIÓN
      // Asegúrate de que el FAB en la pantalla de detalles tenga este Key
      final fabDetalles = find.byKey(const Key('teacherCourseDetailsFAB'));
      expect(fabDetalles, findsOneWidget);
      await tester.tap(fabDetalles);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('newEvaluationDialog')), findsOneWidget);

      // 8. LLENAR FORMULARIO DE EVALUACIÓN
// Seleccionar Categoría
      await tester.tap(find.byKey(const Key('newEvaluationCategoryDropdown')));
      await tester.pumpAndSettle();
// Asegúrate de que el texto coincida exactamente con lo que devuelve tu Fake
      await tester.tap(find.text('CategoríaPyFlutter').last);
      await tester.pumpAndSettle();

// Nombre
      await tester.enterText(find.byKey(const Key('newEvaluationNameField')), "Examen Final de Flutter");
      await tester.pumpAndSettle();

// FECHAS (Ahora son inmediatas gracias al cambio en el onTap)
      await tester.tap(find.byKey(const Key('newEvaluationStartDateField')));
      await tester.pumpAndSettle(); // Aquí el controller se llena solo

      await tester.tap(find.byKey(const Key('newEvaluationEndDateField')));
      await tester.pumpAndSettle(); // Aquí el controller se llena solo

// El botón de Guardar ya debería estar visible y habilitado
      final submitButtonFinder = find.byKey(const Key('newEvaluationSubmitButton'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('CategoríaPyFlutter'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('teacherGroupDetailsScaffold')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
    });

  });
}