// Importaciones necesarias
import '../../domain/entities/authentication_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../data/models/user_model.dart'; // 👈 IMPORTANTE: Añadimos esto para conocer el modelo
import 'package:get/get.dart'; // GetX para estado reactivo y controllers
import 'package:loggy/loggy.dart'; // Loggy para imprimir logs de depuración

// Este controller maneja toda la lógica de autenticación de la app
class AuthenticationController extends GetxController {
  // Repositorio de autenticación (contrato abstracto)
  // Aquí se inyecta el repository que puede ser mock, local o remoto
  final IAuthRepository repoAuthentication;

  // 👈 CAMBIO CLAVE: Ahora el estado reactivo guarda al usuario completo (para saber su ROL)
  final _loggedUser = Rxn<UserModel>();

  // Estado reactivo de loading
  final _isLoading = false.obs;

  // Constructor con inyección del repositorio
  AuthenticationController(this.repoAuthentication);

  // Getters públicos para la UI
  bool get isLoading => _isLoading.value;
  bool get isLogged =>
      _loggedUser.value != null; // 👈 Devuelve true si hay un usuario guardado

  // 👈 NUEVO: Getter para que la LoginPage pregunte qué rol tiene el usuario que acaba de entrar
  UserRole get role => _loggedUser.value?.rol ?? UserRole.student;

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

    // Crear usuario del dominio y mandarlo al repositorio
    // 👈 CAMBIO: Ahora recibe el UserModel? completo desde tu base de datos simulada
    var userResult = await repoAuthentication.login(
      AuthenticationUser(email: email, name: email, password: password),
    );

    // 👈 CAMBIO: Verificamos si el usuario fue encontrado
    if (userResult != null) {
      _loggedUser.value =
          userResult; // Guardamos el usuario (y su rol) en el estado de GetX
      _isLoading.value = false;
      return true; // Login exitoso
    }

    // Desactivar loading si falla
    _isLoading.value = false;
    return false; // Login fallido
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
    var success = await repoAuthentication.signUp(
      AuthenticationUser(email: email, name: email, password: password),
    );

    // Desactivar loading
    _isLoading.value = false;

    // Retornar el resultado de la creación
    return success;
  }

  // ============================
  // Método para cerrar sesión
  // ============================
  Future<void> logOut() async {
    logInfo('AuthenticationController: Log Out');

    // Llamar al repository
    await repoAuthentication.logOut();

    // 👈 CAMBIO: Limpiamos el estado del usuario al salir
    _loggedUser.value = null;
  }

  // ============================
  // Validación simple de datos
  // ============================
  bool _validate(String email, String password) =>
      email.isNotEmpty &&
      password.length >= 6; // Ajustado a >= 6 para coincidir con tu UI
}
