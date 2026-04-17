//FlutterProyect/lib/features/reportes/domain/services/ReporteService.dart
import '../../data/dataSources/i_reporte_source.dart';
import '../../data/dataSources/reporte_source_service.dart';
import '../../../evaluaciones/data/dataSources/i_evaluacion_source.dart';
import '../../../evaluaciones/data/dataSources/evaluacion_source_service.dart';
import '../../../../features/cursos/domain/repositories/i_curso_repository.dart';
import "../../../reportes/data/models/reporte_promedio_personal_por_categoria_model.dart";
import "../../../reportes/data/models/reporte_grupal_por_categoria_model.dart";
class ReporteService {
  final IEvaluacionSource evaluacionSource;
  final IReporteSource reporteSource;
  final ICursoRepository cursoRepository;

  ReporteService(
    this.evaluacionSource,
    this.reporteSource,
    this.cursoRepository,
  );

  // ==============================
  // 🔢 PROMEDIO SEGURO
  // ==============================
  double calcularPromedio(List<String> notas) {
    if (notas.isEmpty) return 0;

    final numeros = notas.map((e) => double.tryParse(e) ?? 0).toList();

    final suma = numeros.reduce((a, b) => a + b);

    return suma / numeros.length;
  }

  // ==============================
  // 📊 OBTENER LOS 4 PROMEDIOS
  // ==============================
  Future<Map<String, String>> obtenerPromediosPorEvaluacion({
    required String idEvaluacion,
    required String idEstudiante,
  }) async {
    final tipos = ["Puntualidad", "Contribuciones", "Actitud", "Compromiso"];

    final Map<String, String> promedios = {};

    for (var tipo in tipos) {
      final notas = await evaluacionSource.getNotasPorEvaluado(
        idEvaluacion,
        idEstudiante,
        tipo,
      );

      final promedio = calcularPromedio(notas);

      promedios[tipo] = promedio.toString();
    }

    return promedios;
  }

  Future<Map<String, String>> obtenerPromediosPorCategoria({
    required String idCategoria,
    required String idEstudiante,
  }) async {
    final evaluaciones = await evaluacionSource.getEvaluacionesByProfe(
      idCategoria,
    );

    if (evaluaciones.isEmpty) {
      return {
        "Puntualidad": "0",
        "Contribuciones": "0",
        "Actitud": "0",
        "Compromiso": "0",
      };
    }

    final List<double> p = [];
    final List<double> c = [];
    final List<double> a = [];
    final List<double> co = [];

    for (var eval in evaluaciones) {
      final idEval = eval.id.toString();

      try {
        final reporte = await reporteSource.getReportePersonalPorEvaluacion(
          idEstudiante: idEstudiante,
          idEvaluacion: idEval,
        );

        p.add(double.tryParse(reporte.notaPuntualidad) ?? 0);
        c.add(double.tryParse(reporte.notaContribucion) ?? 0);
        a.add(double.tryParse(reporte.notaActitud) ?? 0);
        co.add(double.tryParse(reporte.notaCompromiso) ?? 0);
      } catch (e) {
        // 🔥 Si no existe reporte para esa evaluación → lo ignoras
        continue;
      }
    }

    double promedio(List<double> lista) =>
        lista.isEmpty ? 0 : lista.reduce((a, b) => a + b) / lista.length;

    return {
      "Puntualidad": promedio(p).toString(),
      "Contribuciones": promedio(c).toString(),
      "Actitud": promedio(a).toString(),
      "Compromiso": promedio(co).toString(),
    };
  }

