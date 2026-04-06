import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/grupos/data/dataSources/grupo_source_service_roble.dart';

import 'grupo_source_service_roble_test.mocks.dart';

@GenerateMocks([http.Client, ILocalPreferences])
void main() {
  late GrupoSourceServiceRoble dataSource;
  late MockClient mockHttpClient;
  late MockILocalPreferences mockPrefs;

  setUpAll(() {
    dotenv.testLoad(fileInput: 'EXPO_PUBLIC_ROBLE_PROJECT_ID=test_contract');
  });

  setUp(() {
    Get.reset();

    mockHttpClient = MockClient();
    mockPrefs = MockILocalPreferences();

    Get.put<ILocalPreferences>(mockPrefs);

    when(mockPrefs.getString('token')).thenAnswer((_) async => 'token_prueba');

    dataSource = GrupoSourceServiceRoble(client: mockHttpClient);
  });

  group('createCategoria', () {
    test(
      'debe crear categoría y retornar un id cuando el status es 201',
      () async {
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('', 201));

        final result = await dataSource.createCategoria(
          'curso_1',
          'Categoría A',
        );

        expect(result, isNotEmpty);

        verify(
          mockHttpClient.post(
            argThat(
              predicate<Uri>(
                (u) => u.path.contains('/database/test_contract/insert'),
              ),
            ),
            headers: argThat(
              containsPair('Authorization', 'Bearer token_prueba'),
              named: 'headers',
            ),
            body: argThat(
              allOf(
                contains('"tableName":"Categoria"'),
                contains('"nombre":"Categoría A"'),
                contains('"idCurso":"curso_1"'),
              ),
              named: 'body',
            ),
          ),
        ).called(1);
      },
    );

    test('debe lanzar excepción si Roble responde con error', () async {
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () => dataSource.createCategoria('curso_1', 'Categoría A'),
        throwsA(isA<Exception>()),
      );
    });

    test('debe fallar si no hay token en preferencias', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => null);

      expect(
        () => dataSource.createCategoria('curso_1', 'Categoría A'),
        throwsA(isA<Exception>()),
      );

      verifyNever(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      );
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

    test('debe insertar lote correctamente cuando el status es 200', () async {
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('', 200));

      await dataSource.createGruposBatch(estudiantes);

      verify(
        mockHttpClient.post(
          argThat(
            predicate<Uri>(
              (u) => u.path.contains('/database/test_contract/insert'),
            ),
          ),
          headers: argThat(
            containsPair('Authorization', 'Bearer token_prueba'),
            named: 'headers',
          ),
          body: argThat(
            allOf(
              contains('"tableName":"Grupos"'),
              contains('"Correo":"correo1@uninorte.edu.co"'),
              contains('"Correo":"correo2@uninorte.edu.co"'),
            ),
            named: 'body',
          ),
        ),
      ).called(1);
    });

    test('no debe llamar http si la lista está vacía', () async {
      await dataSource.createGruposBatch([]);

      verifyNever(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      );
    });

    test('debe lanzar excepción cuando la API responde error', () async {
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode({'message': 'falló'}), 500),
      );

      expect(
        () => dataSource.createGruposBatch(estudiantes),
        throwsA(isA<Exception>()),
      );
    });

    test('debe fallar si no hay token', () async {
      when(mockPrefs.getString('token')).thenAnswer((_) async => null);

      expect(
        () => dataSource.createGruposBatch(estudiantes),
        throwsA(isA<Exception>()),
      );

      verifyNever(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      );
    });
  });
}
