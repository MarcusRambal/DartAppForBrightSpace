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

  @override
  Future<String> createCategoria(String idCurso, String nombre) async {
    final token = await _getValidToken();
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    // 🔥 Ahora lo guardamos 100% como String
    final String idCatManual = DateTime.now().millisecondsSinceEpoch.toString();

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
      return idCatManual;
    } else {
      throw Exception("Error en Roble al crear categoría");
    }
  }

  // 🔥 NUEVO: INSERCIÓN MASIVA
  @override
  Future<void> createGruposBatch(List<Map<String, dynamic>> estudiantes) async {
    if (estudiantes.isEmpty) return;

    final token = await _getValidToken();
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final body = jsonEncode({
      "tableName": "Grupos",
      "records":
          estudiantes, // Enviamos todos los estudiantes en un solo paquete
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
      logError("ERROR LOTE GRUPOS: ${response.body}");
      throw Exception("Error al insertar el lote de estudiantes");
    }
  }
}
