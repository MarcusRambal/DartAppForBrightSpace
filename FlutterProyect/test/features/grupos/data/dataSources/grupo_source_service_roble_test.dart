import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/grupos/data/dataSources/grupo_source_service_roble.dart';

class FakeLocalPreferences implements ILocalPreferences {
  final Map<String, dynamic> _storage = {};

  @override
  Future<String?> getString(String key) async {
    final value = _storage[key];
    return value is String ? value : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _storage[key];
    return value is int ? value : null;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    final value = _storage[key];
    return value is double ? value : null;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _storage[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _storage[key];
    return value is bool ? value : null;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _storage[key] = value;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _storage[key];
    return value is List<String> ? value : null;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _storage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

class TestHttpClient extends http.BaseClient {
  int responseStatusCode = 200;
  String responseBody = '';

  int callCount = 0;
  Uri? lastUri;
  Map<String, String>? lastHeaders;
  String? lastBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    callCount++;
    lastUri = request.url;
    lastHeaders = request.headers;

    final bodyBytes = await request.finalize().toBytes();
    lastBody = utf8.decode(bodyBytes);

    return http.StreamedResponse(
      Stream.value(Uint8List.fromList(utf8.encode(responseBody))),
      responseStatusCode,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GrupoSourceServiceRoble dataSource;
  late TestHttpClient testHttpClient;
  late FakeLocalPreferences fakePrefs;

  final tUri = Uri.https(
    'roble-api.openlab.uninorte.edu.co',
    '/database/NO_ENV/insert',
  );

  setUpAll(() async {
    await dotenv.load(
      fileName: '.env',
      isOptional: true,
      mergeWith: {'EXPO_PUBLIC_ROBLE_PROJECT_ID': 'NO_ENV'},
    );
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    testHttpClient = TestHttpClient();
    fakePrefs = FakeLocalPreferences();
    await fakePrefs.setString('token', 'token_prueba');

    Get.put<ILocalPreferences>(fakePrefs);

    dataSource = GrupoSourceServiceRoble(client: testHttpClient);
  });

  group('GrupoSourceServiceRoble - createCategoria', () {
    test(
      'Debe crear categoría y retornar un id cuando Roble responde 201',
      () async {
        testHttpClient.responseStatusCode = 201;
        testHttpClient.responseBody = '';

        final result = await dataSource.createCategoria(
          'curso_1',
          'Categoría A',
        );

        expect(result, isNotEmpty);
        expect(testHttpClient.callCount, 1);
        expect(testHttpClient.lastUri, tUri);
        expect(testHttpClient.lastHeaders, {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token_prueba',
        });
        expect(testHttpClient.lastBody, contains('"tableName":"Categoria"'));
        expect(testHttpClient.lastBody, contains('"nombre":"Categoría A"'));
        expect(testHttpClient.lastBody, contains('"idCurso":"curso_1"'));
        expect(testHttpClient.lastBody, contains('"idcat":"'));
      },
    );

    test('Debe lanzar excepción si Roble responde con error', () async {
      testHttpClient.responseStatusCode = 500;
      testHttpClient.responseBody = 'Error';

      await expectLater(
        dataSource.createCategoria('curso_1', 'Categoría A'),
        throwsException,
      );

      expect(testHttpClient.callCount, 1);
      expect(testHttpClient.lastUri, tUri);
    });

    test('Debe fallar si no hay token disponible', () async {
      await fakePrefs.remove('token');

      await expectLater(
        dataSource.createCategoria('curso_1', 'Categoría A'),
        throwsException,
      );

      expect(testHttpClient.callCount, 0);
    });
  });

  group('GrupoSourceServiceRoble - createGruposBatch', () {
    final estudiantes = [
      {
        'idCat': 'cat_1',
        'idGrupo': 'G1_correo1@uninorte.edu.co',
        'nombre': 'Grupo 1',
        'Correo': 'correo1@uninorte.edu.co',
      },
      {
        'idCat': 'cat_1',
        'idGrupo': 'G1_correo2@uninorte.edu.co',
        'nombre': 'Grupo 1',
        'Correo': 'correo2@uninorte.edu.co',
      },
    ];

    test(
      'Debe insertar el lote correctamente cuando Roble responde 200',
      () async {
        testHttpClient.responseStatusCode = 200;
        testHttpClient.responseBody = '';

        await dataSource.createGruposBatch(estudiantes);

        expect(testHttpClient.callCount, 1);
        expect(testHttpClient.lastUri, tUri);
        expect(testHttpClient.lastHeaders, {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token_prueba',
        });
        expect(
          testHttpClient.lastBody,
          jsonEncode({'tableName': 'Grupos', 'records': estudiantes}),
        );
      },
    );

    test('No debe llamar http si la lista está vacía', () async {
      await dataSource.createGruposBatch([]);

      expect(testHttpClient.callCount, 0);
    });

    test('Debe lanzar excepción cuando la API responde error', () async {
      testHttpClient.responseStatusCode = 500;
      testHttpClient.responseBody = 'Error';

      await expectLater(
        dataSource.createGruposBatch(estudiantes),
        throwsException,
      );

      expect(testHttpClient.callCount, 1);
      expect(testHttpClient.lastUri, tUri);
    });

    test('Debe fallar si no hay token disponible', () async {
      await fakePrefs.remove('token');

      await expectLater(
        dataSource.createGruposBatch(estudiantes),
        throwsException,
      );

      expect(testHttpClient.callCount, 0);
    });
  });
}
