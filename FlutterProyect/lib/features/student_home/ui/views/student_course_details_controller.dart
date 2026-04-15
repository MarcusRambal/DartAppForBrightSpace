//FlutterProyect/lib/features/student_home/ui/views/student_course_details_controller.dart
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../../../features/cursos/domain/repositories/i_curso_repository.dart';

class StudentCourseDetailsController extends GetxController {
  final ICursoRepository cursoRepository;

  StudentCourseDetailsController({required this.cursoRepository});

  // Un diccionario para guardar los compañeros por cada Categoría (evita recargar si ya se buscó)
  var companerosPorCategoria = <String, List<String>>{}.obs;
  // Un diccionario para saber qué categoría está cargando
  var isLoadingCategoria = <String, bool>{}.obs;

  Future<void> cargarCompaneros(String idCat, String nombreGrupo) async {
    // Si ya los cargamos antes, no hacemos nada
    if (companerosPorCategoria.containsKey(idCat)) return;

    try {
      isLoadingCategoria[idCat] = true;

      final companeros = await cursoRepository.getCompanerosDeGrupo(
        idCat,
        nombreGrupo,
      );
      companerosPorCategoria[idCat] = companeros;
    } catch (e) {
      logError("Error buscando compañeros: $e");
      if(!Get.testMode) {
        Get.snackbar('Error', 'No pudimos cargar a tus compañeros');
      }
    } finally {
      isLoadingCategoria[idCat] = false;
    }
  }
}
