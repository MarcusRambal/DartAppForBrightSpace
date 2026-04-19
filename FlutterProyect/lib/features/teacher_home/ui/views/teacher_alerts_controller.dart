import 'package:get/get.dart';
import '../../../../features/reportes/ui/viewsmodels/reporte_controller.dart';
import '../../../../features/cursos/ui/viewsmodels/curso_controller.dart';

class TeacherAlertsController extends GetxController {
  var cantidadAlertas = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final cursoCtrl = Get.find<CursoController>();

    // Vigila la lista de cursos: cuando cambie (cargue), recalcula
    ever(cursoCtrl.cursos, (_) => calcularAlertasTotales());

    if (cursoCtrl.cursos.isNotEmpty) {
      calcularAlertasTotales();
    }
  }

  Future<void> calcularAlertasTotales() async {
    try {
      isLoading.value = true;
      final cursoCtrl = Get.find<CursoController>();
      final reporteCtrl = Get.find<ReporteController>();

      int totalBajoRendimiento = 0;

      for (var curso in cursoCtrl.cursos) {
        // Usamos el ID del curso para buscar en los reportes
        final alertasCurso = await reporteCtrl.getEstudiantesBajoRendimiento(
          curso.id.toString(),
        );
        totalBajoRendimiento += alertasCurso.length;
      }

      cantidadAlertas.value = totalBajoRendimiento;
    } catch (e) {
      print("Error en AlertasController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
