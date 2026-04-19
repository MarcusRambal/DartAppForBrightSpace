

import 'package:flutter_prueba/features/auth/domain/entities/authentication_user.dart';
import '../features/auth/data/dataSources/i_authentication_source.dart';

class FakeAuthenticationSource implements IAuthenticationSource {
  @override
  Future<void> login(String email, String password) async {
    // No hace nada, solo simula éxito
    return Future.value();
  }

  @override
  Future<bool> addUser(String email) {
    // TODO: implement addUser
    throw UnimplementedError();
  }

  @override
  Future<bool> forgotPassword(String email) {
    // TODO: implement forgotPassword
    throw UnimplementedError();
  }

  @override
  Future<AuthenticationUser> getLoggedUser() {
    // TODO: implement getLoggedUser
    throw UnimplementedError();
  }

  @override
  Future<List<AuthenticationUser>> getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  Future<bool> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  @override
  Future<bool> refreshToken() {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<bool> resetPassword(String email, String newPassword, String validationCode) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<void> signUp(String email, String password, String name) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<bool> validate(String email, String validationCode) {
    // TODO: implement validate
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyToken() {
    // TODO: implement verifyToken
    throw UnimplementedError();
  }
// Implementa los otros métodos igual de simples...
}