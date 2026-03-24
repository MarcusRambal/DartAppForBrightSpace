import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/i_local_preferences.dart';
import 'i_grupo_source.dart';

class GrupoSourceServiceRoble implements IGrupoSource {
  final http.Client httpClient;
  final contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  GrupoSourceServiceRoble({http.Client? client})
    : httpClient = client ?? http.Client();

  Future<String> _getValidToken() async {
    final ILocalPreferences sharedPreferences = Get.find();
    String? token = await sharedPreferences.getString('token');
    if (token == null) throw Exception("No hay token disponible");
    return token;
  }

  /// 1️⃣ CREAR CATEGORÍA
  @override
  Future<String> createCategoria(String idCurso, String nombre) async {
    final token = await _getValidToken();

    // ✅ URL EXACTA como en cursos
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final int idCatManual = DateTime.now().millisecondsSinceEpoch;

    // ✅ ESTRUCTURA EXACTA como en cursos ("records" como lista)
    final body = jsonEncode({
      "tableName": "Categoria",
      "records": [
        {"idcat": idCatManual, "nombre": nombre, "idCurso": idCurso},
      ],
    });

    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return idCatManual.toString();
    } else {
      logError("ERROR ROBLE CATEGORIA: ${response.body}");
      throw Exception("Error en Roble al crear categoría: ${response.body}");
    }
  }

  /// 2️⃣ CREAR GRUPO
  @override
  Future<void> createGrupo(
    String idCat,
    String nombre,
    String idGrupo,
    String correo,
  ) async {
    final token = await _getValidToken();

    // ✅ URL EXACTA como en cursos
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    // ✅ ESTRUCTURA EXACTA como en cursos ("records" como lista)
    final body = jsonEncode({
      "tableName": "Grupos",
      "records": [
        {
          "idCat": int.parse(idCat),
          "idGrupo": idGrupo,
          "nombre": nombre,
          "Correo": correo,
        },
      ],
    });

    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      logError("ERROR ROBLE GRUPOS: ${response.body}");
      throw Exception("Error al insertar estudiante $correo: ${response.body}");
    }
  }
}
