import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/entities/authentication_user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthenticationController extends GetxController {
  final IAuthRepository repository;

  AuthenticationController({required this.repository});

  // --- ESTADOS REACTIVOS PARA CENTRAL.DART ---
  var isLogged = false.obs;
  var isWaitingVerification = false.obs;
  var isLoading = false.obs;
  var isRegistering = false.obs;

  // --- USUARIO LOGUEADO ---
  var loggedUser =
      Rxn<AuthenticationUser>(); // <- Usuario actual con info completa

  // Variables para persistencia temporal
  var userEmail = ''.obs;
  String? _tempPassword;
  String? _tempName;
  var verificationCode = ''.obs;

  // --- NAVEGACION ENTRE VISTAS ---
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
    } catch (e) {
      logError("Error en signUp: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // --- VALIDACION DE CODIGO ---
  Future<bool> validateCode(String email, String code) async {
    try {
      isLoading.value = true;

      // Validar código
      await repository.validate(email, code);

      // Refrescar token y agregar usuario a la tabla (estudiante por defecto)
      //try {
      //  await repository.addUser(email);
      //} catch (e) {
      //  logError("No se pudo agregar el usuario en la tabla: $e");
      //}

      // Obtener información completa del usuario recién agregado
      try {
        loggedUser.value = await repository.getLoggedUser();
        isLogged.value = true;
      } catch (e) {
        logError("No se pudo obtener usuario logueado después de validar: $e");
      }

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

  // --- LOGIN ---
Future<void> login(String email, String password) async {
  try {
    isLoading.value = true;

    // --- 1️⃣ Login normal ---
    await repository.login(email, password);

    // --- 2️⃣ Revisar si el usuario ya existe ---
    bool userExists = false;
    try {
      final users = await repository.getUsers(); // obtiene todos los usuarios
      userExists = users.any((u) => u.email == email); // verifica por email
    } catch (e) {
      logError("No se pudo obtener la lista de usuarios: $e");
      // Si falla la verificación, opcional: podrías continuar o detener
    }

    // --- 3️⃣ Solo agregar si no existe ---
    if (!userExists) {
      try {
        await repository.addUser(email);
        logInfo("Usuario agregado a la tabla Users: $email");
      } catch (e) {
        logError("No se pudo agregar el usuario en la tabla: $e");
      }
    } else {
      logInfo("Usuario ya existe en la tabla Users: $email");
    }

    // --- 4️⃣ Obtener usuario logueado después del login ---
    loggedUser.value = await repository.getLoggedUser();
    isLogged.value = true;
  } catch (e) {
    logError("Error en login: $e");
    rethrow;
  } finally {
    isLoading.value = false;
  }
}

  // --- REENVIAR CODIGO ---
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
