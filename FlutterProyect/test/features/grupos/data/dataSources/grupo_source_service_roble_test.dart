import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/grupos/data/dataSources/grupo_source_service_roble.dart';

class MockLocalPreferences extends Mock implements ILocalPreferences {}

class TestHttpClient extends http.BaseClient {
  int callCount = 0;
  Uri? lastUri;
  Map<String, String>? lastHeaders;
  String? lastBody;

  int responseStatusCode = 200;
  String responseBody = '';

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
  late GrupoSourceServiceRoble dataSource;
  late TestHttpClient testHttpClient;
  late MockLocalPreferences mockPrefs;

  setUpAll(() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Si no carga el .env, el test igual compilará.
      // Si el data source depende estrictamente de esa variable
      // y falla al ejecutar, ahí revisamos el valor real.
    }
  });

  setUp(() {
    Get.testMode = true;
    Get.reset();

    testHttpClient = TestHttpClient();
    mockPrefs = MockLocalPreferences();

    Get.put<ILocalPreferences>(mockPrefs);

    when(mockPrefs.getString('token')).thenAnswer((_) async => 'token_prueba');

    dataSource = GrupoSourceServiceRoble(client: testHttpClient);
  });

  group('createCategoria', () {
    test(
      'debe crear categoría y retornar un id cuando la respuesta es exitosa',
      () async {
        testHttpClient.responseStatusCode = 201;
        testHttpClient.responseBody = '';

        final result = await dataSource.createCategoria(
          'curso_1',
          'Categoría A',
        );

        expect(result, isNotEmpty);
        expect(testHttpClient.callCount, 1);
        expect(testHttpClient.lastUri, isNotNull);
        expect(testHttpClient.lastHeaders, isNotNull);
        expect(testHttpClient.lastBody, isNotNull);

        expect(
          testHttpClient.lastHeaders!['Authorization'],
          'Bearer token_prueba',
        );
        expect(testHttpClient.lastHeaders!['Content-Type'], 'application/json');

        expect(testHttpClient.lastBody!, contains('"tableName":"Categoria"'));
        expect(testHttpClient.lastBody!, contains('"nombre":"Categoría A"'));
        expect(testHttpClient.lastBody!, contains('"idCurso":"curso_1"'));
      },
    );

    test('debe lanzar excepción si Roble responde con error', () async {
      testHttpClient.responseStatusCode = 500;
      testHttpClient.responseBody = 'Error';

      expect(
        () => dataSource.createCategoria('curso_1', 'Categoría A'),
        throwsA(isA<Exception>()),
      );

      expect(testHttpClient.callCount, 1);
    });

    test('debe fallar si no hay token en preferencias', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => null);

      expect(
        () => dataSource.createCategoria('curso_1', 'Categoría A'),
        throwsA(isA<Exception>()),
      );

      expect(testHttpClient.callCount, 0);
    });
  });

  group('createGruposBatch', () {
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
      'debe insertar lote correctamente cuando la respuesta es exitosa',
      () async {
        testHttpClient.responseStatusCode = 200;
        testHttpClient.responseBody = '';

        await dataSource.createGruposBatch(estudiantes);

        expect(testHttpClient.callCount, 1);
        expect(testHttpClient.lastUri, isNotNull);
        expect(testHttpClient.lastHeaders, isNotNull);
        expect(testHttpClient.lastBody, isNotNull);

        expect(
          testHttpClient.lastHeaders!['Authorization'],
          'Bearer token_prueba',
        );
        expect(testHttpClient.lastHeaders!['Content-Type'], 'application/json');

        expect(testHttpClient.lastBody!, contains('"tableName":"Grupos"'));
        expect(
          testHttpClient.lastBody!,
          contains('"Correo":"correo1@uninorte.edu.co"'),
        );
        expect(
          testHttpClient.lastBody!,
          contains('"Correo":"correo2@uninorte.edu.co"'),
        );
      },
    );

    test('no debe llamar http si la lista está vacía', () async {
      await dataSource.createGruposBatch([]);

      expect(testHttpClient.callCount, 0);
    });

    test('debe lanzar excepción cuando la API responde error', () async {
      testHttpClient.responseStatusCode = 500;
      testHttpClient.responseBody = jsonEncode({'message': 'falló'});

      expect(
        () => dataSource.createGruposBatch(estudiantes),
        throwsA(isA<Exception>()),
      );

      expect(testHttpClient.callCount, 1);
    });

    test('debe fallar si no hay token', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => null);

      expect(
        () => dataSource.createGruposBatch(estudiantes),
        throwsA(isA<Exception>()),
      );

      expect(testHttpClient.callCount, 0);
    });
  });
}
