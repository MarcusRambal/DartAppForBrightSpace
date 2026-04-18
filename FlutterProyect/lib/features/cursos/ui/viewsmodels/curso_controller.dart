//FlutterProyect/lib/features/cursos/ui/viewsmodels/curso_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/entities/curso_curso.dart';
import '../../domain/repositories/i_curso_repository.dart';

class CursoController extends GetxController {
  final ICursoRepository repository;

  CursoController({required this.repository});

  // --- ESTADOS REACTIVOS ---
  var cursos = <CursoCurso>[].obs;
  var isLoading = false.obs;


//Funcion para la cantidad de cursos
  int get cantidadCursos => cursos.length;

  var isCreating = false.obs;
  var isUpdating = false.obs;
  var isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    cargarCursos();
  }

  // --- CARGAR CURSOS ---
  Future<void> cargarCursos() async {
    try {
      isLoading.value = true;
      final result = await repository.getCursosByProfe();
      cursos.value = result;
    } catch (e) {
      logError("Error cargando cursos: $e");
      Get.snackbar("Error", "No se pudieron cargar los cursos");
    } finally {
      isLoading.value = false;
    }
  }

  // --- CREAR CURSO ---
  Future<void> crearCurso(String idCurso, String nombre) async {
    try {
      isCreating.value = true;
      await repository.createCurso(idCurso, nombre);
      Get.snackbar(
        "Éxito",
        "Curso creado correctamente",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await cargarCursos(); // Refresca la lista automáticamente
    } catch (e) {
      logError("Error creando curso: $e");
      Get.snackbar(
        "Error",
        "No se pudo crear el curso",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  // --- ACTUALIZAR NOMBRE DEL CURSO ---
  Future<void> actualizarCurso(CursoCurso curso, String nuevoNombre) async {
    try {
      isUpdating.value = true;
      await repository.updateCurso(curso, nuevoNombre);
      Get.snackbar(
        "Éxito",
        "Curso actualizado",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await cargarCursos();
    } catch (e) {
      logError("Error actualizando curso: $e");
      Get.snackbar(
        "Error",
        "No se pudo actualizar el nombre",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // --- ELIMINAR CURSO (En Cascada) ---
  Future<void> eliminarCurso(String idCurso) async {
    try {
      isDeleting.value = true;
      Get.snackbar(
        "Eliminando",
        "Borrando curso y grupos...",
        showProgressIndicator: true,
        snackPosition: SnackPosition.BOTTOM,
      );

      await repository.deleteCurso(idCurso);

      Get.snackbar(
        "Éxito",
        "Curso eliminado correctamente",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await cargarCursos(); // Refresca la lista de la pantalla
    } catch (e) {
      logError("Error eliminando curso: $e");
      Get.snackbar(
        "Error",
        "No se pudo eliminar el curso",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }
}
