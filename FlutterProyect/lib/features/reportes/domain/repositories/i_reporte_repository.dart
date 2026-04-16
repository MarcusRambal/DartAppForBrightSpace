//FlutterProyect/lib/features/reportes/domain/repositories/i_reporte_repository.dart
import '../entities/reporteGrupalPorCategoria_entity.dart';
import '../entities/reporteGrupalPorEvaluacion_entity.dart';
import '../entities/reportePersonalPorCategoria_entity.dart';
import '../entities/reportePersonalPorEvaluacion_entity.dart';
import '../entities/reportePromedioPersonalPorCategoria_entity.dart';

abstract class IReporteRepository {
  //CREAR TODO
  Future<void> createReporteGrupalPorEvaluacion(
    String idEvaluacion,
    String idGrupo,
    String nota,
  );
  Future<void> createReporteGrupalPorCategoria(
    String idCategoria,
    String idGrupo,
    String nota,
    String idCurso,
  );
  Future<void> createReportePersonalPorEvaluacion(
    String idEvaluacion,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  );
  Future<void> createReportePersonalPorCategoria(
    String idCategoria,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  );
  Future<void> createReportePromedioPersonalPorCategoria(
    String idCategoria,
    String idEstudiante,
    String nota,
    String idCurso,
  );
  //ACTUALIZAR TODO
  Future<void> updateReporteGrupalPorEvaluacion(
    String idReporteGrupal,
    String idEvaluacion,
    String idGrupo,
    String nota,
  );
  Future<void> updateReporteGrupalPorCategoria(
    String idReporteGrupal,
    String idCategoria,
    String idGrupo,
    String nota,
    String idCurso,
  );
  Future<void> updateReportePersonalPorEvaluacion(
    String idReportePersonal,
    String idEvaluacion,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  );
  Future<void> updateReportePersonalPorCategoria(
    String idReportePersonal,
    String idCategoria,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  );
  Future<void> updateReportePromedioPersonalPorCategoria(
    String idReportePromedioPersonal,
    String idEstudiante,
    String idEvaluacion,
    String nota,
    String idCurso,
  );
  //Lista de todos los resportes de personas en un curso
  //Lista de todos los reportes de grupos de un curso
  //Usar getCursosByProfe para las siguentes funciones
  Future<List<ReportePromedioPersonalPorCategoriaEntity>>
  getReportesPromedioPersonalCategoriaTodos(String idCurso);
  Future<List<ReporteGrupalPorCategoriaEntity>> getReportesGrupalesTodos(
    String idCurso,
  );
  //pantalla con mis notas en una evaluación
  //pantalla con mis notas en una categoría
  Future<ReportePersonalPorEvaluacionEntity>
  getReportePersonalPorEvaluacionEntity(
    String idEstudiante,
    String idEvaluacion,
  );

  Future<ReportePersonalPorCategoriaEntity>
  getReportePersonalPorCategoriaEntity(String idEstudiante, String idCategoria);
  //Lista de las reportes de los estudiantes de una categoría
  //Lista de las reportes de los estudiantes de una evaluacion
  Future<List<ReportePersonalPorEvaluacionEntity>>
  getReportesPersonalPorEvaluacionEntity(String idEvaluacion);
  Future<List<ReportePersonalPorCategoriaEntity>>
  getReportesPersonalPorCategoriaEntity(String idCategoria);
  //Lista de las reportes de los GRUPOS de una categoría
  //Lista de las reportes de los GRUPOS de una evaluacion
  Future<List<ReporteGrupalPorCategoriaEntity>> getReportesGrupalesPorCategoria(
    String idCategoria,
  );
  Future<List<ReporteGrupalPorEvaluacionEntity>>
  getReportesGrupalesPorEvaluacion(String idEvaluacion);

  Future<ReporteGrupalPorCategoriaEntity> getReporteGrupalPorCategoria(
    String idCategoria,
    String idGrupo,
  );
  Future<ReporteGrupalPorEvaluacionEntity> getReporteGrupalPorEvaluacion(
    String idEvaluacion,
    String idGrupo,
  );
  Future<ReportePromedioPersonalPorCategoriaEntity>
  getReportePromedioPersonalPorCategoria(
    String idCategoria,
    String idEstudiante,
  );
  //Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria);
  //Future<List<PreguntaEntity>> getPreguntas();
}
