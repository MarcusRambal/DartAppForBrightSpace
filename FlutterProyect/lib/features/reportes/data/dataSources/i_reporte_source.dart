import '../models/reporte_grupal_por_categoria_model.dart';
import '../models/reporte_grupal_por_evaluacion_model.dart';
import '../models/reporte_personal_por_categoria_model.dart';
import '../models/reporte_personal_por_evaluacion_model.dart';
import '../models/reporte_promedio_personal_por_categoria_model.dart';

abstract class IReporteSource {
  // CREATE
  Future<void> createReporteGrupalPorEvaluacion({
    required String idEvaluacion,
    required String idGrupo,
    required String nota,
  });

  Future<void> createReporteGrupalPorCategoria({
    required String idCategoria,
    required String idGrupo,
    required String nota,
    required String idCurso,
  });

  Future<void> createReportePersonalPorEvaluacion({
    required String idEvaluacion,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  });

  Future<void> createReportePersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  });

  Future<void> createReportePromedioPersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
    required String nota,
    required String idCurso,
  });

  // UPDATE
  Future<void> updateReporteGrupalPorEvaluacion({
    required String idReporteGrupal,
    required String idEvaluacion,
    required String idGrupo,
    required String nota,
  });

  Future<void> updateReporteGrupalPorCategoria({
    required String idReporteGrupal,
    required String idCategoria,
    required String idGrupo,
    required String idCurso,
    required String nota,
  });

  Future<void> updateReportePersonalPorEvaluacion({
    required String idReportePersonal,
    required String idEvaluacion,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  });

  Future<void> updateReportePersonalPorCategoria({
    required String idReportePersonal,
    required String idCategoria,
    required String idEstudiante,
    required String notaPuntualidad,
    required String notaContribucion,
    required String notaActitud,
    required String notaCompromiso,
  });

  Future<void> updateReportePromedioPersonalPorCategoria({
    required String idReportePromedioPersonal,
    required String idEstudiante,
    required String idCategoria,
    required String nota,
    required String idCurso,
  });

  // GET LISTAS
  Future<List<ReportePromedioPersonalPorCategoriaModel>>
  getReportesPromedioPersonalCategoriaTodos(String idCurso);

  Future<List<ReporteGrupalPorCategoriaModel>> getReportesGrupalesTodos(
    String idCurso,
  );

  // GET INDIVIDUALES
  Future<ReportePersonalPorEvaluacionModel> getReportePersonalPorEvaluacion({
    required String idEstudiante,
    required String idEvaluacion,
  });

  Future<ReportePersonalPorCategoriaModel> getReportePersonalPorCategoria({
    required String idEstudiante,
    required String idCategoria,
  });

  // LISTAS POR CONTEXTO
  Future<List<ReportePersonalPorEvaluacionModel>>
  getReportesPersonalPorEvaluacion(String idEvaluacion);

  Future<List<ReportePersonalPorCategoriaModel>>
  getReportesPersonalPorCategoria(String idCategoria);

  Future<List<ReporteGrupalPorCategoriaModel>> getReportesGrupalesPorCategoria(
    String idCategoria,
  );

  Future<List<ReporteGrupalPorEvaluacionModel>>
  getReportesGrupalesPorEvaluacion(String idEvaluacion);

  Future<ReporteGrupalPorCategoriaModel> getReporteGrupalPorCategoria(
    String idCategoria,
    String idGrupo,
  );

  Future<ReporteGrupalPorEvaluacionModel> getReporteGrupalPorEvaluacion(
    String idEvaluacion,
    String idGrupo,
  );

  Future<ReportePromedioPersonalPorCategoriaModel>
  getReportePromedioPersonalPorCategoria(
    String idCategoria,
    String idEstudiante,
  );
}
