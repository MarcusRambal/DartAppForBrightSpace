// FlutterProyect/lib/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/evaluacion_entity.dart';
import '../../domain/entities/respuesta_entity.dart';
import '../../domain/entities/pregunta_entity.dart';
import '../../domain/repositories/i_evaluacion_repository.dart';
import '../../../../features/cursos/domain/repositories/i_curso_repository.dart';
import '../../../../../core/i_local_preferences.dart';

class EvaluacionController extends GetxController {
  final IEvaluacionRepository repository;
  final ICursoRepository cursoRepository; // 🔥 NUEVO

  EvaluacionController({
    required this.repository,
    required this.cursoRepository,
  });

  // --- ESTADOS REACTIVOS ---
  var evaluaciones = <EvaluacionEntity>[].obs;
  var preguntas = <PreguntaEntity>[].obs;

  var isLoading = false.obs;
  var isLoadingPreguntas = false.obs;

  var isCreating = false.obs;
  var isSending = false.obs;

  var respuestas = <RespuestaEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  bool estaVigente(EvaluacionEntity e) {
    final ahora = DateTime.now();
    return ahora.isAfter(e.fechaCreacion) &&
        ahora.isBefore(e.fechaFinalizacion);
  }

  // --- CARGAR EVALUACIONES ---
  Future<void> cargarEvaluaciones(String idCategoria) async {
    try {
      isLoading.value = true;

      final result = await repository.getEvaluacionesByProfe(idCategoria);
      evaluaciones.value = result;
    } catch (e) {
      logError("Error cargando evaluaciones: $e");
      Get.snackbar("Error", "No se pudieron cargar las evaluaciones");
    } finally {
      isLoading.value = false;
    }
  }

  // --- CARGAR PREGUNTAS ---
  Future<void> cargarPreguntas() async {
    try {
      isLoadingPreguntas.value = true;

      final result = await repository.getPreguntas();
      preguntas.value = result;
    } catch (e) {
      logError("Error cargando preguntas: $e");
      Get.snackbar("Error", "No se pudieron cargar las preguntas");
    } finally {
      isLoadingPreguntas.value = false;
    }
  }

  // --- CREAR EVALUACION ---
  Future<void> crearEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
    bool esPrivada,
  ) async {
    try {
      isCreating.value = true;

      await repository.createEvaluacion(
        idCategoria,
        tipo,
        fechaCreacion,
        fechaFinalizacion,
        nom,
        esPrivada,
      );

      Get.snackbar(
        "Éxito",
        "Evaluación creada correctamente",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logError("Error creando evaluación: $e");
      Get.snackbar(
        "Error",
        "No se pudo crear la evaluación",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  // --- RESPUESTAS ---
  void agregarRespuesta(RespuestaEntity respuesta) {
    respuestas.add(respuesta);
  }

  void limpiarRespuestas() {
    respuestas.clear();
  }

  Future<void> enviarRespuestas() async {
    try {
      isSending.value = true;

      await repository.createRespuestas(respuestas);

      Get.snackbar(
        "Éxito",
        "Respuestas enviadas correctamente",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      limpiarRespuestas();
    } catch (e) {
      logError("Error enviando respuestas: $e");
      Get.snackbar(
        "Error",
        "No se pudieron enviar las respuestas",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  // --- VALIDAR SI YA EVALUO ---
  Future<bool> yaEvaluo(
    String idEvaluacion,
    String idEvaluador,
    String idEvaluado,
  ) async {
    try {
      return await repository.yaEvaluo(idEvaluacion, idEvaluador, idEvaluado);
    } catch (e) {
      logError("Error validando evaluación: $e");
      return false;
    }
  }

  var evaluacionesIncompletas = <EvaluacionEntity>[].obs;
  bool _calculandoIncompletas = false;
  // 🔥 MÉTODO CLAVE (MISMA LÓGICA, SIN OTRO CONTROLLER)
  Future<void> cargarEvaluacionesIncompletasPorGrupos(
    List<dynamic> grupos,
  ) async {
    // 🔥 evita doble ejecución (causa del error + contador en 0)
    if (_calculandoIncompletas) return;

    try {
      _calculandoIncompletas = true;

      isLoading.value = true;

      final List<EvaluacionEntity> acumuladas = [];

      final prefs = Get.find<ILocalPreferences>();
      final miId = await prefs.getString('email');

      if (miId == null) {
        throw Exception("Usuario no autenticado");
      }

      final Map<String, List<String>> cacheCompaneros = {};

      for (final g in grupos) {
        final idCat = g.idCat.toString();
        final nombreGrupo = g.grupoNombre.toString();

        if (!cacheCompaneros.containsKey(idCat)) {
          final companeros = await cursoRepository.getCompanerosDeGrupo(
            idCat,
            nombreGrupo,
          );
          cacheCompaneros[idCat] = companeros;
        }

        final companeros = cacheCompaneros[idCat]!;

        final evaluacionesList = await repository.getEvaluacionesByProfe(idCat);

        for (var evaluacion in evaluacionesList) {
          if (!estaVigente(evaluacion)) continue;

          bool completa = true;

          for (var evaluado in companeros) {
            if (evaluado.trim().toLowerCase() == miId.trim().toLowerCase()) {
              continue;
            }

            final ya = await repository.yaEvaluo(
              evaluacion.id.toString(),
              miId,
              evaluado,
            );

            if (!ya) {
              completa = false;
              break;
            }
          }

          if (!completa) {
            acumuladas.add(evaluacion);
          }
        }
      }

      // 🔥 IMPORTANTE: update seguro fuera del build cycle
      evaluacionesIncompletas.assignAll(acumuladas);
    } catch (e) {
      logError("Error batch incompletas: $e");
    } finally {
      isLoading.value = false;
      _calculandoIncompletas = false;
    }
  }

  Future<void> cambiarPrivacidad(
    String idEvaluacion,
    bool esPrivadaActual,
  ) async {
    try {
      final nuevoEstado = !esPrivadaActual;

      // 1. Cambio local inmediato (Optimista)
      int index = evaluaciones.indexWhere((e) => e.id == idEvaluacion);
      if (index != -1) {
        evaluaciones[index].esPrivada = nuevoEstado;
        evaluaciones.refresh();
      }

      // 2. Llamamos al repositorio con el ID correcto y el nuevo estado
      await repository.updatePrivacidad(idEvaluacion, nuevoEstado);

      Get.snackbar(
        "Éxito",
        "La evaluación ahora es ${nuevoEstado ? 'Privada' : 'Pública'}",
        backgroundColor: nuevoEstado ? Colors.orange : Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("❌ Error: $e");
      // Revertimos si falla
      int index = evaluaciones.indexWhere((e) => e.id == idEvaluacion);
      if (index != -1) {
        evaluaciones[index].esPrivada = esPrivadaActual;
        evaluaciones.refresh();
      }
      Get.snackbar("Error", "No se pudo sincronizar el cambio con Roble");
    }
  }

  bool estaCompleta(String idEvaluacion) {
    return false;
  }
}
