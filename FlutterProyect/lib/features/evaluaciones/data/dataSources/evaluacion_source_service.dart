//FlutterProyect/lib/features/evaluaciones/data/dataSources/evaluacion_source_service.dart
import 'dart:convert';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/i_local_preferences.dart';
import 'i_evaluacion_source.dart';
import '../models/evaluacion_model.dart';
import '../models/pregunta_model.dart';

class EvaluacionSourceService implements IEvaluacionSource {
  final http.Client httpClient;
  final contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  EvaluacionSourceService({http.Client? client})
    : httpClient = client ?? http.Client();

  Future<String> _getValidToken() async {
    final ILocalPreferences sharedPreferences = Get.find();
    String? token = await sharedPreferences.getString('token');
    if (token == null) throw Exception("No hay token disponible");
    return token;
  }

  @override
  Future<String> createEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  ) async {
    try {
      print("entre");
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/insert');

      // 🔥 Generar ID manual (igual que categoria)
      final String idEvaluacion = DateTime.now().millisecondsSinceEpoch
          .toString();

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "tableName": "evaluacion",
          "records": [
            {
              "idEvaluacion": idEvaluacion,
              "idCategoria": idCategoria,
              "tipo": esPrivada ? "Privada" : tipo,
              "fechaCreacion": fechaCreacion,
              "fechaFinalizacion": fechaFinalizacion,
              "nom": nom,
            },
          ],
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return idEvaluacion;
      } else {
        throw Exception("Error al crear evaluación: ${response.body}");
      }
    } catch (e) {
      logError("Error en createEvaluacion: $e");
      rethrow;
    }
  }

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(
    String idCategoria,
  ) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "evaluacion",
        "idCategoria": idCategoria,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 CORRECCIÓN AQUÍ
        final List<dynamic> records = data;

        return records
            .map(
              (e) => EvaluacionModel.fromJson({
                'id': int.tryParse(e['idEvaluacion'].toString()) ?? 0,
                'idCategoria': e['idCategoria'],
                'tipo': e['tipo'],
                'fechaCreacion': e['fechaCreacion'],
                'fechaFinalizacion': e['fechaFinalizacion'],
                'nom': e['nom'],
                'esPrivada': e['tipo'] == 'Privada',
              }),
            )
            .toList();
      } else {
        throw Exception("Error al obtener evaluaciones: ${response.body}");
      }
    } catch (e) {
      logError("Error en getEvaluacionesByProfe: $e");
      rethrow;
    }
  }

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/insert');

      // 🔥 Generar IDs manuales
      final records = respuestas.map((r) {
        return {
          "idRespuesta":
              DateTime.now().millisecondsSinceEpoch.toString() +
              r.idPregunta +
              r.idEvaluacion +
              r.idEvaluado +
              r.idEvaluador, // para evitar duplicados
          "idEvaluacion": r.idEvaluacion,
          "idEvaluador": r.idEvaluador,
          "idEvaluado": r.idEvaluado,
          "idPregunta": r.idPregunta,
          "tipo": r.tipo,
          "valor_comentario": r.valorComentario,
        };
      }).toList();

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"tableName": "respuesta", "records": records}),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Error al crear respuestas: ${response.body}");
      }
    } catch (e) {
      logError("Error en createRespuestas: $e");
      rethrow;
    }
  }

  @override
  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  ) async {
    try {
      final token = await _getValidToken();
      final prefs = Get.find<ILocalPreferences>();

      final idEs = await prefs.getString('userId');
      final correoEs = await prefs.getString('email');
      print("correo");
      print(correoEs);
      if (idEs == null) throw Exception("Usuario no autenticado");
      idEvaluador = idEs;
      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "respuesta",
        "idEvaluacion": idEvaluacion,
        "idEvaluador": idEvaluador,
        "idEvaluado": idEvaluado,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("========== RESPONSE ==========");
      print(response.body);
      print("STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("TIPO data: ${data.runtimeType}");
        print("DATA: $data");

        // 🔥 Aquí validamos TODO
        if (data is List) {
          print("ES UNA LISTA");
          return data.isNotEmpty;
        } else if (data is Map) {
          print("ES UN MAP");
          print("CLAVES: ${data.keys}");

          if (data.containsKey('data')) {
            print("data['data']: ${data['data']}");
            print("TIPO data['data']: ${data['data'].runtimeType}");

            final inner = data['data'];

            if (inner is List) {
              return inner.isNotEmpty;
            } else {
              throw Exception("data['data'] no es lista");
            }
          } else {
            throw Exception("No existe la clave 'data'");
          }
        } else {
          throw Exception("Formato desconocido");
        }
      } else {
        throw Exception("Error al validar evaluación: ${response.body}");
      }
    } catch (e) {
      print("🔥 ERROR DETECTADO: $e");
      logError("Error en yaEvaluo: $e");
      rethrow;
    }
  }

  @override
  Future<List<PreguntaEntity>> getPreguntas() async {
    try {
      final token = await _getValidToken();

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "Pregunta",
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 CORRECCIÓN AQUÍ
        final List<dynamic> records = data;

        return records
            .map(
              (e) => PreguntaModel.fromJson({
                'idPregunta': int.tryParse(e['idPregunta'].toString()) ?? 0,
                'tipo': e['tipo'],
                'pregunta': e['pregunta'],
              }),
            )
            .toList();
      } else {
        throw Exception("Error al obtener preguntas: ${response.body}");
      }
    } catch (e) {
      logError("Error en getEvaluacionesByProfe: $e");
      rethrow;
    }
  }

Future<List<String>> getNotasPorEvaluado(
  String idEvaluacion,
  String idEvaluado,
  String tipo,
) async {
  try {
    print("\n========== getNotasPorEvaluado ==========");
    print("idEvaluacion: $idEvaluacion");
    print("idEvaluado: $idEvaluado");
    print("tipo: $tipo");

    final token = await _getValidToken();

    final url = Uri.https(baseUrl, '/database/$contract/read', {
      "tableName": "respuesta",
      "idEvaluacion": idEvaluacion,
      "idEvaluado": idEvaluado,
      "tipo": tipo,
    });

    print("URL: $url");

    final response = await httpClient.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY RAW: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> records = jsonDecode(response.body);

      print("CANTIDAD RECORDS: ${records.length}");

      for (var r in records) {
        print("RECORD: $r");
      }

      final notas = records.map<String>((e) {
        final valor = e['valor_comentario'];
        print("VALOR EXTRAIDO: $valor");
        return valor.toString();
      }).toList();

      print("NOTAS FINALES: $notas");
      print("========================================\n");

      return notas;
    } else {
      print("❌ ERROR RESPONSE: ${response.body}");
      throw Exception("Error al obtener notas");
    }
  } catch (e) {
    print("❌ EXCEPCIÓN en getNotasPorEvaluado: $e");
    logError("Error en getNotasPorEvaluado: $e");
    rethrow;
  }
}
}
