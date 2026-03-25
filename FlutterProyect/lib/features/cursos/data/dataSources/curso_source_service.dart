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
      final authRepo = Get.find<dynamic>();
      final refreshed = await authRepo.refreshToken();
      if (!refreshed) throw Exception("No se pudo refrescar el token");
      token = await sharedPreferences.getString('token');
      if (token == null) throw Exception("Token sigue siendo null");
    }
    return token;
  }

  // 🟢 CREATE
  @override
  Future<void> createCurso(String idCurso, String nom) async {
    final token = await _getValidToken();
    final prefs = Get.find<ILocalPreferences>();

    final idProfe = await prefs.getString('userId');
    if (idProfe == null) throw Exception("Usuario no autenticado");

    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final body = jsonEncode({
      "tableName": "Cursos",
      "records": [
        {"idcurso": idCurso, "idprofe": idProfe, "nom": nom},
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
      throw Exception("Error al crear curso");
    }
  }

  // 🔵 READ (Para Profesores)
  @override
  Future<List<CursoCurso>> getCursosByProfe() async {
    final token = await _getValidToken();
    final prefs = Get.find<ILocalPreferences>();

    final idProfe = await prefs.getString('userId');
    if (idProfe == null) throw Exception("Usuario no autenticado");

    final uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'Cursos',
      'idprofe': idProfe,
    });

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      return decodedJson.map((x) => CursoCurso.fromJson(x)).toList();
    } else {
      throw Exception("Error al obtener cursos");
    }
  }

  // 🟣 READ (Para Estudiantes)
  @override
  Future<List<CursoCurso>> getCursosByEstudiante(String emailEstudiante) async {
    final token = await _getValidToken();

    final uriGrupos = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'Grupos',
      'Correo': emailEstudiante,
    });

    final respGrupos = await httpClient.get(
      uriGrupos,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respGrupos.statusCode == 200) {
      List<dynamic> grupos = jsonDecode(respGrupos.body);
      if (grupos.isEmpty) return [];

      Set<String> idCats = grupos.map((g) => g['idCat'].toString()).toSet();
      List<CursoCurso> listaCursos = [];

      for (String idCat in idCats) {
        final uriCat = Uri.https(baseUrl, '/database/$contract/read', {
          'tableName': 'Categoria',
          'idcat': idCat,
        });

        final respCat = await httpClient.get(
          uriCat,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (respCat.statusCode == 200) {
          List<dynamic> categoria = jsonDecode(respCat.body);
          if (categoria.isNotEmpty) {
            String nrc = categoria[0]['idCurso'].toString();

            final uriCurso = Uri.https(baseUrl, '/database/$contract/read', {
              'tableName': 'Cursos',
              'idcurso': nrc,
            });

            final respCurso = await httpClient.get(
              uriCurso,
              headers: {'Authorization': 'Bearer $token'},
            );

            if (respCurso.statusCode == 200) {
              List<dynamic> cursoJson = jsonDecode(respCurso.body);
              if (cursoJson.isNotEmpty) {
                listaCursos.add(CursoCurso.fromJson(cursoJson[0]));
              }
            }
          }
        }
      }
      return listaCursos;
    } else {
      throw Exception("Error al buscar los cursos del estudiante");
    }
  }

  // 🟡 UPDATE
  @override
  Future<void> updateCurso(CursoCurso curso, String nomNuevo) async {
    final token = await _getValidToken();

    final uriReadCurso = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'Cursos',
      'idcurso': curso.id,
    });

    final readResponse = await httpClient.get(
      uriReadCurso,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (readResponse.statusCode == 200) {
      List<dynamic> cursosEncontrados = jsonDecode(readResponse.body);
      if (cursosEncontrados.isNotEmpty) {
        String cursoDbId = cursosEncontrados[0]['_id'];

        final uri = Uri.https(baseUrl, '/database/$contract/update');
        final body = jsonEncode({
          "tableName": "Cursos",
          "idColumn": "_id",
          "idValue": cursoDbId,
          "updates": {"nom": nomNuevo},
        });

        final response = await httpClient.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        if (response.statusCode != 200)
          throw Exception("Error al actualizar curso");
      }
    }
  }

  // 🛠️ MÉTODO AYUDANTE: Borrado universal por columna específica
  Future<void> _deleteByPK(
    String tableName,
    String pkColumn,
    String pkValue,
    String token,
  ) async {
    final uri = Uri.https(baseUrl, '/database/$contract/delete');
    final body = jsonEncode({
      "tableName": tableName,
      "idColumn": pkColumn, // 🔥 Dinámico (usaremos idGrupo o idcat)
      "idValue": pkValue,
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
      logError("Error borrando en $tableName: ${response.body}");
    }
  }

  // 🧹 VACIAR CURSO (Buscar y Destruir uno por uno)
  @override
  Future<void> vaciarContenidoCurso(String idCurso) async {
    final token = await _getValidToken();

    // 1. Buscamos las categorías de este curso
    final uriCat = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'Categoria',
      'idCurso': idCurso,
    });

    final respCat = await httpClient.get(
      uriCat,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respCat.statusCode == 200) {
      List<dynamic> categorias = jsonDecode(respCat.body);

      for (var cat in categorias) {
        String idCatStr = cat['idcat'].toString(); // PK de categoría

        // 2. Buscamos TODOS los grupos que pertenecen a esta categoría
        final uriGrupos = Uri.https(baseUrl, '/database/$contract/read', {
          'tableName': 'Grupos',
          'idCat': idCatStr,
        });

        final respGrupos = await httpClient.get(
          uriGrupos,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (respGrupos.statusCode == 200) {
          List<dynamic> grupos = jsonDecode(respGrupos.body);

          // 3. Borramos cada estudiante usando su PK oficial (idGrupo)
          for (var grupo in grupos) {
            String grupoPK = grupo['idGrupo'];
            await _deleteByPK('Grupos', 'idGrupo', grupoPK, token);
          }
        }

        // 4. Borramos la categoría por su PK oficial (idcat)
        await _deleteByPK('Categoria', 'idcat', idCatStr, token);
      }
    }
  }

  // 🔴 DELETE CURSO
  @override
  Future<void> deleteCurso(String idCurso) async {
    final token = await _getValidToken();

    // 1. Vaciamos las dependencias
    await vaciarContenidoCurso(idCurso);

    // 2. Borramos el curso usando su PK (idcurso)
    await _deleteByPK('Cursos', 'idcurso', idCurso, token);
  }
}
