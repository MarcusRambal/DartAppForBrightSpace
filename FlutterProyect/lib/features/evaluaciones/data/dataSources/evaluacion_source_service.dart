import 'dart:convert';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/i_local_preferences.dart';
import 'i_evaluacion_source.dart';
import '../models/evaluacion_model.dart';

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
  ) async {
    try {
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
          "tableName": "Evaluacion",
          "records": [
            {
              "idEvaluacion": idEvaluacion,
              "idCategoria": idCategoria,
              "tipo": tipo,
              "fechaCreacion": fechaCreacion,
              "fechaFinalizacion": fechaFinalizacion,
            },
          ],
        }),
      );

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
        "tableName": "Evaluacion",
        "idCategoria": idCategoria,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> records = data['data'];

        return records
            .map(
              (e) => EvaluacionModel.fromJson({
                // 🔥 Adaptamos el JSON al model
                'id': e['idEvaluacion'],
                'idCategoria': e['idCategoria'],
                'tipo': e['tipo'],
                'fechaCreacion': e['fechaCreacion'],
                'fechaFinalizacion': e['fechaFinalizacion'],
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
              r.idPregunta, // para evitar duplicados
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
        body: jsonEncode({"tableName": "Respuesta", "records": records}),
      );

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

      final url = Uri.https(baseUrl, '/database/$contract/read', {
        "tableName": "Respuesta",
        "idEvaluacion": idEvaluacion,
        "idEvaluador": idEvaluador,
        "idEvaluado": idEvaluado,
      });

      final response = await httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> records = data['data'];

        return records.isNotEmpty;
      } else {
        throw Exception("Error al validar evaluación");
      }
    } catch (e) {
      logError("Error en yaEvaluo: $e");
      rethrow;
    }
  }
}