  // ==============================
  // 🔁 UPSERT REPORTE PERSONAL POR EVALUACION
  // ==============================
  Future<void> upsertReportePersonalPorEvaluacion({
    required String idEvaluacion,
    required String idEstudiante,
  }) async {
    final promedios = await obtenerPromediosPorEvaluacion(
      idEvaluacion: idEvaluacion,
      idEstudiante: idEstudiante,
    );

    final promedioP = promedios["Puntualidad"]!;
    final promedioC = promedios["Contribuciones"]!;
    final promedioA = promedios["Actitud"]!;
    final promedioCo = promedios["Compromiso"]!;

    try {
      // 🔍 1. Intentar obtener el reporte
      await reporteSource.getReportePersonalPorEvaluacion(
        idEstudiante: idEstudiante,
        idEvaluacion: idEvaluacion,
      );

      // ✏️ 2. Si existe → UPDATE
      await reporteSource.updateReportePersonalPorEvaluacion(
        idReportePersonal: "", // ya no importa
        idEvaluacion: idEvaluacion,
        idEstudiante: idEstudiante,
        notaPuntualidad: promedioP,
        notaContribucion: promedioC,
        notaActitud: promedioA,
        notaCompromiso: promedioCo,
      );
    } catch (e) {
      // ➕ 3. Si NO existe → CREATE
      await reporteSource.createReportePersonalPorEvaluacion(
        idEvaluacion: idEvaluacion,
        idEstudiante: idEstudiante,
        notaPuntualidad: promedioP,
        notaContribucion: promedioC,
        notaActitud: promedioA,
        notaCompromiso: promedioCo,
      );
    }
  }

