import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

// Importaciones según tu proyecto
import 'package:flutter_prueba/features/auth/ui/views/signup_page.dart';
import 'package:flutter_prueba/features/auth/ui/viewsmodels/authentication_controller.dart';
import 'package:flutter_prueba/features/shared/domain/services/i_notification_service.dart';
import 'package:flutter_prueba/features/auth/domain/repositories/i_auth_repository.dart';

// --- MOCK CONTROLADOR ---
class MockNotificationService extends Mock implements INotificationService {}
class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAuthControl extends GetxController implements AuthenticationController {
  @override final notificationService = MockNotificationService();
  @override final repository = MockAuthRepository();
  @override var isLoading = false.obs;
  @override var isRegistering = false.obs;
  @override var isWaitingVerification = false.obs;

  bool signUpCalled = false;
  bool goToLoginCalled = false;
  String? lastEmail;

  @override
  Future<void> signUp(String email, String password, dynamic name) async {
    signUpCalled = true;
    lastEmail = email;
  }

  @override void goToLogin() => goToLoginCalled = true;

  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  group('Widget SignUpPage Tests', () {

    testWidgets('Widget signUp validación campo vacio nombre', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SignUpPage()));

      await tester.tap(find.byKey(const Key('signUpSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('Widget signUp validación email @', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SignUpPage()));

      await tester.enterText(find.byKey(const Key('signUpNameField')), 'Marcus');
      await tester.enterText(find.byKey(const Key('signUpEmailField')), 'correo_sin_arroba');

      await tester.tap(find.byKey(const Key('signUpSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter valid email'), findsOneWidget);
    });

    testWidgets('Widget signUp validación password corto', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SignUpPage()));

      await tester.enterText(find.byKey(const Key('signUpPasswordField')), '123');

      await tester.tap(find.byKey(const Key('signUpSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Password must have at least 6 characters'), findsOneWidget);
    });

    testWidgets('Widget signUp registro exitoso', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SignUpPage()));

      // Usamos las llaves que definiste
      await tester.enterText(find.byKey(const Key('signUpNameField')), "Marcus");
      await tester.enterText(find.byKey(const Key('signUpEmailField')), "marcus@uninorte.edu.co");
      await tester.enterText(find.byKey(const Key('signUpPasswordField')), "123456");

      await tester.tap(find.byKey(const Key('signUpSubmitButton')));
      await tester.pump();

      expect(mockController.signUpCalled, true);
      expect(mockController.lastEmail, "marcus@uninorte.edu.co");
    });

    testWidgets('Widget signUp navegación back to login', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SignUpPage()));

      final backButton = find.byKey(const Key('signUpBackToLoginButton'));

      await tester.ensureVisible(backButton);
      await tester.pumpAndSettle();

      await tester.tap(backButton);
      await tester.pump();

      expect(mockController.goToLoginCalled, true);
    });
  });
}