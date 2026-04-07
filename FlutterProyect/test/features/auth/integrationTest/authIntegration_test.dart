import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:flutter_prueba/features/auth/ui/views/login_page.dart';
import 'package:flutter_prueba/features/auth/ui/viewsmodels/authentication_controller.dart';
import 'package:flutter_prueba/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_prueba/features/auth/data/dataSources/authentication_source_service.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/shared/domain/services/i_notification_service.dart';

class FakeHttpClient extends Fake implements http.Client {
  @override
  Future<http.Response> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
        Object? encoding,
      }) async {
    if (url.path.contains('/login')) {
      return http.Response(jsonEncode({
        'accessToken': 'token_abc',
        'refreshToken': 'token_def',
        'user': {'id': "999", 'email': 'mpreston@uninorte.edu.co'}
      }), 201);
    }

    if (body != null && body.toString().contains('error@test.com')) {
      return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
    }

    // Lógica para agregar usuario
    if (url.path.contains('/insert')) {
      return http.Response(jsonEncode({'status': 'ok'}), 201);
    }

    return http.Response(jsonEncode({}), 200);
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response(jsonEncode([
      {
        "userId": "999",
        "email": "mpreston@uninorte.edu.co",
        "rol": "estudiante"
      }
    ]), 200, headers: {'content-type': 'application/json; charset=UTF-8'});
  }
}
class MockNotificationService extends Mock implements INotificationService {}
class FakePreferences extends Fake implements ILocalPreferences {
  @override
  Future<bool> setString(String k, String v) async => true;

  @override
  Future<String?> getString(String k) async {
    if (k == 'token') return "token_abc";
    if (k == 'userId') return "999";
    return "";
  }
}
void main() {
  provideDummy<Uri>(Uri.parse('https://dummy.com'));
  late FakeHttpClient mockClient;
  late MockNotificationService mockNotification;
  late AuthenticationController authController;

  const testContract = "PROYECTO_TEST_123";
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    dotenv.env['EXPO_PUBLIC_ROBLE_PROJECT_ID'] = testContract;
  });
  setUp(() {
    Get.testMode = true;
    Get.deleteAll(force: true);

    final fakeClient = FakeHttpClient();
    mockNotification = MockNotificationService();

    Get.put<ILocalPreferences>(FakePreferences());


    final dataSource = AuthenticationSourceServiceRoble(client: fakeClient);
    final repository = AuthRepository(dataSource);

    authController = AuthenticationController(
      repository: repository,
      notificationService: mockNotification,
    );

    Get.put(authController);
  });
  testWidgets('Integración Login: Flujo completo hasta éxito', (WidgetTester tester) async {

    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

    await tester.enterText(find.byKey(const Key('loginEmailField')), "mpreston@uninorte.edu.co");
    await tester.enterText(find.byKey(const Key('loginPasswordField')), "ThePassword!1.");
    await tester.tap(find.byKey(const Key('loginSubmitButton')));


    await tester.pump(Duration(milliseconds: 500));
    await tester.pumpAndSettle();


    expect(authController.isLogged.value, isTrue);
    expect(authController.loggedUser.value?.email, "mpreston@uninorte.edu.co");

  });

  testWidgets('Login fallido: Credenciales incorrectas', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));

    await tester.enterText(find.byKey(const Key('loginEmailField')), "test@error.com");
    await tester.enterText(find.byKey(const Key('loginPasswordField')), "error");
    await tester.tap(find.byKey(const Key('loginSubmitButton')));

    await tester.pumpAndSettle();

    expect(authController.isLogged.value, isFalse);
  });
}

