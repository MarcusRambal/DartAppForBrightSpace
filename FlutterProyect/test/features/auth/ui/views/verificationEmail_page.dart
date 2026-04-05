import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';


import 'package:flutter_prueba/features/auth/ui/views/verificationEmail_page.dart';
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

  @override var userEmail = "test@uninorte.edu.co".obs;

  bool validateCalled = false;
  bool resendCalled = false;
  bool goToSignUpCalled = false;

  @override
  Future<bool> validateCode(String email, String code) async {
    validateCalled = true;
    return true;
  }

  @override
  Future<void> resendCode() async {
    resendCalled = true;
    return;
  }

  @override
  void goToSignUp() => goToSignUpCalled = true;

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

  group('Widget VerificationPage Tests', () {

    testWidgets('Debe mostrar el email del usuario correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: VerificationPage()));

      expect(find.textContaining('test@uninorte.edu.co'), findsOneWidget);
    });

    testWidgets('Validación local: código menor a 6 caracteres', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: VerificationPage()));

      await tester.enterText(find.byKey(const Key('verificationCodeField')), '123');
      await tester.tap(find.byKey(const Key('verificationSubmitButton')));
      await tester.pump();

      expect(mockController.validateCalled, false);
    });

    testWidgets('Llamada exitosa a validateCode', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: VerificationPage()));

      await tester.enterText(find.byKey(const Key('verificationCodeField')), '123456');
      await tester.tap(find.byKey(const Key('verificationSubmitButton')));
      await tester.pump();

      expect(mockController.validateCalled, true);
    });

    testWidgets('Debe llamar a reenviar código', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: VerificationPage()));

      final resendBtn = find.byKey(const Key('verificationResendButton'));

      await tester.ensureVisible(resendBtn);
      await tester.tap(resendBtn);
      await tester.pump();

      expect(mockController.resendCalled, true);
    });

    testWidgets('Debe mostrar Loading cuando el controlador está cargando', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: VerificationPage()));

      mockController.isLoading.value = true;
      await tester.pump();


      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('verificationSubmitButton')), findsNothing);
    });

    testWidgets('Navegación: Volver al registro', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: VerificationPage()));

      final backBtn = find.byKey(const Key('verificationBackButton'));

      await tester.ensureVisible(backBtn);
      await tester.tap(backBtn);
      await tester.pump();

      expect(mockController.goToSignUpCalled, true);
    });
  });
}