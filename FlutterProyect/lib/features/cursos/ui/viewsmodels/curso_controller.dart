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

  // --- OPCIONAL (para UI) ---
  var isCreating = false.obs;
  var isUpdating = false.obs;
  var isDeleting = false.obs;

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

      Get.snackbar("Éxito", "Curso creado correctamente");

      await cargarCursos(); // 🔥 refresca

    } catch (e) {
      logError("Error creando curso: $e");
      Get.snackbar("Error", "No se pudo crear el curso");
    } finally {
      isCreating.value = false;
    }
  }

  // --- ACTUALIZAR CURSO ---
  Future<void> actualizarCurso(CursoCurso curso, String nuevoNombre) async {
    try {
      isUpdating.value = true;

      await repository.updateCurso(curso, nuevoNombre);

      Get.snackbar("Éxito", "Curso actualizado");

      await cargarCursos();

    } catch (e) {
      logError("Error actualizando curso: $e");
      Get.snackbar("Error", "No se pudo actualizar");
    } finally {
      isUpdating.value = false;
    }
  }

  // --- ELIMINAR CURSO ---
  Future<void> eliminarCurso(String idCurso) async {
    try {
      isDeleting.value = true;

      await repository.deleteCurso(idCurso);

      Get.snackbar("Éxito", "Curso eliminado");

      await cargarCursos();

    } catch (e) {
      logError("Error eliminando curso: $e");
      Get.snackbar("Error", "No se pudo eliminar");
    } finally {
      isDeleting.value = false;
    }
  }
}