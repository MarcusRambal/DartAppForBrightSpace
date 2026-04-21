import 'package:flutter/material.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_prueba/features/reportes/data/dataSources/i_reporte_source.dart';
import 'package:flutter_prueba/test_helpers/fake_authentication_repository.dart';
import 'package:flutter_prueba/test_helpers/fake_http_client.dart';
import 'package:flutter_prueba/test_helpers/fake_report_sources.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:flutter_prueba/main.dart' as app;
import 'package:flutter_prueba/test_helpers/fake_local_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() async {
    Get.reset();
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });

  void setupFakes({
    required String id,
    required String role,
    required String email,
  }) {
    Get.reset();
    Get.put<IAuthRepository>(
      FakeAuthenticationRepository(id: id, role: role, email: email),
      permanent: true,
    );
    final fakePrefs = FakeLocalPreferences();
    fakePrefs.injectToken("fake_token_valido");
    Get.put<ILocalPreferences>(fakePrefs, permanent: true);
    Get.put<IReporteSource>(FakeReporteSource(), permanent: true);
  }

  void setupFakeApi() {
    Get.put<http.Client>(MockApiCliente(), tag: 'apiClient', permanent: true);
  }

  group(
    'Pruebas de Flujo desde login hasta hacer evaluaciones desde usuario de estudiante',
    () {
      testWidgets('Validar inicio de sesión de profesor', (tester) async {
        setupFakes(
          id: 'f66b8ad3-9e8e-49ac-a745-573206f64466',
          role: 'profesor',
          email: 'augustosalazar@uninorte.edu.co',
        );
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
        final courseCardFinder = find.byKey(
          const Key('teacherCourseGesture_202610_1852'),
        );
        expect(courseCardFinder, findsOneWidget);
        await tester.tap(courseCardFinder);

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('teacherCourseDetailsScaffold')),
          findsOneWidget,
        );
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
        await tester.tap(
          find.byKey(const Key('newEvaluationCategoryDropdown')),
        );
        await tester.pumpAndSettle();
        // Asegúrate de que el texto coincida exactamente con lo que devuelve tu Fake
        await tester.tap(find.text('CategoríaPyFlutter').last);
        await tester.pumpAndSettle();

        // Nombre
        await tester.enterText(
          find.byKey(const Key('newEvaluationNameField')),
          "Examen Final de Flutter",
        );
        await tester.pumpAndSettle();

        // FECHAS (Ahora son inmediatas gracias al cambio en el onTap)
        await tester.tap(find.byKey(const Key('newEvaluationStartDateField')));
        await tester.pumpAndSettle(); // Aquí el controller se llena solo

        await tester.tap(find.byKey(const Key('newEvaluationEndDateField')));
        await tester.pumpAndSettle(); // Aquí el controller se llena solo

        // El botón de Guardar ya debería estar visible y habilitado
        final submitButtonFinder = find.byKey(
          const Key('newEvaluationSubmitButton'),
        );
        await tester.tap(submitButtonFinder);
        await tester.pumpAndSettle();

        await tester.tap(find.text('CategoríaPyFlutter'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('teacherGroupDetailsScaffold')),
          findsOneWidget,
        );
        final groupKey = Key('teacherGroupExpansion_Grupo 3');

        await tester.tap(find.byKey(groupKey));

        await tester.pumpAndSettle();

        final String evalId = '1775164724851';
        // 2. Tap en cambiar privacidad
        final privButton = find.byKey(Key('evalPrivacidadButton_$evalId'));
        await tester.tap(privButton);
        await tester.pumpAndSettle(); // Espera a que el estado se actualice

        // 3. Verificación (Opcional): Verifica que cambió el estado (por ejemplo, el icono o texto)
        // expect(find.text('Pública'), findsOneWidget);

        // 4. Tap en resultados
        final resButton = find.byKey(Key('evalResultadosButton_$evalId'));
        await tester.tap(resButton);
        await tester.pumpAndSettle();

        // 2. Verificar que el Scaffold cargó
        expect(find.byKey(const Key('teacherReportScaffold')), findsOneWidget);

        // 3. Esperar a que el CircularProgressIndicator desaparezca (cargando datos)
        // Usamos pumpAndSettle para esperar a que la red (Fake) responda
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 4. Verificar que el promedio general aparece
        expect(
          find.byKey(const Key('teacherReportGeneralAverageText')),
          findsOneWidget,
        );

        // 5. Expandir un grupo para ver a los estudiantes
        // Aquí usamos la key que definiste en tu código: 'teacherReportGroupExpansion_$nombreGrupo'
        final groupKeyReport = Key('teacherReportGroupExpansion_Grupo 3');
        await tester.tap(find.byKey(groupKeyReport));
        await tester.pumpAndSettle();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('teacherGroupDetailsScaffold')),
          findsOneWidget,
        );

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('teacherCourseDetailsScaffold')),
          findsOneWidget,
        );
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('teacherHomeScaffold')), findsOneWidget);

        final alertsButton = find.byKey(const Key('teacherHomeAlertsGesture'));

        await tester.tap(alertsButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('teacherAlertsScaffold')), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 3000));

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('teacherHomeScaffold')), findsOneWidget);
        await tester.pumpAndSettle();

        final deleteFinder = find.byKey(
          Key('teacherCourseDeleteButton_202610_1852'),
        );
        await tester.tap(deleteFinder);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Sí, borrar"));
        await tester.pumpAndSettle();

        await tester.pumpAndSettle(const Duration(seconds: 3));
        final logoutBtn = find.byKey(const Key('teacherHomeLogoutButton'));

        await tester.ensureVisible(logoutBtn);
        await tester.tap(logoutBtn);
        await tester.pumpAndSettle();

        final confirmBtn = find.byKey(const Key('logoutConfirmButton'));

        expect(confirmBtn, findsOneWidget);

        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        await tester.pump(const Duration(milliseconds: 6000));
      });
      testWidgets(
        'Login, navegar cursos/grupo, evaluar a un compañero y cerrar sesión',
        (tester) async {
          setupFakes(
            id: 'bce0313f-611a-43b8-9e6d-23b5e7fe3f18',
            role: 'estudiante',
            email: 'mpreston@uninorte.edu.co',
          );
          final fakePrefs =
              Get.find<ILocalPreferences>() as FakeLocalPreferences;
          fakePrefs.injectEmail('mpreston@uninorte.edu.co');
          fakePrefs.injectUserId('bce0313f-611a-43b8-9e6d-23b5e7fe3f18');

          app.main();
          await tester.pumpAndSettle();

          // ── 1. LOGIN ──────────────────────────────────────────────────────
          await tester.enterText(
            find.byKey(const Key('loginEmailField')),
            'mpreston@uninorte.edu.co',
          );
          await tester.enterText(
            find.byKey(const Key('loginPasswordField')),
            'ThePassword!1.',
          );
          await tester.tap(find.byKey(const Key('loginSubmitButton')));
          await tester.pumpAndSettle();

          // ── 2. STUDENT HOME ───────────────────────────────────────────────
          expect(find.byKey(const Key('studentHomeScaffold')), findsOneWidget);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('studentHomeLoadingIndicator')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('courseCardContainer_202610_1852')),
            findsOneWidget,
          );

          // ── 3. ENTRAR AL CURSO ────────────────────────────────────────────
          await tester.tap(
            find.byKey(const Key('courseCardContainer_202610_1852')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('studentCourseDetailsScaffold')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('studentCourseDetailsHeader')),
            findsOneWidget,
          );

          // ── 4. ENTRAR AL GRUPO ────────────────────────────────────────────
          final groupTile = find.byKey(
            const Key('groupListTile_1774449735424'),
          );
          expect(groupTile, findsOneWidget);
          await tester.tap(groupTile);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(find.byKey(const Key('groupDetailsScaffold')), findsOneWidget);

          // ── 5. VERIFICAR EVALUACIÓN VIGENTE ──────────────────────────────
          expect(
            find.byKey(const Key('evaluationCard_1775164724851')),
            findsOneWidget,
          );

          // ── 6. ABRIR DETALLE DE LA EVALUACIÓN ────────────────────────────
          await tester.tap(
            find.byKey(const Key('evaluationCard_1775164724851')),
          );
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.text('gmrey@uninorte.edu.co'), findsOneWidget);

          // ── 7. TAP EN "Evaluar" ───────────────────────────────────────────
          final evalButton = find.widgetWithText(ElevatedButton, 'Evaluar');
          expect(evalButton, findsWidgets);
          await tester.tap(evalButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // ── 8. RESPONDER LAS 4 PREGUNTAS ─────────────────────────────────
          for (int i = 0; i < 4; i++) {
            expect(find.textContaining('¿'), findsOneWidget);
            final excelente = find.widgetWithText(
              ElevatedButton,
              'Excelente (5)',
            );
            expect(excelente, findsOneWidget);
            await tester.tap(excelente);
            await tester.pumpAndSettle();
          }

          // ── 9. FINALIZAR LA EVALUACIÓN ────────────────────────────────────
          final finalizarBtn = find.widgetWithText(
            ElevatedButton,
            'Finalizar evaluación',
          );
          expect(finalizarBtn, findsOneWidget);
          await tester.tap(finalizarBtn);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.textContaining('Excelente'), findsNothing);

          // ── 10. VOLVER AL STUDENT HOME ────────────────────────────────────
          await tester.pageBack();
          await tester.pumpAndSettle();

          await tester.pageBack();
          await tester.pumpAndSettle();

          await tester.pageBack();
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('studentHomeScaffold')), findsOneWidget);

          // ── 11. LOGOUT ────────────────────────────────────────────────────
          await tester.tap(find.byKey(const Key('studentHomeLogoutButton')));
          await tester.pumpAndSettle();

          expect(find.text('Sí'), findsOneWidget);
          await tester.tap(find.text('Sí'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
        },
      );
    },
  );
}
