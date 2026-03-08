// Importaciones necesarias
import '../../domain/entities/authentication_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'package:get/get.dart'; // GetX para estado reactivo y controllers
import 'package:loggy/loggy.dart'; // Loggy para imprimir logs de depuración

// Este controller maneja toda la lógica de autenticación de la app
class AuthenticationController extends GetxController {

  // Repositorio de autenticación (contrato abstracto)
  // Aquí se inyecta el repository que puede ser mock, local o remoto
  final IAuthRepository repoAuthentication;

  // Estado reactivo de login
  final _logged = false.obs;

  // Estado reactivo de loading
  final _isLoading = false.obs;

  // Constructor con inyección del repositorio
  AuthenticationController(this.repoAuthentication);

  // Getters públicos para la UI
  bool get isLoading => _isLoading.value;
  bool get isLogged => _logged.value;

  // ============================
  // Método para iniciar sesión
  // ============================
  Future<bool> login(String email, String password) async {
    logInfo('AuthenticationController: Login $email $password');

    // Validación básica de email y password antes de llamar al repository
    if (!_validate(email, password)) {
      logWarning('AuthenticationController: Invalid email or password');
      return false;
    }

    // Activar indicador de carga en la UI
    _isLoading.value = true;

    // Crear usuario del dominio
    var rta = await repoAuthentication.login(
      AuthenticationUser(email: email, name: email, password: password),
    );

    // Actualizar estado de login
    _logged.value = rta;

    // Desactivar loading
    _isLoading.value = false;

    // Retornar resultado
    return rta;
  }

  // ============================
  // Método para registrar usuario
  // ============================
  Future<bool> signUp(String email, String password) async {
    logInfo('AuthenticationController: Sign Up $email $password');

    // Validación básica de email y password
    if (!_validate(email, password)) {
      logWarning('AuthenticationController: Invalid email or password');
      return false;
    }

    // Activar loading
    _isLoading.value = true;

    // Crear usuario y enviar al repository
    await repoAuthentication.signUp(
      AuthenticationUser(email: email, name: email, password: password),
    );

    // Desactivar loading
    _isLoading.value = false;

    // Retornar true porque la creación se realizó sin errores
    return true;
  }

  // ============================
  // Método para cerrar sesión
  // ============================
  Future<void> logOut() async {
    logInfo('AuthenticationController: Log Out');

    // Llamar al repository
    await repoAuthentication.logOut();

    // Cambiar estado de login
    _logged.value = false;
  }

  // ============================
  // Validación simple de datos
  // ============================
  bool _validate(String email, String password) =>
      email.isNotEmpty && password.length > 6;
}