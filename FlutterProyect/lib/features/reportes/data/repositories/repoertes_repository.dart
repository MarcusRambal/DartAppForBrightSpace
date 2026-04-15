import 'package:flutter_prueba/features/reportes/domain/entities/reporteGrupalPorCategoria_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reporteGrupalPorEvaluacion_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reportePersonalPorCategoria_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reportePersonalPorEvaluacion_entity.dart';
import 'package:flutter_prueba/features/reportes/domain/entities/reportePromedioPersonalPorCategoria_entity.dart';

import '../../domain/repositories/i_reporte_repository.dart';
import '../dataSources/i_reporte_source.dart';

class ReportesRepository implements IReporteRepository {
  final IReporteSource reporteSource;

  ReportesRepository(this.reporteSource);

  // CREATE
  @override
  Future<void> createReporteGrupalPorCategoria(
    String idCategoria,
    String idGrupo,
    String nota,
    String idCurso,
  ) async {
    await reporteSource.createReporteGrupalPorCategoria(
      idCategoria: idCategoria,
      idGrupo: idGrupo,
      nota: nota,
      idCurso: idCurso,
    );
  }

  @override
  Future<void> createReporteGrupalPorEvaluacion(
    String idEvaluacion,
    String idGrupo,
    String nota,
  ) async {
    await reporteSource.createReporteGrupalPorEvaluacion(
      idEvaluacion: idEvaluacion,
      idGrupo: idGrupo,
      nota: nota,
    );
  }

  @override
  Future<void> createReportePersonalPorCategoria(
    String idCategoria,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  ) async {
    await reporteSource.createReportePersonalPorCategoria(
      idCategoria: idCategoria,
      idEstudiante: idEstudiante,
      notaPuntualidad: notaPuntualidad,
      notaContribucion: notaContribucion,
      notaActitud: notaActitud,
      notaCompromiso: notaCompromiso,
    );
  }

  @override
  Future<void> createReportePersonalPorEvaluacion(
    String idEvaluacion,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  ) async {
    await reporteSource.createReportePersonalPorEvaluacion(
      idEvaluacion: idEvaluacion,
      idEstudiante: idEstudiante,
      notaPuntualidad: notaPuntualidad,
      notaContribucion: notaContribucion,
      notaActitud: notaActitud,
      notaCompromiso: notaCompromiso,
    );
  }

  @override
  Future<void> createReportePromedioPersonalPorCategoria(
    String idReportePersonal,
    String nota,
    String idCurso,
  ) async {
    await reporteSource.createReportePromedioPersonalPorCategoria(
      idReportePersonal: idReportePersonal,
      nota: nota,
      idCurso:idCurso,
    );
  }

  // GET INDIVIDUALES
  @override
  Future<ReportePersonalPorCategoriaEntity>
      getReportePersonalPorCategoriaEntity(
    String idEstudiante,
    String idCategoria,
  ) async {
    final model = await reporteSource.getReportePersonalPorCategoria(
      idEstudiante: idEstudiante,
      idCategoria: idCategoria,
    );

    return model.toEntity();
  }

  @override
  Future<ReportePersonalPorEvaluacionEntity>
      getReportePersonalPorEvaluacionEntity(
    String idEstudiante,
    String idEvaluacion,
  ) async {
    final model = await reporteSource.getReportePersonalPorEvaluacion(
      idEstudiante: idEstudiante,
      idEvaluacion: idEvaluacion,
    );

    return model.toEntity();
  }

  // GET LISTAS
  @override
  Future<List<ReporteGrupalPorCategoriaEntity>>
      getReportesGrupalesPorCategoria(String idCategoria) async {
    final models =
        await reporteSource.getReportesGrupalesPorCategoria(idCategoria);

    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ReporteGrupalPorEvaluacionEntity>>
      getReportesGrupalesPorEvaluacion(String idEvaluacion) async {
    final models =
        await reporteSource.getReportesGrupalesPorEvaluacion(idEvaluacion);

    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ReporteGrupalPorCategoriaEntity>>
      getReportesGrupalesTodos(String idCurso) async {
    final models = await reporteSource.getReportesGrupalesTodos(idCurso);

    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ReportePersonalPorCategoriaEntity>>
      getReportesPersonalPorCategoriaEntity(String idCategoria) async {
    final models =
        await reporteSource.getReportesPersonalPorCategoria(idCategoria);

    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ReportePersonalPorEvaluacionEntity>>
      getReportesPersonalPorEvaluacionEntity(String idEvaluacion) async {
    final models =
        await reporteSource.getReportesPersonalPorEvaluacion(idEvaluacion);

    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ReportePromedioPersonalPorCategoriaEntity>>
      getReportesPromedioPersonalCategoriaTodos(String idCurso) async {
    final models =
        await reporteSource.getReportesPromedioPersonalCategoriaTodos(idCurso);

    return models.map((e) => e.toEntity()).toList();
  }

  // UPDATE
  @override
  Future<void> updateReporteGrupalPorCategoria(
    String idReporteGrupal,
    String idCategoria,
    String idGrupo,
    String nota,
    String idCurso,
  ) async {
    await reporteSource.updateReporteGrupalPorCategoria(
      idReporteGrupal: idReporteGrupal,
      idCategoria: idCategoria,
      idGrupo: idGrupo,
      nota: nota,
      idCurso: idCurso,
    );
  }

  @override
  Future<void> updateReporteGrupalPorEvaluacion(
    String idReporteGrupal,
    String idEvaluacion,
    String idGrupo,
    String nota,
  ) async {
    await reporteSource.updateReporteGrupalPorEvaluacion(
      idReporteGrupal: idReporteGrupal,
      idEvaluacion: idEvaluacion,
      idGrupo: idGrupo,
      nota: nota,
    );
  }

  @override
  Future<void> updateReportePersonalPorCategoria(
    String idReportePersonal,
    String idCategoria,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  ) async {
    await reporteSource.updateReportePersonalPorCategoria(
      idReportePersonal: idReportePersonal,
      idCategoria: idCategoria,
      idEstudiante: idEstudiante,
      notaPuntualidad: notaPuntualidad,
      notaContribucion: notaContribucion,
      notaActitud: notaActitud,
      notaCompromiso: notaCompromiso,
    );
  }

  @override
  Future<void> updateReportePersonalPorEvaluacion(
    String idReportePersonal,
    String idEvaluacion,
    String idEstudiante,
    String notaPuntualidad,
    String notaContribucion,
    String notaActitud,
    String notaCompromiso,
  ) async {
    await reporteSource.updateReportePersonalPorEvaluacion(
      idReportePersonal: idReportePersonal,
      idEvaluacion: idEvaluacion,
      idEstudiante: idEstudiante,
      notaPuntualidad: notaPuntualidad,
      notaContribucion: notaContribucion,
      notaActitud: notaActitud,
      notaCompromiso: notaCompromiso,
    );
  }

  @override
  Future<void> updateReportePromedioPersonalPorCategoria(
    String idReportePromedioPersonal,
    String idEstudiante,
    String idEvaluacion,
    String nota,
    String idCurso,
  ) async {
    await reporteSource.updateReportePromedioPersonalPorCategoria(
      idReportePromedioPersonal: idReportePromedioPersonal,
      idEstudiante: idEstudiante,
      idEvaluacion: idEvaluacion,
      nota: nota,
      idCurso:idCurso,
    );
  }
}