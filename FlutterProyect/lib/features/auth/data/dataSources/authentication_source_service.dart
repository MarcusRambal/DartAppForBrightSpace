import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/authentication_user.dart';
import 'i_authentication_source.dart';
import '../models/user_model.dart';
import 'package:collection/collection.dart';

class AuthenticationSourceService
    with UiLoggy
    implements IAuthenticationSource {
  final http.Client httpClient;

  // 1️⃣ Usuarios simulados: docentes preexistentes
  final List<UserModel> _users = [
    UserModel(
      id: 1,
      email: 'profesor@institucion.edu',
      name: 'Profesor Ejemplo',
      password: 'profesor123',
      rol: UserRole.teacher,
    ),
  ];

  AuthenticationSourceService({http.Client? client})
    : httpClient = client ?? http.Client();

  // 2️⃣ Login: busca usuario existente (docente o estudiante)
  @override
  Future<UserModel?> login(AuthenticationUser user) async {
    // 👈 Cambiar bool por UserModel?
    logInfo("Attempting login for email: ${user.email}");

    var existingUser = _users.firstWhereOrNull(
      (u) => u.email == user.email && u.password == user.password,
    );

    if (existingUser != null) {
      logInfo("Login successful: ${existingUser.email} (${existingUser.rol})");
      return Future.value(
        existingUser,
      ); // 👈 Retornar el usuario en lugar de true
    } else {
      logWarning("Login failed for: ${user.email}");
      return Future.value(null); // 👈 Retornar null en lugar de false
    }
  }

  // 3️⃣ SignUp: agrega estudiante a la lista con rol student
  @override
  Future<bool> signUp(AuthenticationUser user) async {
    logInfo("Attempting sign up for email: ${user.email}");

    var existingUser = _users.firstWhereOrNull((u) => u.email == user.email);

    if (existingUser != null) {
      logWarning("Sign up failed: user already exists ${user.email}");
      return Future.value(false);
    }

    _users.add(
      UserModel(
        id: _users.length + 1,
        email: user.email,
        name: user.name,
        password: user.password,
        rol: UserRole.student,
      ),
    );

    logInfo("Student registered successfully: ${user.email}");
    return Future.value(true);
  }

  // 4️⃣ Logout: simulación
  @override
  Future<bool> logOut() async {
    logInfo("Attempting logout");
    return Future.value(true);
  }

  // 5️⃣ Otros métodos: simulación
  @override
  Future<bool> validate(String email, String validationCode) async {
    logInfo("Attempting email validation for email: $email");
    return Future.value(true);
  }

  @override
  Future<bool> refreshToken() async {
    logInfo("Attempting token refresh");
    return Future.value(true);
  }

  @override
  Future<bool> forgotPassword(String email) async {
    logInfo("Attempting password reset for email: $email");
    return Future.value(true);
  }

  @override
  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  ) async {
    logInfo("Reset password requested for email: $email");
    return Future.value(true);
  }

  @override
  Future<bool> verifyToken() async {
    logInfo("Attempting token verification");
    return Future.value(true);
  }
}
