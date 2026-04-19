import 'package:flutter_prueba/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_prueba/features/auth/domain/entities/authentication_user.dart';

import '../core/i_local_preferences.dart';

class FakeAuthenticationRepository implements IAuthRepository {
  final String id;
  final String role;
  final String email;

  String? _fakeToken;
  FakeAuthenticationRepository({required this.id, required this.role, required this.email});

  @override
  Future<void> login(String email, String password) async {
    _fakeToken = "fake_token_test";
  return Future.value();
  }

  @override
  Future<List<AuthenticationUser>> getUsers() async => [
    AuthenticationUser(id: id, email: email, rol: role)
  ];

  @override
  Future<bool> addUser(String email) async {
    return true;
  }

  @override
  Future<bool> forgotPassword(String email) async => true;

  @override
  Future<AuthenticationUser> getLoggedUser() async =>
      AuthenticationUser(id: id, email: email, rol: role);

  @override
  Future<bool> logOut() async => true;

  @override
  Future<bool> refreshToken() async => true;

  @override
  Future<bool> resetPassword(String email, String newPassword, String validationCode) async => true;

  @override
  Future<void> signUp(String email, String password, String name) async => Future.value();

  @override
  Future<bool> validate(String email, String validationCode) async => true;

  @override
  Future<bool> verifyToken() async => true;

  @override
  Future<bool> validateToken() {
    // TODO: implement validateToken
    throw UnimplementedError();
  }
}