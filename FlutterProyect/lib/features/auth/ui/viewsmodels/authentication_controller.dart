import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthenticationController extends GetxController {
  final IAuthRepository repository;

  AuthenticationController({required this.repository});

  // --- Observables para la UI ---
  var isLoading = false.obs;
  var userEmail = ''.obs; // Lo guardamos para la pantalla de verificación
  var verificationCode = ''.obs;

  // --- Registro ---
  Future<void> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;
      userEmail.value = email; // Persistimos el email en el controlador

      await repository.signUp(email, password, name);

      // Si el signUp es exitoso (201), navegamos a la verificación
      Get.toNamed('/verify-email');
    } catch (e) {
      logError("Error en signUp: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  //  Verificación
  Future<void> verifyEmail() async {
    if (verificationCode.value.length < 6) {
      throw "El código debe tener 6 dígitos";
    }

    try {
      isLoading.value = true;

      final success = await repository.validate(userEmail.value, verificationCode.value);

      if (success) {
        logInfo("Email verificado para ${userEmail.value}");

        // await repository.addUser(userEmail.value);

        Get.offAllNamed('/home'); // Limpia el stack y va al Home
      }
    } catch (e) {
      logError("Error en verificación: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await repository.login(email, password);
    }catch(e){
      logError("Error en login: $e");
      rethrow;
    }finally{
      isLoading.value = false;
    }
  }

  // Helper para el PinCodeTextField de la UI
  void onCodeChanged(String code) => verificationCode.value = code;
}