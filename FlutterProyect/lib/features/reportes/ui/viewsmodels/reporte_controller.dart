// FlutterProyect/lib/features/reportes/ui/viewsmodels/reporte_controller.dart
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/services/ReporteService.dart';
import '../../data/dataSources/i_reporte_source.dart';
import "../../../reportes/data/models/reporte_promedio_personal_por_categoria_model.dart";
import "../../../reportes/data/models/reporte_grupal_por_categoria_model.dart";

class ReporteController extends GetxController {
  final ReporteService reporteService;
  final IReporteSource reporteSource;

  ReporteController({
    required this.reporteService,
    required this.reporteSource,
  });

  // ==============================
  // 🔄 PERSONAL POR EVALUACIÓN
  // ==============================
  Future<void> generarReportePersonalPorEvaluacion({
    required String idEvaluacion,
    required String idEstudiante,
  }) async {
    try {
      await reporteService.upsertReportePersonalPorEvaluacion(
        idEvaluacion: idEvaluacion,
        idEstudiante: idEstudiante,
      );
    } catch (e) {
      logError("Error generando reporte personal por evaluación: $e");
    }
  }

  // ==============================
  // 🔄 PERSONAL POR CATEGORÍA
  // ==============================
  Future<void> generarReportePersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
  }) async {
    try {
      await reporteService.upsertReportePersonalPorCategoria(
        idCategoria: idCategoria,
        idEstudiante: idEstudiante,
      );
    } catch (e) {
      logError("Error generando reporte personal por categoría: $e");
    }
  }

  // ==============================
  // 🔄 PROMEDIO PERSONAL
  // ==============================
  Future<void> generarReportePromedioPersonal({
    required String idCategoria,
    required String idEstudiante,
    required String idCurso,
  }) async {
    try {
      await reporteService.upsertReportePromedioPersonalPorCategoria(
        idCategoria: idCategoria,
        idEstudiante: idEstudiante,
        idCurso: idCurso,
      );
    } catch (e) {
      logError("Error generando promedio personal: $e");
    }
  }

  // ==============================
  // 🔄 GRUPAL POR EVALUACIÓN
  // ==============================
  Future<void> generarReporteGrupalPorEvaluacion({
    required String idEvaluacion,
    required String idCategoria,
    required String nombreGrupo,
  }) async {
    try {
      await reporteService.upsertReporteGrupalPorEvaluacion(
        idEvaluacion: idEvaluacion,
        idCategoria: idCategoria,
        nombreGrupo: nombreGrupo,
      );
    } catch (e) {
      logError("Error generando reporte grupal por evaluación: $e");
    }
  }

  // ==============================
  // 🔄 GRUPAL POR CATEGORÍA
  // ==============================
  Future<void> generarReporteGrupalPorCategoria({
    required String idCategoria,
    required String nombreGrupo,
    required String idCurso,
  }) async {
    try {
      await reporteService.upsertReporteGrupalPorCategoria(
        idCategoria: idCategoria,
        nombreGrupo: nombreGrupo,
        idCurso: idCurso,
      );
    } catch (e) {
      logError("Error generando reporte grupal por categoría: $e");
    }
  }

  // ==============================
  // 🚀 MÉTODO COMPLETO
  // ==============================
  Future<void> generarTodo({
    required String idEvaluacion,
    required String idCategoria,
    required String idEstudiante,
    required String nombreGrupo,
    required String idCurso,
  }) async {
    try {
      await generarReportePersonalPorEvaluacion(
        idEvaluacion: idEvaluacion,
        idEstudiante: idEstudiante,
      );

      await generarReportePersonalPorCategoria(
        idCategoria: idCategoria,
        idEstudiante: idEstudiante,
      );

      await generarReportePromedioPersonal(
        idCategoria: idCategoria,
        idEstudiante: idEstudiante,
        idCurso: idCurso,
      );

      await generarReporteGrupalPorEvaluacion(
        idEvaluacion: idEvaluacion,
        idCategoria: idCategoria,
        nombreGrupo: nombreGrupo,
      );

      await generarReporteGrupalPorCategoria(
        idCategoria: idCategoria,
        nombreGrupo: nombreGrupo,
        idCurso: idCurso,
      );
    } catch (e) {
      logError("Error generando todos los reportes: $e");
    }
  }

  // =====================================================
  // 📥 GETS (LECTURA DE DATOS)
  // =====================================================

  Future getReportePersonalPorEvaluacion({
    required String idEvaluacion,
    required String idEstudiante,
  }) async {
    try {
      return await reporteSource.getReportePersonalPorEvaluacion(
        idEvaluacion: idEvaluacion,
        idEstudiante: idEstudiante,
      );
    } catch (e) {
      logError("Error obteniendo reporte personal por evaluación: $e");
      return null;
    }
  }

  Future getReportePersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
  }) async {
    try {
      return await reporteSource.getReportePersonalPorCategoria(
        idCategoria: idCategoria,
        idEstudiante: idEstudiante,
      );
    } catch (e) {
      logError("Error obteniendo reporte personal por categoría: $e");
      return null;
    }
  }

  Future getReportePromedioPersonal({
    required String idCategoria,
    required String idEstudiante,
  }) async {
    try {
      return await reporteSource.getReportePromedioPersonalPorCategoria(
        idCategoria,
        idEstudiante,
      );
    } catch (e) {
      logError("Error obteniendo promedio personal: $e");
      return null;
    }
  }

  Future getReporteGrupalPorEvaluacion({
    required String idEvaluacion,
    required String idGrupo,
  }) async {
    try {
      return await reporteSource.getReporteGrupalPorEvaluacion(
        idEvaluacion,
        idGrupo,
      );
    } catch (e) {
      logError("Error obteniendo reporte grupal por evaluación: $e");
      return null;
    }
  }

  Future getReporteGrupalPorCategoria({
    required String idCategoria,
    required String idGrupo,
  }) async {
    try {
      return await reporteSource.getReporteGrupalPorCategoria(
        idCategoria,
        idGrupo,
      );
    } catch (e) {
      logError("Error obteniendo reporte grupal por categoría: $e");
      return null;
    }
  }

  Future<List> getReportesGrupalesPorCategoria(String idCategoria) async {
    try {
      return await reporteSource.getReportesGrupalesPorCategoria(idCategoria);
    } catch (e) {
      logError("Error obteniendo reportes grupales por categoría: $e");
      return [];
    }
  }

  Future<List> getReportesGrupalesPorEvaluacion(String idEvaluacion) async {
    try {
      return await reporteSource.getReportesGrupalesPorEvaluacion(idEvaluacion);
    } catch (e) {
      logError("Error obteniendo reportes grupales por evaluación: $e");
      return [];
    }
  }

  Future<List> getReportesPersonalesPorCategoria(String idCategoria) async {
    try {
      return await reporteSource.getReportesPersonalPorCategoria(idCategoria);
    } catch (e) {
      logError("Error obteniendo reportes personales por categoría: $e");
      return [];
    }
  }

  Future<List> getReportesPersonalesPorEvaluacion(String idEvaluacion) async {
    try {
      return await reporteSource.getReportesPersonalPorEvaluacion(idEvaluacion);
    } catch (e) {
      logError("Error obteniendo reportes personales por evaluación: $e");
      return [];
    }
  }

  Future<List> getReportesPromedioPersonal(String idCurso) async {
    try {
      return await reporteSource.getReportesPromedioPersonalCategoriaTodos(
        idCurso,
      );
    } catch (e) {
      logError("Error obteniendo promedios personales: $e");
      return [];
    }
  }

  Future<List<ReportePromedioPersonalPorCategoriaModel>>
  getEstudiantesBajoRendimiento(String idCurso) async {
    try {
      return await reporteService.obtenerEstudiantesBajoRendimiento(idCurso);
    } catch (e) {
      logError("Error obteniendo estudiantes bajo rendimiento: $e");
      return [];
    }
  }

  Future<List<ReporteGrupalPorCategoriaModel>> getGruposBajoRendimiento(
    String idCurso,
  ) async {
    try {
      return await reporteService.obtenerGruposBajoRendimiento(idCurso);
    } catch (e) {
      logError("Error obteniendo grupos bajo rendimiento: $e");
      return [];
    }
  }
}
