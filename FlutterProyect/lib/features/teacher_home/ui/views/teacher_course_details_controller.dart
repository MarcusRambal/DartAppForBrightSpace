import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../../../features/cursos/domain/repositories/i_curso_repository.dart';

class TeacherCourseDetailsController extends GetxController {
  final ICursoRepository repository;
  TeacherCourseDetailsController({required this.repository});

  var categorias = <Map<String, dynamic>>[].obs;
  var isLoadingCategorias = true.obs;
  var datosGrupos = <String, Map<String, List<String>>>{}.obs;
  var loadingDetalleCategoria = <String, bool>{}.obs;

  Future<void> fetchCategorias(String idCurso) async {
    try {
      isLoadingCategorias.value = true;
      final result = await repository.getCategoriasByCurso(idCurso);
      categorias.assignAll(result);
    } catch (e) {
      logError("Error: $e");
    } finally {
      isLoadingCategorias.value = false;
    }
  }

  Future<void> fetchDetalleCategoria(String idCat) async {
    if (datosGrupos.containsKey(idCat)) return;
    try {
      loadingDetalleCategoria[idCat] = true;
      final listaPlana = await repository.getDatosDeGruposPorCategoria(idCat);
      Map<String, List<String>> agrupados = {};
      for (var estudiante in listaPlana) {
        String nombreGrupo = estudiante['nombre'].toString();
        String correo = estudiante['Correo'].toString();
        if (!agrupados.containsKey(nombreGrupo)) agrupados[nombreGrupo] = [];
        agrupados[nombreGrupo]!.add(correo);
      }
      datosGrupos[idCat] = agrupados;
    } finally {
      loadingDetalleCategoria[idCat] = false;
    }
  }
}
