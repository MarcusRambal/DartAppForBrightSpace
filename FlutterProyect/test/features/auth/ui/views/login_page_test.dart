import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';


import 'package:flutter_prueba/features/auth/ui/views/login_page.dart';
import 'package:flutter_prueba/features/auth/ui/viewsmodels/authentication_controller.dart';
import 'package:flutter_prueba/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_prueba/features/shared/domain/services/i_notification_service.dart';


class MockNotificationService extends Mock implements INotificationService {}
class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAuthControl extends GetxController implements AuthenticationController {
  @override final notificationService = MockNotificationService();
  @override final repository = MockAuthRepository();

  @override var isLoading = false.obs;
  @override var isRegistering = false.obs;
  @override var isWaitingVerification = false.obs;

  bool loginCalled = false;
  String? lastEmail;

  @override
  Future<void> login(String email, String password) async {
    loginCalled = true;
    lastEmail = email;
    return;
  }


  @override void goToLogin() {}
  @override void goToSignUp() {}
  @override Future<void> logout() async {}
  @override Future<void> resendCode() async {}
  @override Future<void> signUp(String email, String password, String name) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAuthControl mockController;

  setUp(() {
    Get.testMode = true;
    mockController = MockAuthControl();
    Get.put<AuthenticationController>(mockController);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('Widget LoginPage Tests (Estilo Uninorte)', () {

    testWidgets('Widget login validación campo vacio email', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

      await tester.enterText(find.byKey(const Key('loginEmailField')), '');

      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('Widget login validación @ email', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

      await tester.enterText(find.byKey(const Key('loginEmailField')), 'correo_sin_arroba');

      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter valid email'), findsOneWidget);
    });

    testWidgets('Widget login validación campo vacio password', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

      await tester.enterText(find.byKey(const Key('loginPasswordField')), '');

      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('Widget login validación número de caracteres password', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

      await tester.enterText(find.byKey(const Key('loginPasswordField')), '123');

      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Password must have at least 6 characters'), findsOneWidget);
    });

    testWidgets('Widget login autenticación exitosa (llamada al controlador)', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

      await tester.enterText(find.byKey(const Key('loginEmailField')), "marcus@uninorte.edu.co");
      await tester.enterText(find.byKey(const Key('loginPasswordField')), "123456");

      await tester.tap(find.byKey(const Key('loginSubmitButton')));

      await tester.pump();

      expect(mockController.loginCalled, true);
      expect(mockController.lastEmail, "marcus@uninorte.edu.co");
    });

    testWidgets('Widget login alternar visibilidad password', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

      final textField = tester.widget<TextField>(
          find.descendant(of: find.byKey(const Key('loginPasswordField')), matching: find.byType(TextField))
      );
      expect(textField.obscureText, true);

      await tester.tap(find.byKey(const Key('loginPasswordVisibilityIcon')));
      await tester.pump();

      final textFieldVisible = tester.widget<TextField>(
          find.descendant(of: find.byKey(const Key('loginPasswordField')), matching: find.byType(TextField))
      );
      expect(textFieldVisible.obscureText, false);
    });
  });
}