//FlutterProyect/lib/features/student_home/ui/views/student_home_controller.dart
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import "../../../evaluaciones/ui/viewmodels/evaluaciones_controller.dart";
import '../../../../features/cursos/domain/repositories/i_curso_repository.dart';
import '../../../../features/cursos/domain/entities/curso_matriculado.dart';

class StudentHomeController extends GetxController {
  final ICursoRepository cursoRepository;
  final String studentEmail;

  StudentHomeController({
    required this.cursoRepository,
    required this.studentEmail,
  });

  var cursos = <CursoMatriculado>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCursos();
  }

  void cargarEvaluaciones() {
    if (cursos.isEmpty) return; // 🔥 evita llamadas innecesarias

    final grupos = cursos.expand((curso) => curso.grupos).toList();

    Get.find<EvaluacionController>()
        .cargarEvaluacionesIncompletasPorGrupos(grupos);
  }

  void fetchCursos() async {
    try {
      isLoading.value = true;

      var fetchedCursos = await cursoRepository.getCursosByEstudiante(
        studentEmail,
      );

      cursos.assignAll(fetchedCursos);

      // 🔥 AQUÍ ES DONDE VA (NO EN LA UI)
      cargarEvaluaciones();

    } catch (e) {
      logError("Error buscando cursos del estudiante: $e");
      if (!Get.testMode) {
        Get.snackbar('Error', 'No se pudieron cargar tus cursos.');
      }
    } finally {
      isLoading.value = false;
    }
  }
}