//FlutterProyect/lib/features/auth/ui/viewsmodels/authentication_controller.dart
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/entities/authentication_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../../shared/domain/services/i_notification_service.dart';


class AuthenticationController extends GetxController {
  final IAuthRepository repository;
  final INotificationService notificationService;

  AuthenticationController({
    required this.repository,
    required this.notificationService,
  });

  // --- ESTADOS REACTIVOS ---
  var isLogged = false.obs;
  var isWaitingVerification = false.obs;
  var isLoading = false.obs;
  var isRegistering = false.obs;

  var loggedUser = Rxn<AuthenticationUser>();
  var userEmail = ''.obs;
  String? _tempPassword;
  String? _tempName;
  var verificationCode = ''.obs;

  // --- NAVEGACIÓN ---
  void goToSignUp() {
    isWaitingVerification.value = false;
    isRegistering.value = true;
  }

  void goToLogin() {
    isRegistering.value = false;
    isWaitingVerification.value = false;
  }

  // --- SIGNUP ---
  Future<void> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;
      userEmail.value = email;
      _tempPassword = password;
      _tempName = name;

      await repository.signUp(email, password, name);

      isRegistering.value = false;
      isWaitingVerification.value = true;

      notificationService.showInfo("Registro", "Código enviado a $email");
    } catch (e) {
      logError("Error en signUp: $e");
      notificationService.showError("Error", "No se pudo realizar el registro");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // --- VALIDACIÓN DE CÓDIGO ---
  Future<bool> validateCode(String email, String code) async {
    try {
      isLoading.value = true;
      await repository.validate(email, code);

      isWaitingVerification.value = false;

      if (_tempPassword != null) {
        await login(email, _tempPassword!);
      } else {
        goToLogin();
        notificationService.showInfo("Verificado", "Por favor inicia sesión.");
      }

      return true;
    } catch (e) {
      logError("Error en validación: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  // --- LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await repository.login(email, password);

      // Lógica de "Agregar si no existe"
      try {
        final users = await repository.getUsers();
        if (!users.any((u) => u.email == email)) {
          await repository.addUser(email);
          logInfo("Usuario nuevo guardado: $email");
        }
      } catch (e) {
        logWarning("Error no crítico al verificar/agregar usuario: $e");
      }

      loggedUser.value = await repository.getLoggedUser();
      isLogged.value = true;
    } catch (e, stackTrace) { // Añade stackTrace para ver dónde falló el mapeo
      logError("Error en login: $e");
      print("STDOUT ERROR: $e"); // Esto saldrá en la consola de flutter test
      print("STACKTRACE: $stackTrace");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    try {
      isLoading.value = true;
      try {
        await repository.logOut();
      } catch (_) {}

      // Limpiar estados
      isLogged.value = false;
      loggedUser.value = null;
      isRegistering.value = false;
      isWaitingVerification.value = false;

      notificationService.showSuccess("Sesión", "Has cerrado sesión");
    } finally {
      isLoading.value = false;
    }
  }

  // --- REENVIAR CÓDIGO ---
  Future<void> resendCode() async {
    if (_tempPassword == null || _tempName == null) {
      notificationService.showError("Error", "Datos de registro perdidos. Intenta de nuevo.");
      return;
    }
    try {
      isLoading.value = true;
      await repository.signUp(userEmail.value, _tempPassword!, _tempName!);
      notificationService.showSuccess("Éxito", "Código reenviado");
    } catch (e) {
      notificationService.showError("Error", "No se pudo reenviar el código");
    } finally {
      isLoading.value = false;
    }
  }
}
