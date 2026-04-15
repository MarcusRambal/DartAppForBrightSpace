//FlutterProyect/lib/features/evaluaciones/data/dataSources/evaluacion_source_service.dart
import 'dart:convert';
import 'package:flutter_prueba/features/reportes/domain/entities/reporteGrupalPorCategoria_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reporteGrupalPorEvaluacion_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reportePersonalPorCategoria_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reportePersonalPorEvaluacion_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reportePromedioPersonalPorCategoria_entity.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/i_local_preferences.dart';
import 'i_reporte_source.dart';
import '../models/reporte_grupal_por_categoria_model.dart';
import '../models/reporte_grupal_por_evaluacion_model.dart';
import '../models/reporte_personal_por_categoria_model.dart';
import '../models/reporte_personal_por_evaluacion_model.dart';
import '../models/reporte_promedio_personal_por_categoria_model.dart';

class ReporteSourceService implements IReporteSource {
  final http.Client httpClient;
  final contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  ReporteSourceService({http.Client? client})
    : httpClient = client ?? http.Client();

  Future<String> _getValidToken() async {
    final ILocalPreferences sharedPreferences = Get.find();
    String? token = await sharedPreferences.getString('token');
    if (token == null) throw Exception("No hay token disponible");
    return token;
  }

  @override
  Future<void> createReporteGrupalPorCategoria({
    required String idCategoria,
    required String idGrupo,
    required String nota,
    required String idCurso,
  }) async {
    try {
      print("entre");
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/insert');

      // 🔥 Generar ID manual (igual que categoria)
      final String idReporteGrupalPorCategoria =
          DateTime.now().millisecondsSinceEpoch.toString() +
          idCategoria +
          idGrupo;

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reporteGrupalPorCategoria",
          "records": [
            {
              "idReporteGrupalPorCategoria": idReporteGrupalPorCategoria,
              "idCategoria": idCategoria,
              "nota": nota,
              "idGrupo": idGrupo,
              "idCurso": idCurso,
            },
          ],
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(idReporteGrupalPorCategoria);
      } else {
        throw Exception("Error al crear evaluación: ${response.body}");
      }
    } catch (e) {
      logError("Error en createEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<void> createReporteGrupalPorEvaluacion({
    required String idEvaluacion,
    required String idGrupo,
    required String nota,
  }) async {
    try {
      print("entre");
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/insert');

      // 🔥 Generar ID manual (igual que categoria)
      final String idReporteGrupalPorEvaluacion =
          DateTime.now().millisecondsSinceEpoch.toString() +
          idEvaluacion +
          idGrupo;

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reporteGrupalPorEvaluacion",
          "records": [
            {
              "idReporteGrupalPorEvaluacion": idReporteGrupalPorEvaluacion,
              "idEvaluacion": idEvaluacion,
              "nota": nota,
              "idGrupo": idGrupo,
            },
          ],
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(idReporteGrupalPorEvaluacion);
      } else {
        throw Exception("Error al crear evaluación: ${response.body}");
      }
    } catch (e) {
      logError("Error en createEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<void> createReportePersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  }) async {
    try {
      print("entre");
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/insert');

      // 🔥 Generar ID manual (igual que categoria)
      final String idReportePersonalPorCategoria =
          DateTime.now().millisecondsSinceEpoch.toString() +
          idCategoria +
          idEstudiante;

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reportePersonalPorCategoria",
          "records": [
            {
              "idReportePersonalPorCategoria": idReportePersonalPorCategoria,
              "idCategoria": idCategoria,
              "notaPuntualidad": notaPuntualidad,
              "idEstudiante": idEstudiante,
              "notaContribucion": notaContribucion,
              "notaActitud": notaActitud,
              "notaCompromiso": notaCompromiso,
            },
          ],
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(idReportePersonalPorCategoria);
      } else {
        throw Exception("Error al crear evaluación: ${response.body}");
      }
    } catch (e) {
      logError("Error en createEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<void> createReportePersonalPorEvaluacion({
    required String idEvaluacion,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  }) async {
    try {
      print("entre");
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/insert');

      // 🔥 Generar ID manual (igual que categoria)
      final String idReportePersonalPorEvaluacion =
          DateTime.now().millisecondsSinceEpoch.toString() +
          idEvaluacion +
          idEstudiante;

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reportePersonalPorEvaluacion",
          "records": [
            {
              "idReportePersonalPorEvaluacion": idReportePersonalPorEvaluacion,
              "idEvaluacion": idEvaluacion,
              "notaPuntualidad": notaPuntualidad,
              "idEstudiante": idEstudiante,
              "notaContribucion": notaContribucion,
              "notaActitud": notaActitud,
              "notaCompromiso": notaCompromiso,
            },
          ],
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(idReportePersonalPorEvaluacion);
      } else {
        throw Exception("Error al crear evaluación: ${response.body}");
      }
    } catch (e) {
      logError("Error en createEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<void> createReportePromedioPersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
    required String nota,
    required String idCurso,
  }) async {
    try {
      print("entre");
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/insert');

      // 🔥 Generar ID manual (igual que categoria)
      final String idReportePromedioPersonalPorCategoria =
          DateTime.now().millisecondsSinceEpoch.toString() +
          idCategoria +
          idEstudiante +
          idCurso;

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reportePromedioPersonalPorCategoria",
          "records": [
            {
              "idReportePromedioPersonalPorCategoria":
                  idReportePromedioPersonalPorCategoria,
              "idCategoria": idCategoria,
              "idEstudiante": idEstudiante,
              "nota": nota,
              "idCurso": idCurso,
            },
          ],
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(idReportePromedioPersonalPorCategoria);
      } else {
        throw Exception("Error al crear evaluación: ${response.body}");
      }
    } catch (e) {
      logError("Error en createEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<ReportePersonalPorCategoriaModel> getReportePersonalPorCategoria({
    required String idEstudiante,
    required String idCategoria,
  }) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reportePersonalPorCategoria",
        "idEstudiante": idEstudiante,
        "idCategoria": idCategoria,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Puede venir como lista, tomamos el primero
        final List<dynamic> records = data;

        if (records.isEmpty) {
          throw Exception("No se encontró el reporte");
        }

        final e = records.first;

        return ReportePersonalPorCategoriaModel.fromJson({
          'idReportePersonal': e['idReportePersonalPorCategoria'],
          'idCategoria': e['idCategoria'],
          'idEstudiante': e['idEstudiante'],
          'notaPuntualidad': e['notaPuntualidad'],
          'notaContribucion': e['notaContribucion'],
          'notaActitud': e['notaActitud'],
          'notaCompromiso': e['notaCompromiso'],
        });
      } else {
        throw Exception("Error al obtener reporte: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportePersonalPorCategoria: $e");
      rethrow;
    }
  }

  @override
  Future<ReportePersonalPorEvaluacionModel> getReportePersonalPorEvaluacion({
    required String idEstudiante,
    required String idEvaluacion,
  }) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reportePersonalPorEvaluacion",
        "idEstudiante": idEstudiante,
        "idEvaluacion": idEvaluacion,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        if (records.isEmpty) {
          throw Exception("No se encontró el reporte");
        }

        final e = records.first;

        return ReportePersonalPorEvaluacionModel.fromJson({
          'idReportePersonal': e['idReportePersonalPorEvaluacion'],
          'idEvaluacion': e['idEvaluacion'],
          'idEstudiante': e['idEstudiante'],
          'notaPuntualidad': e['notaPuntualidad'],
          'notaContribucion': e['notaContribucion'],
          'notaActitud': e['notaActitud'],
          'notaCompromiso': e['notaCompromiso'],
        });
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportePersonalPorEvaluacion: $e");
      rethrow;
    }
  }

  //NUEVOOOOOOO
  @override
  Future<ReporteGrupalPorCategoriaModel> getReporteGrupalPorCategoria(
    String idCategoria,
    String idGrupo,
  ) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reporteGrupalPorCategoria",
        "idCategoria": idCategoria,
        "idGrupo": idGrupo,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        if (records.isEmpty) {
          throw Exception("No existe el reporte");
        }

        final e = records.first;

        return ReporteGrupalPorCategoriaModel.fromJson({
          'idReporteGrupal': e['idReporteGrupalPorCategoria'],
          'idCategoria': e['idCategoria'],
          'idGrupo': e['idGrupo'],
          'nota': e['nota'],
          'idCurso': e['idCurso'],
        });
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReporteGrupalPorCategoria: $e");
      rethrow;
    }
  }

  @override
  Future<ReporteGrupalPorEvaluacionModel> getReporteGrupalPorEvaluacion(
    String idEvaluacion,
    String idGrupo,
  ) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reporteGrupalPorEvaluacion",
        "idEvaluacion": idEvaluacion,
        "idGrupo": idGrupo,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        if (records.isEmpty) {
          throw Exception("No existe el reporte");
        }

        final e = records.first;

        return ReporteGrupalPorEvaluacionModel.fromJson({
          'idReporteGrupal': e['idReporteGrupalPorEvaluacion'],
          'idEvaluacion': e['idEvaluacion'],
          'idGrupo': e['idGrupo'],
          'nota': e['nota'],
        });
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReporteGrupalPorEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<ReportePromedioPersonalPorCategoriaModel>
  getReportePromedioPersonalPorCategoria(
    String idCategoria,
    String idEstudiante,
  ) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reportePromedioPersonalPorCategoria",
        "idCategoria": idCategoria,
        "idEstudiante": idEstudiante,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        if (records.isEmpty) {
          throw Exception("No existe el reporte promedio");
        }

        final e = records.first;

        return ReportePromedioPersonalPorCategoriaModel.fromJson({
          'idReportePromedioPersonal':
              e['idReportePromedioPersonalPorCategoria'],
          'idCategoria': e['idCategoria'],
          'idEstudiante': e['idEstudiante'],
          'nota': e['nota'],
          'idCurso': e['idCurso'],
        });
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportePromedioPersonalPorCategoria: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReporteGrupalPorCategoriaModel>> getReportesGrupalesPorCategoria(
    String idCategoria,
  ) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reporteGrupalPorCategoria",
        "idCategoria": idCategoria,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        return records.map((e) {
          return ReporteGrupalPorCategoriaModel.fromJson({
            'idReporteGrupal': e['idReporteGrupalPorCategoria'],
            'idCategoria': e['idCategoria'],
            'idGrupo': e['idGrupo'],
            'nota': e['nota'],
            'idCurso': e['idCurso'],
          });
        }).toList();
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportesGrupalesPorCategoria: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReporteGrupalPorEvaluacionModel>>
  getReportesGrupalesPorEvaluacion(String idEvaluacion) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reporteGrupalPorEvaluacion",
        "idEvaluacion": idEvaluacion,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        return records.map((e) {
          return ReporteGrupalPorEvaluacionModel.fromJson({
            'idReporteGrupal': e['idReporteGrupalPorEvaluacion'],
            'idEvaluacion': e['idEvaluacion'],
            'idGrupo': e['idGrupo'],
            'nota': e['nota'],
          });
        }).toList();
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportesGrupalesPorEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReporteGrupalPorCategoriaModel>> getReportesGrupalesTodos(
    String idCurso,
  ) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reporteGrupalPorCategoria", // ⚠️ misma tabla
        "idCurso": idCurso, // ⚠️ revisar si existe este filtro en backend
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        return records.map((e) {
          return ReporteGrupalPorCategoriaModel.fromJson({
            'idReporteGrupal': e['idReporteGrupalPorCategoria'],
            'idCategoria': e['idCategoria'],
            'idGrupo': e['idGrupo'],
            'nota': e['nota'],
            'idCurso': e['idCurso'],
          });
        }).toList();
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportesGrupalesTodos: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReportePersonalPorCategoriaModel>>
  getReportesPersonalPorCategoria(String idCategoria) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reportePersonalPorCategoria",
        "idCategoria": idCategoria,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        return records.map((e) {
          return ReportePersonalPorCategoriaModel.fromJson({
            'idReportePersonal':
                e['idReportePersonalPorCategoria'], // ⚠️ revisar
            'idCategoria': e['idCategoria'],
            'idEstudiante': e['idEstudiante'],
            'notaPuntualidad': e['notaPuntualidad'],
            'notaContribucion': e['notaContribucion'],
            'notaActitud': e['notaActitud'],
            'notaCompromiso': e['notaCompromiso'],
          });
        }).toList();
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportesPersonalPorCategoria: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReportePersonalPorEvaluacionModel>>
  getReportesPersonalPorEvaluacion(String idEvaluacion) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reportePersonalPorEvaluacion",
        "idEvaluacion": idEvaluacion,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        return records.map((e) {
          return ReportePersonalPorEvaluacionModel.fromJson({
            'idReportePersonal':
                e['idReportePersonalPorEvaluacion'], // ⚠️ revisar
            'idEvaluacion': e['idEvaluacion'],
            'idEstudiante': e['idEstudiante'],
            'notaPuntualidad': e['notaPuntualidad'],
            'notaContribucion': e['notaContribucion'],
            'notaActitud': e['notaActitud'],
            'notaCompromiso': e['notaCompromiso'],
          });
        }).toList();
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportesPersonalPorEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReportePromedioPersonalPorCategoriaModel>>
  getReportesPromedioPersonalCategoriaTodos(String idCurso) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "reportePromedioPersonalPorCategoria", // ⚠️ revisar tabla
        "idCurso": idCurso,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        return records.map((e) {
          return ReportePromedioPersonalPorCategoriaModel.fromJson({
            'idReportePromedioPersonal':
                e['idReportePromedioPersonalPorCategoria'], // ⚠️ revisar
            'idReportePersonal':
                e['idReportePersonalPorCategoria'], // ⚠️ revisar FK
            'nota': e['nota'],
            'idCurso': e['idCurso'],
          });
        }).toList();
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      logError("Error en getReportesPromedioPersonalCategoriaTodos: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateReporteGrupalPorCategoria({
    required String idReporteGrupal,
    required String idCategoria,
    required String idGrupo,
    required String nota,
    required String idCurso,
  }) async {
    try {
      final token = await _getValidToken();

      // 🔥 USAR TU GET
      final reporte = await getReporteGrupalPorCategoria(idCategoria, idGrupo);

      final String idReporteGrupalEncontrado = reporte.idReporteGrupal;

      final urlUpdate = Uri.https(baseUrl, '/database/$contract/update');

      final responseUpdate = await httpClient.put(
        urlUpdate,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reporteGrupalPorCategoria",
          "idColumn": "idReporteGrupalPorCategoria",
          "idValue": idReporteGrupalEncontrado,
          "updates": {"nota": nota},
        }),
      );

      if (responseUpdate.statusCode != 200) {
        throw Exception("Error al actualizar: ${responseUpdate.body}");
      }
    } catch (e) {
      logError("Error en updateReporteGrupalPorCategoria: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateReporteGrupalPorEvaluacion({
    required String idReporteGrupal,
    required String idEvaluacion,
    required String idGrupo,
    required String nota,
  }) async {
    try {
      final token = await _getValidToken();

      // 🔥 USAR TU GET
      final reporte = await getReporteGrupalPorEvaluacion(
        idEvaluacion,
        idGrupo,
      );

      final String idReporteGrupalEncontrado = reporte.idReporteGrupal;

      final urlUpdate = Uri.https(baseUrl, '/database/$contract/update');

      final responseUpdate = await httpClient.put(
        urlUpdate,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reporteGrupalPorEvaluacion",
          "idColumn": "idReporteGrupalPorEvaluacion",
          "idValue": idReporteGrupalEncontrado,
          "updates": {"nota": nota},
        }),
      );

      if (responseUpdate.statusCode != 200) {
        throw Exception("Error al actualizar: ${responseUpdate.body}");
      }
    } catch (e) {
      logError("Error en updateReporteGrupalPorEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateReportePersonalPorCategoria({
    required String idReportePersonal,
    required String idCategoria,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  }) async {
    try {
      final token = await _getValidToken();

      // 🔍 1. Obtener el reporte usando tu GET existente
      final reporte = await getReportePersonalPorCategoria(
        idEstudiante: idEstudiante,
        idCategoria: idCategoria,
      );

      final String idReportePersonalEncontrado = reporte
          .idReportePersonal; // ⚠️ viene de e['idReportePersonalPorCategoria']

      // ✏️ 2. UPDATE
      final url = Uri.https(baseUrl, '/database/$contract/update');

      final response = await httpClient.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reportePersonalPorCategoria", // ⚠️ revisar tabla
          "idColumn":
              "idReportePersonalPorCategoria", // ⚠️ revisar nombre real en BD
          "idValue": idReportePersonalEncontrado,
          "updates": {
            "notaPuntualidad": notaPuntualidad,
            "notaContribucion": notaContribucion,
            "notaActitud": notaActitud,
            "notaCompromiso": notaCompromiso,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Error al actualizar: ${response.body}");
      }
    } catch (e) {
      logError("Error en updateReportePersonalPorCategoria: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateReportePersonalPorEvaluacion({
    required String idReportePersonal,
    required String idEvaluacion,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  }) async {
    try {
      final token = await _getValidToken();

      // 🔍 1. Obtener el reporte usando tu GET existente
      final reporte = await getReportePersonalPorEvaluacion(
        idEstudiante: idEstudiante,
        idEvaluacion: idEvaluacion,
      );

      final String idReportePersonalEncontrado = reporte
          .idReportePersonal; // ⚠️ viene de e['idReportePersonalPorEvaluacion']

      // ✏️ 2. Hacer el UPDATE
      final url = Uri.https(baseUrl, '/database/$contract/update');

      final response = await httpClient.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reportePersonalPorEvaluacion", // ⚠️ revisar tabla
          "idColumn":
              "idReportePersonalPorEvaluacion", // ⚠️ revisar nombre ID en BD
          "idValue": idReportePersonalEncontrado,
          "updates": {
            "notaPuntualidad": notaPuntualidad,
            "notaContribucion": notaContribucion,
            "notaActitud": notaActitud,
            "notaCompromiso": notaCompromiso,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Error al actualizar: ${response.body}");
      }
    } catch (e) {
      logError("Error en updateReportePersonalPorEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateReportePromedioPersonalPorCategoria({
    required String idReportePromedioPersonal,
    required String idCategoria,
    required String idEstudiante,
    required String nota,
    required String idCurso,
  }) async {
    try {
      final token = await _getValidToken();

      // 🔥 USAR TU GET
      final reporte = await getReportePromedioPersonalPorCategoria(
        idCategoria,
        idEstudiante,
      );

      final String idReportePromedioEncontrado =
          reporte.idReportePromedioPersonal;

      final urlUpdate = Uri.https(baseUrl, '/database/$contract/update');

      final responseUpdate = await httpClient.put(
        urlUpdate,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "reportePromedioPersonalPorCategoria",
          "idColumn": "idReportePromedioPersonalPorCategoria",
          "idValue": idReportePromedioEncontrado,
          "updates": {"nota": nota},
        }),
      );

      if (responseUpdate.statusCode != 200) {
        throw Exception("Error al actualizar: ${responseUpdate.body}");
      }
    } catch (e) {
      logError("Error en updateReportePromedioPersonalPorCategoria: $e");
      rethrow;
    }
  }
}