  Future<void> upsertReportePersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
  }) async {
    final promedios = await obtenerPromediosPorCategoria(
      idCategoria: idCategoria,
      idEstudiante: idEstudiante,
    );

    try {
      await reporteSource.updateReportePersonalPorCategoria(
        idReportePersonal: "",
        idCategoria: idCategoria,
        idEstudiante: idEstudiante,
        notaPuntualidad: promedios["Puntualidad"]!,
        notaContribucion: promedios["Contribuciones"]!,
        notaActitud: promedios["Actitud"]!,
        notaCompromiso: promedios["Compromiso"]!,
      );
    } catch (e) {
      await reporteSource.createReportePersonalPorCategoria(
        idCategoria: idCategoria,
        idEstudiante: idEstudiante,
        notaPuntualidad: promedios["Puntualidad"]!,
        notaContribucion: promedios["Contribuciones"]!,
        notaActitud: promedios["Actitud"]!,
        notaCompromiso: promedios["Compromiso"]!,
      );
    }
  }

  Future<void> upsertReporteGrupalPorEvaluacion({
    required String idEvaluacion,
    required String idCategoria,
    required String nombreGrupo,
  }) async {
    final estudiantes = await cursoRepository.getCompanerosDeGrupo(
      idCategoria,
      nombreGrupo,
    );

    final List<double> promediosEstudiantes = [];

    for (final correo in estudiantes) {
      try {
        final reporte = await reporteSource.getReportePersonalPorEvaluacion(
          idEstudiante: correo,
          idEvaluacion: idEvaluacion,
        );

        final p = double.tryParse(reporte.notaPuntualidad) ?? 0;
        final c = double.tryParse(reporte.notaContribucion) ?? 0;
        final a = double.tryParse(reporte.notaActitud) ?? 0;
        final co = double.tryParse(reporte.notaCompromiso) ?? 0;

        final promedioEstudiante = (p + c + a + co) / 4;

        promediosEstudiantes.add(promedioEstudiante);
      } catch (e) {
        continue;
      }
    }

    double promedioGrupo(List<double> lista) {
      if (lista.isEmpty) return 0;
      return lista.reduce((a, b) => a + b) / lista.length;
    }

    final resultado = promedioGrupo(promediosEstudiantes).toString();

    try {
      await reporteSource.updateReporteGrupalPorEvaluacion(
        idReporteGrupal: "",
        idEvaluacion: idEvaluacion,
        idGrupo: nombreGrupo,
        nota: resultado,
      );
    } catch (e) {
      await reporteSource.createReporteGrupalPorEvaluacion(
        idEvaluacion: idEvaluacion,
        idGrupo: nombreGrupo,
        nota: resultado,
      );
    }
  }

  Future<void> upsertReporteGrupalPorCategoria({
    required String idCategoria,
    required String nombreGrupo,
    required String idCurso,
  }) async {
    final evaluaciones = await evaluacionSource.getEvaluacionesByProfe(
      idCategoria,
    );

    if (evaluaciones.isEmpty) {
      try {
        await reporteSource.updateReporteGrupalPorCategoria(
          idReporteGrupal: "",
          idCategoria: idCategoria,
          idGrupo: nombreGrupo,
          nota: "0",
          idCurso: idCurso,
        );
      } catch (e) {
        await reporteSource.createReporteGrupalPorCategoria(
          idCategoria: idCategoria,
          idGrupo: nombreGrupo,
          nota: "0",
          idCurso: idCurso,
        );
      }
      return;
    }

    final List<double> notasGrupales = [];

    for (var eval in evaluaciones) {
      final idEval = eval.id.toString();

      try {
        final reporte = await reporteSource.getReporteGrupalPorEvaluacion(
          idEval,
          nombreGrupo,
        );

        final nota = double.tryParse(reporte.nota) ?? 0;
        notasGrupales.add(nota);
      } catch (e) {
        // 🔥 Si no existe reporte → lo ignoras
        continue;
      }
    }

    double promedio(List<double> lista) {
      if (lista.isEmpty) return 0;
      return lista.reduce((a, b) => a + b) / lista.length;
    }

    final resultado = promedio(notasGrupales).toString();

    try {
      await reporteSource.updateReporteGrupalPorCategoria(
        idReporteGrupal: "",
        idCategoria: idCategoria,
        idGrupo: nombreGrupo,
        nota: resultado,
        idCurso: idCurso,
      );
    } catch (e) {
      await reporteSource.createReporteGrupalPorCategoria(
        idCategoria: idCategoria,
        idGrupo: nombreGrupo,
        nota: resultado,
        idCurso: idCurso,
      );
    }
  }

  Future<void> upsertReportePromedioPersonalPorCategoria({
    required String idCategoria,
    required String idEstudiante,
    required String idCurso,
  }) async {
    try {
      // 🔍 1. Obtener el reporte personal por categoría
      final reporte = await reporteSource.getReportePersonalPorCategoria(
        idEstudiante: idEstudiante,
        idCategoria: idCategoria,
      );

      final p = double.tryParse(reporte.notaPuntualidad) ?? 0;
      final c = double.tryParse(reporte.notaContribucion) ?? 0;
      final a = double.tryParse(reporte.notaActitud) ?? 0;
      final co = double.tryParse(reporte.notaCompromiso) ?? 0;

      final promedio = ((p + c + a + co) / 4).toString();

      try {
        // ✏️ UPDATE
        await reporteSource.updateReportePromedioPersonalPorCategoria(
          idReportePromedioPersonal: "",
          idCategoria: idCategoria,
          idEstudiante: idEstudiante,
          nota: promedio,
          idCurso: idCurso,
        );
      } catch (e) {
        // ➕ CREATE
        await reporteSource.createReportePromedioPersonalPorCategoria(
          idCategoria: idCategoria,
          idEstudiante: idEstudiante,
          nota: promedio,
          idCurso: idCurso,
        );
      }
    } catch (e) {
      // 🔥 Si no existe el reporte base → no haces nada
      return;
    }
  }

  Future<List<ReportePromedioPersonalPorCategoriaModel>>
  obtenerEstudiantesBajoRendimiento(String idCurso) async {
    final reportes = await reporteSource
        .getReportesPromedioPersonalCategoriaTodos(idCurso);

    final filtrados = reportes.where((e) {
      final nota = double.tryParse(e.nota) ?? 0;
      return nota < 3.3;
    }).toList();

    filtrados.sort((a, b) {
      final notaA = double.tryParse(a.nota) ?? 0;
      final notaB = double.tryParse(b.nota) ?? 0;
      return notaA.compareTo(notaB);
    });

    return filtrados;
  }

  Future<List<ReporteGrupalPorCategoriaModel>> obtenerGruposBajoRendimiento(
    String idCurso,
  ) async {
    final reportes = await reporteSource.getReportesGrupalesPorCategoria(
      idCurso,
    );

    final filtrados = reportes.where((e) {
      final nota = double.tryParse(e.nota) ?? 0;
      return nota < 3.3;
    }).toList();

    filtrados.sort((a, b) {
      final notaA = double.tryParse(a.nota) ?? 0;
      final notaB = double.tryParse(b.nota) ?? 0;
      return notaA.compareTo(notaB);
    });

    return filtrados;
  }
}
