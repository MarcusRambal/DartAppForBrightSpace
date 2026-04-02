import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Imports de tus archivos
import 'package:flutter_prueba/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_prueba/features/auth/data/dataSources/i_authentication_source.dart';
import 'package:flutter_prueba/features/auth/domain/entities/authentication_user.dart';

@GenerateMocks([IAuthenticationSource])
import 'auth_repository_test.mocks.dart';

void main() {
  late AuthRepository repository;
  late MockIAuthenticationSource mockSource;

  setUp(() {
    mockSource = MockIAuthenticationSource();
    repository = AuthRepository(mockSource);
  });

  group('AuthRepository - Pasarela de datos', () {
    const tEmail = "marcus@uninorte.edu.co";
    const tPass = "Pass123!";
    const tName = "Marcus";
    const tCode = "123456";

    test('Debe llamar a signUp en el Source y retornar void', () async {
      when(mockSource.signUp(any, any, any))
          .thenAnswer((_) async => Future.value());

      await repository.signUp(tEmail, tPass, tName);

      verify(mockSource.signUp(tEmail, tPass, tName)).called(1);
    });

    test('Debe llamar a validate en el Source y retornar true', () async {
      when(mockSource.validate(any, any))
          .thenAnswer((_) async => true);

      final result = await repository.validate(tEmail, tCode);

      expect(result, true);
      verify(mockSource.validate(tEmail, tCode)).called(1);
    });

    test('Debe retornar un AuthenticationUser cuando getLoggedUser es exitoso', () async {
      final tUser = AuthenticationUser(id: "1", email: tEmail, rol: "estudiante");
      when(mockSource.getLoggedUser())
          .thenAnswer((_) async => tUser);

      final result = await repository.getLoggedUser();

      expect(result, tUser);
      verify(mockSource.getLoggedUser()).called(1);
    });

    test('Debe propagar la excepción si el Source falla', () async {
      when(mockSource.login(any, any))
          .thenThrow(Exception("Error de servidor"));

      expect(() => repository.login(tEmail, tPass), throwsException);
      verify(mockSource.login(tEmail, tPass)).called(1);
    });
  });
}