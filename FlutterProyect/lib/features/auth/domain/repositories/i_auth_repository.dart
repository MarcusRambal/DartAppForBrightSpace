//FlutterProyect/lib/features/auth/domain/repositories/i_auth_repository.dart
import '../entities/authentication_user.dart';

abstract class IAuthRepository {
  Future<void> login(String email, String password);

  Future<void> signUp(String email, String password, String name);

  Future<bool> logOut();

  Future<bool> validate(String email, String validationCode);

  Future<bool> validateToken();

  Future<void> forgotPassword(String email);

  Future<AuthenticationUser> getLoggedUser();

  Future<List<AuthenticationUser>> getUsers();
  Future<bool> addUser(String email);
}
