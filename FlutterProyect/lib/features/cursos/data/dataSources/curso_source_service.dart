import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/i_local_preferences.dart';
import '../../domain/entities/curso_curso.dart';
import 'i_curso_source.dart';

class CursoSourceServiceRoble implements ICursoSource {
  final http.Client httpClient;

  final contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );

  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  CursoSourceServiceRoble({http.Client? client})
    : httpClient = client ?? http.Client();

  // 🔑 Obtener token válido (con refresh automático)
  Future<String> _getValidToken() async {
    final ILocalPreferences sharedPreferences = Get.find();

    String? token = await sharedPreferences.getString('token');

    if (token == null) {
      logInfo("No hay token, intentando refrescar...");

      // 🔥 Aquí debes tener registrado tu auth repository en Get
      final authRepo = Get.find<dynamic>();
      final refreshed = await authRepo.refreshToken();

      if (!refreshed) {
        throw Exception("No se pudo refrescar el token");
      }

      token = await sharedPreferences.getString('token');

      if (token == null) {
        throw Exception("Token sigue siendo null");
      }
    }

    return token;
  }

  // 🟢 CREATE
@override
Future<void> createCurso(String idCurso, String nom) async {
  final token = await _getValidToken();
  final prefs = Get.find<ILocalPreferences>();

  final idProfe = await prefs.getString('userId');

  if (idProfe == null) {
    throw Exception("Usuario no autenticado");
  }

  final uri = Uri.https(baseUrl, '/database/$contract/insert');

  final body = jsonEncode({
    "tableName": "Cursos",
    "records": [
      {
        "idcurso": idCurso,
        "idprofe": idProfe,
        "nom": nom,
      }
    ]
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
    throw Exception("Error al crear curso");
  }
}
  // 🔵 READ
@override
Future<List<CursoCurso>> getCursosByProfe() async {
  final token = await _getValidToken();
  final prefs = Get.find<ILocalPreferences>();

  final idProfe = await prefs.getString('userId');

  if (idProfe == null) {
    throw Exception("Usuario no autenticado");
  }

  final uri = Uri.https(baseUrl, '/database/$contract/read', {
    'tableName': 'Cursos',
    'idprofe': idProfe,
  });

  final response = await httpClient.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson.map((x) => CursoCurso.fromJson(x)).toList();
  } else {
    throw Exception("Error al obtener cursos");
  }
}

  // 🟡 UPDATE
@override
Future<void> updateCurso(CursoCurso curso, String nomNuevo) async {
  final token = await _getValidToken();

  final uri = Uri.https(baseUrl, '/database/$contract/update');

  final body = jsonEncode({
    "tableName": "Cursos",
    "idColumn": "idcurso",
    "idValue": curso.id,
    "updates": {
      "nom": nomNuevo
    }
  });

  final response = await httpClient.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception("Error al actualizar curso");
  }
}
  // 🔴 DELETE
@override
Future<void> deleteCurso(String idCurso) async {
  final token = await _getValidToken();

  final uri = Uri.https(baseUrl, '/database/$contract/delete');

  final body = jsonEncode({
    "tableName": "Cursos",
    "idColumn": "idcurso",
    "idValue": idCurso,
  });

  final response = await httpClient.delete(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception("Error al eliminar curso");
  }
}
}
