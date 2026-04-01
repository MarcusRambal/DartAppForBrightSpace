import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/entities/evaluacion_entity.dart';
import '../../domain/entities/respuesta_entity.dart';
import '../../domain/repositories/i_evaluacion_repository.dart';

class EvaluacionController extends GetxController {
  final IEvaluacionRepository repository;

  EvaluacionController({required this.repository});

  // --- ESTADOS REACTIVOS ---
  var evaluaciones = <EvaluacionEntity>[].obs;
  var isLoading = false.obs;

  var isCreating = false.obs;
  var isSending = false.obs;

  // --- RESPUESTAS EN MEMORIA ---
  var respuestas = <RespuestaEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  // --- CARGAR EVALUACIONES (INDEPENDIENTE) ---
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

  // --- CREAR EVALUACION (SIN RECARGA AUTOMATICA) ---
  Future<void> crearEvaluacion(
    String idCategoria,
    String tipo,
    String fechaCreacion,
    String fechaFinalizacion,
    String nom,
  ) async {
    try {
      isCreating.value = true;

      await repository.createEvaluacion(
        idCategoria,
        tipo,
        fechaCreacion,
        fechaFinalizacion,
        nom,
      );

      Get.snackbar(
        "Éxito",
        "Evaluación creada correctamente",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ❌ YA NO SE LLAMA cargarEvaluaciones AQUÍ

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

  // --- AGREGAR RESPUESTA EN MEMORIA ---
  void agregarRespuesta(RespuestaEntity respuesta) {
    respuestas.add(respuesta);
  }

  // --- LIMPIAR RESPUESTAS ---
  void limpiarRespuestas() {
    respuestas.clear();
  }

  // --- ENVIAR RESPUESTAS ---
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
      
      return await repository.yaEvaluo(
        idEvaluacion,
        idEvaluador,
        idEvaluado,
      );
    } catch (e) {
      logError("Error validando evaluación: $e");
      return false;
    }
  }
  
}