import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthenticationController extends GetxController {
  final IAuthRepository repository;

  AuthenticationController({required this.repository});

  // --- ESTADOS REACTIVOS PARA CENTRAL.DART ---
  var isLogged = false.obs;
  var isWaitingVerification = false.obs;
  var isLoading = false.obs;
  var isRegistering = false.obs;

  void goToSignUp() {
    isWaitingVerification.value = false;
    isRegistering.value = true;
  }

  void goToLogin() {
    isRegistering.value = false;
    isWaitingVerification.value = false;
  }

  // Variables para persistencia temporal
  var userEmail = ''.obs;
  String? _tempPassword;
  String? _tempName;
  var verificationCode = ''.obs;

  Future<void> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;
      userEmail.value = email;
      _tempPassword = password;
      _tempName = name;

      await repository.signUp(email, password, name);

      isRegistering.value = false;
      isWaitingVerification.value = true;

    } catch (e) {
      logError("Error en signUp: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> validateCode(String email, String code) async {
    try {
      isLoading.value = true;
      await repository.validate(email, code);

      isWaitingVerification.value = false;

      Get.snackbar(
        "¡Cuenta Verificada!",
        "Tu correo ha sido validado. Ya puedes ingresar.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      logError("Error en validación: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await repository.login(email, password);

      isLogged.value = true;

    } catch(e) {
      logError("Error en login: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (_tempPassword == null || _tempName == null) {
      Get.snackbar("Error", "Datos perdidos, intenta registrarte de nuevo.");
      return;
    }
    try {
      isLoading.value = true;
      await repository.signUp(userEmail.value, _tempPassword!, _tempName!);
      Get.snackbar("Éxito", "Nuevo código enviado a ${userEmail.value}");
    } catch (e) {
      logError("Error al reenviar: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onCodeChanged(String code) => verificationCode.value = code;
}