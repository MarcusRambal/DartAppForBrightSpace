import '../entities/authentication_user.dart';
import '../../data/models/user_model.dart'; // 👈 Añadir esta línea

abstract class IAuthRepository {
  Future<UserModel?> login(AuthenticationUser user);

  Future<bool> signUp(AuthenticationUser user);
  Future<bool> logOut();

  Future<bool> validate(String email, String validationCode);

  Future<bool> validateToken();

  Future<void> forgotPassword(String email);
}
