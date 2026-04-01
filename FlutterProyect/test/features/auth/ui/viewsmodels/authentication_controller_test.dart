import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';

// Importa tus archivos
import 'package:flutter_prueba/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_prueba/features/auth/ui/viewsmodels/authentication_controller.dart';
import 'package:flutter_prueba/features/auth/domain/entities/authentication_user.dart';
import 'package:flutter_prueba/features/shared/domain/services/i_notification_service.dart';


// Generar el Mock
@GenerateMocks([IAuthRepository, INotificationService])
import 'authentication_controller_test.mocks.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthenticationController controller;
  late MockIAuthRepository mockRepository;
  late MockINotificationService mockNotification;

  setUp(() {
    mockRepository = MockIAuthRepository();
    mockNotification = MockINotificationService();

    controller = AuthenticationController(
      repository: mockRepository,
      notificationService: mockNotification,
    );
  });

  group('SignUp Tests', () {
    test('Debe cambiar estados correctamente al registrarse con éxito', () async {

      when(mockRepository.signUp(any, any, any))
          .thenAnswer((_) async => true);

      await controller.signUp("test@uninorte.edu.co", "Pass123!", "Marcus");

      expect(controller.isLoading.value, false);
      expect(controller.isRegistering.value, false);
      expect(controller.isWaitingVerification.value, true);
      expect(controller.userEmail.value, "test@uninorte.edu.co");
    });

    test('Debe manejar el error si el signUp falla', () async {
      when(mockRepository.signUp(any, any, any))
          .thenThrow(Exception("Error de red"));

      expect(() => controller.signUp("a@a.com", "123", "N"), throwsException);
      expect(controller.isLoading.value, false);
    });
  });

  group('Login Tests', () {
    test('Debe loguear al usuario y actualizar el estado isLogged', () async {
      // Mock de usuario de retorno
      final tUser = AuthenticationUser(id: "1",email: "test@uninorte.edu.co", rol: "estudiante");

      when(mockRepository.login(any, any)).thenAnswer((_) async => true);
      when(mockRepository.getUsers()).thenAnswer((_) async => [tUser]);
      when(mockRepository.getLoggedUser()).thenAnswer((_) async => tUser);

      await controller.login("test@uninorte.edu.co", "123456");

      expect(controller.isLogged.value, true);
      expect(controller.loggedUser.value, tUser);
      expect(controller.isLoading.value, false);
    });
  });

  group('validateCode', () {
    const tEmail = "marcus@uninorte.edu.co";
    const tPass = "Pass123!";
    const tCode = "123456";
    final tUser = AuthenticationUser(id: "1", email: tEmail, rol: "estudiante");

    test('Debe completar validación y login automático exitosamente', () async {

      controller.userEmail.value = tEmail;

      when(mockRepository.validate(any, any)).thenAnswer((_) async => true);
      when(mockRepository.login(any, any)).thenAnswer((_) async => true);
      when(mockRepository.getUsers()).thenAnswer((_) async => [tUser]);
      when(mockRepository.getLoggedUser()).thenAnswer((_) async => tUser);


      await controller.signUp(tEmail, tPass, "Marcus");
      final result = await controller.validateCode(tEmail, tCode);


      expect(result, true);
      expect(controller.isLogged.value, true);
      expect(controller.loggedUser.value, tUser);
      expect(controller.isWaitingVerification.value, false);


      verify(mockRepository.validate(tEmail, tCode)).called(1);
      verify(mockRepository.login(tEmail, tPass)).called(1);
      verify(mockRepository.getLoggedUser()).called(1);
    });

    test('Debe fallar si la validación es correcta pero el login automático falla', () async {

      await controller.signUp(tEmail, tPass, "Marcus");
      when(mockRepository.validate(tEmail, tCode)).thenAnswer((_) async => true);


      when(mockRepository.login(tEmail, tPass)).thenThrow(Exception("Error en auto-login"));

      expect(() => controller.validateCode(tEmail, tCode), throwsException);
      expect(controller.isLogged.value, false);
      expect(controller.isWaitingVerification.value, true);
    });
  });

}