import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../features/cursos/domain/entities/curso_curso.dart';
import '../../../../features/cursos/domain/repositories/i_curso_repository.dart';
import '../../../../features/cursos/domain/entities/curso_matriculado.dart';

class StudentHomeController extends GetxController {
  final ICursoRepository cursoRepository;
  final String studentEmail;

  StudentHomeController({
    required this.cursoRepository,
    required this.studentEmail,
  });

  // Variables reactivas (Observables)
  var cursos = <CursoMatriculado>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Cuando el controlador nace, inmediatamente busca los cursos
    fetchCursos();
  }

  void fetchCursos() async {
    try {
      isLoading.value = true;
      // Llamamos al método maestro que creamos en el backend
      var fetchedCursos = await cursoRepository.getCursosByEstudiante(
        studentEmail,
      );
      cursos.assignAll(fetchedCursos);
    } catch (e) {
      logError("Error buscando cursos del estudiante: $e");
      Get.snackbar('Error', 'No se pudieron cargar tus cursos.');
    } finally {
      isLoading.value = false;
    }
  }
}
