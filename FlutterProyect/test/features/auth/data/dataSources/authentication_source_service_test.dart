import 'dart:convert';
import 'package:flutter_prueba/features/auth/domain/entities/authentication_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:flutter_prueba/features/auth/data/dataSources/authentication_source_service.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';

@GenerateMocks([http.Client, ILocalPreferences])
import 'authentication_source_service_test.mocks.dart';

void main() {
  late AuthenticationSourceServiceRoble dataSource;
  late MockClient mockHttpClient;
  late MockILocalPreferences mockPrefs;

  setUpAll(() {
    dotenv.load(fileName: '.env');
  });

  setUp(() {
    Get.reset();

    mockHttpClient = MockClient();
    mockPrefs = MockILocalPreferences();

    Get.put<ILocalPreferences>(mockPrefs);

    when(mockPrefs.getString(any)).thenAnswer((_) async => "token_por_defecto");
    when(mockPrefs.remove(any)).thenAnswer((_) async => true);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

    dataSource = AuthenticationSourceServiceRoble(client: mockHttpClient);
  });
  group('login', () {
    const tEmail = "marcus@uninorte.edu.co";
    const tPass = "password123";

    test('debe guardar tokens y datos de usuario en SharedPreferences cuando el status es 201', () async {
      final responseBody = jsonEncode({
        "accessToken": "access_123",
        "refreshToken": "refresh_123",
        "user": {
          "id": "user_001",
          "email": tEmail
        }
      });

      when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body')
      )).thenAnswer((_) async => http.Response(responseBody, 201));

      await dataSource.login(tEmail, tPass);

      verify(mockPrefs.setString('token', 'access_123')).called(1);
      verify(mockPrefs.setString('refreshToken', 'refresh_123')).called(1);
      verify(mockPrefs.setString('userId', 'user_001')).called(1);
      verify(mockPrefs.setString('email', tEmail)).called(1);
    });

    test('debe lanzar un Future.error con el mensaje del servidor cuando falla (401)', () async {
      final errorResponse = jsonEncode({"message": "Usuario no verificado o no encontrado"});

      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(errorResponse, 401));


      expect(
              () => dataSource.login(tEmail, tPass),
          throwsA(predicate((e) => e is String && e.contains("Usuario no verificado")))
      );
    });
  });

  group('signUp', () {
    const tEmail = "marcus@uninorte.edu.co";
    const tPass = "Pass123!";
    const tName = "Marcus";

    test('debe retornar void (éxito) cuando el status es 201', () async {
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => http.Response('', 201));

      await dataSource.signUp(tEmail, tPass, tName);

      verify(mockHttpClient.post(
        argThat(predicate((Uri u) => u.path.contains('signup'))),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('debe retornar el mensaje de error cuando el servidor responde con un String (400)', () async {
      final errorResponse = jsonEncode({"message": "El usuario ya existe"});

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => http.Response(errorResponse, 400));

      expect(
              () => dataSource.signUp(tEmail, tPass, tName),
          throwsA(equals("El usuario ya existe"))
      );
    });

    test('debe concatenar y retornar errores cuando el servidor responde con una lista (400)', () async {
      final errorResponse = jsonEncode({
        "message": ["Email inválido.", "La contraseña es muy débil."]
      });

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => http.Response(errorResponse, 400));

      expect(
              () => dataSource.signUp(tEmail, tPass, tName),
          throwsA(equals("Email inválido. La contraseña es muy débil."))
      );
    });
  });


  group('logOut', () {
    const tToken = "token_de_prueba_123";

    test('debe retornar true y borrar tokens cuando el servidor responde 201', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => http.Response('', 201));

      final result = await dataSource.logOut();

      expect(result, true);
      verify(mockPrefs.remove('token')).called(1);
      verify(mockPrefs.remove('refreshToken')).called(1);
    });

    test('debe lanzar error inmediatamente si el token es nulo en preferencias', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => null);

      expect(() => dataSource.logOut(), throwsA(equals('No token found')));

      verifyNever(mockHttpClient.post(any, headers: anyNamed('headers')));
    });

    test('debe lanzar error con el mensaje del servidor si el status no es 201', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);
      final errorResponse = jsonEncode({"message": "Invalid Session"});

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => http.Response(errorResponse, 401));

      expect(
              () => dataSource.logOut(),
          throwsA(contains('Error code Invalid Session'))
      );
    });
  });


  group('validate', () {
    const tEmail = "marcus@uninorte.edu.co";
    const tCode = "123456";

    test('debe retornar true cuando el servidor responde 201 (Éxito)', () async {
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 201));

      final result = await dataSource.validate(tEmail, tCode);

      expect(result, true);
      verify(mockHttpClient.post(
        argThat(predicate((Uri u) => u.path.contains('verify-email'))),
        headers: anyNamed('headers'),
        body: jsonEncode({"email": tEmail, "code": tCode}),
      )).called(1);
    });

    test('debe retornar true cuando el servidor responde 400 pero el mensaje indica que ya fue verificado', () async {
      final errorResponse = jsonEncode({"message": "El usuario ya ha sido verificado"});

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(errorResponse, 400));

      final result = await dataSource.validate(tEmail, tCode);

      expect(result, true);
    });

    test('debe lanzar el mensaje de error cuando el servidor responde con error (ej. 401 o 400 distinto)', () async {
      final errorResponse = jsonEncode({"message": "Código inválido"});

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(errorResponse, 401));

      expect(
              () => dataSource.validate(tEmail, tCode),
          throwsA(equals("Código inválido"))
      );
    });

    test('debe manejar errores sin mensaje en el body devolviendo un String vacío o error', () async {
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({}), 404));

      expect(
              () => dataSource.validate(tEmail, tCode),
          throwsA(equals(""))
      );
    });
  });

  group('refreshToken', () {
    const tRefreshToken = "refresh_token_viejo_456";
    const tNewAccessToken = "access_token_nuevo_789";

    test('debe guardar el nuevo token y retornar true cuando el servidor responde 201', () async {
      when(mockPrefs.getString('refreshToken')).thenAnswer((_) async => tRefreshToken);

      final responseBody = jsonEncode({"accessToken": tNewAccessToken});
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await dataSource.refreshToken();

      expect(result, true);
      verify(mockPrefs.setString('token', tNewAccessToken)).called(1);
      verify(mockHttpClient.post(
        argThat(predicate((Uri u) => u.path.contains('refresh-token'))),
        headers: anyNamed('headers'),
        body: jsonEncode({'refreshToken': tRefreshToken}),
      )).called(1);
    });

    test('debe retornar false (sin lanzar error) si el refreshToken es nulo en preferencias', () async {
      when(mockPrefs.getString('refreshToken')).thenAnswer((_) async => null);

      final result = await dataSource.refreshToken();

      expect(result, false);
      verifyNever(mockHttpClient.post(any, headers: anyNamed('headers')));
    });

    test('debe lanzar Future.error con el status code cuando la respuesta no es 201', () async {
      when(mockPrefs.getString('refreshToken')).thenAnswer((_) async => tRefreshToken);

      final errorBody = jsonEncode({"message": "Token expirado o inválido"});
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(errorBody, 401));

      expect(
              () => dataSource.refreshToken(),
          throwsA(equals('Error code 401'))
      );
    });
  });

  group('verifyToken', () {
    const tToken = "token_a_verificar_123";

    test('debe retornar true cuando el servidor responde 200 (Token Válido)', () async {
      // Arrange
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);

      when(mockHttpClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('', 200));

      // Act
      final result = await dataSource.verifyToken();

      // Assert
      expect(result, true);
      verify(mockHttpClient.get(
        argThat(predicate((Uri u) => u.path.contains('verify-token'))),
        headers: {'Authorization': 'Bearer $tToken'},
      )).called(1);
    });

    test('debe retornar false si el token no existe en preferencias', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => null);

      final result = await dataSource.verifyToken();

      expect(result, false);
      verifyNever(mockHttpClient.get(any, headers: anyNamed('headers')));
    });

    test('debe retornar false cuando el servidor responde con error (ej. 401)', () async {
      // Arrange
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);

      final errorBody = jsonEncode({"message": "Token expired"});
      when(mockHttpClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(errorBody, 401));

      // Act
      final result = await dataSource.verifyToken();

      // Assert
      expect(result, false);
    });
  });

  group('addUser', () {
    const tEmail = "nuevo_usuario@uninorte.edu.co";
    const tToken = "token_valido_123";
    const tUserId = "user_999";

    test('debe retornar true cuando el usuario se agrega exitosamente (Status 201)', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);
      when(mockPrefs.getString('userId')).thenAnswer((_) async => tUserId);

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 201));

      final result = await dataSource.addUser(tEmail);

      expect(result, true);
      verify(mockHttpClient.post(
        any,
        headers: argThat(containsPair('Authorization', 'Bearer $tToken'), named: 'headers'),
        body: argThat(contains('estudiante'), named: 'body'),
      )).called(1);
    });

    test('debe lanzar error inmediatamente si no hay token y el refresh falla', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => null);

      when(mockHttpClient.post(
        argThat(predicate((Uri u) => u.path.contains('refresh-token'))),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"message": "error"}', 401));

      expect(
              () => dataSource.addUser(tEmail),
          throwsA(equals('No se pudo obtener token'))
      );
    });

    test('debe lanzar error con el mensaje formateado cuando la API de base de datos falla (403)', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);
      when(mockPrefs.getString('userId')).thenAnswer((_) async => tUserId);

      final errorBody = jsonEncode({"message": "Permiso denegado"});

      when(mockHttpClient.post(
        argThat(predicate((Uri u) => u.path.contains('/database/'))),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(errorBody, 403));

      expect(
              () => dataSource.addUser(tEmail),
          throwsA(equals('AddUser error code 403'))
      );
    });
  });

  group('getLoggedUser', () {
    const tUserId = "user_123";
    const tToken = "token_valido_789";

    final tUserJson = [
      {
        "userId": tUserId,
        "email": "marcus@uninorte.edu.co",
        "name": "Marcus",
        "rol": "estudiante"
      }
    ];

    test('debe retornar un AuthenticationUser cuando el servidor responde 200 con datos', () async {
      when(mockPrefs.getString('userId')).thenAnswer((_) async => tUserId);
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);

      when(mockHttpClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(tUserJson), 200));

      final result = await dataSource.getLoggedUser();

      expect(result.email, "marcus@uninorte.edu.co");
      expect(result.id, tUserId);

      verify(mockHttpClient.get(
        argThat(predicate((Uri u) {
          return u.path.contains('/read') &&
              u.queryParameters['userId'] == tUserId &&
              u.queryParameters['tableName'] == 'Users';
        })),
        headers: argThat(containsPair('Authorization', 'Bearer $tToken'), named: 'headers'),
      )).called(1);
    });

    test('debe lanzar error cuando la lista recibida está vacía (Usuario no encontrado)', () async {
      when(mockPrefs.getString('userId')).thenAnswer((_) async => tUserId);
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);

      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode([]), 200));

      expect(
              () => dataSource.getLoggedUser(),
          throwsA(contains('No se encontró el usuario'))
      );
    });

    test('debe lanzar error formateado cuando el servidor responde con error (ej. 500)', () async {
      when(mockPrefs.getString('userId')).thenAnswer((_) async => tUserId);
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);

      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Internal Server Error', 500));

      expect(
              () => dataSource.getLoggedUser(),
          throwsA(equals('Error code 500'))
      );
    });
  });

  group('getUsers', () {
    const tToken = "token_valido_999";

    final tUsersListJson = [
      {
        "userId": "user_001",
        "email": "marcus@uninorte.edu.co",
        "name": "Marcus",
        "rol": "estudiante"
      },
      {
        "userId": "user_002",
        "email": "profesor@uninorte.edu.co",
        "name": "Augusto",
        "rol": "profesor"
      }
    ];

    test('debe retornar una lista de AuthenticationUser cuando el servidor responde 200', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);

      when(mockHttpClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(tUsersListJson), 200));

      final result = await dataSource.getUsers();

      expect(result, isA<List<AuthenticationUser>>());
      expect(result.length, 2);
      expect(result[0].email, "marcus@uninorte.edu.co");
      expect(result[1].id, "user_002");

      verify(mockHttpClient.get(
        argThat(predicate((Uri u) =>
        u.path.contains('/read') &&
            u.queryParameters['tableName'] == 'Users'
        )),
        headers: argThat(containsPair('Authorization', 'Bearer $tToken'), named: 'headers'),
      )).called(1);
    });

    test('debe retornar una lista vacía si el servidor responde 200 pero no hay registros', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode([]), 200));

      final result = await dataSource.getUsers();

      expect(result, isEmpty);
    });

    test('debe lanzar un Future.error cuando el status code no es 200', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => tToken);
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 404));

      expect(
              () => dataSource.getUsers(),
          throwsA(equals('Error code 404'))
      );
    });
  });
}

