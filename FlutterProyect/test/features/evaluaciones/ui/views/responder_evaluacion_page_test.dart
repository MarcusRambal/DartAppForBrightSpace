import 'package:flutter/material.dart';
import 'package:flutter_prueba/features/evaluaciones/data/dataSources/i_evaluacion_source.dart';
import 'package:flutter_prueba/features/reportes/data/dataSources/i_reporte_source.dart';
import 'package:flutter_prueba/features/reportes/data/models/reporte_grupal_por_categoria_model.dart';
import 'package:flutter_prueba/features/reportes/data/models/reporte_grupal_por_evaluacion_model.dart';
import 'package:flutter_prueba/features/reportes/data/models/reporte_personal_por_categoria_model.dart';
import 'package:flutter_prueba/features/reportes/data/models/reporte_personal_por_evaluacion_model.dart';
import 'package:flutter_prueba/features/reportes/data/models/reporte_promedio_personal_por_categoria_model.dart';
import 'package:flutter_prueba/features/reportes/domain/services/ReporteService.dart';
import 'package:flutter_prueba/features/reportes/ui/viewsmodels/reporte_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'package:flutter_prueba/features/evaluaciones/ui/views/responder_evaluacion_page.dart';
import 'package:flutter_prueba/features/cursos/domain/repositories/i_curso_repository.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_matriculado.dart';


class FakeReporteService implements ReporteService {
  @override
  Future<void> upsertReportePersonalPorEvaluacion({required String idEvaluacion, required String idEstudiante}) async {}

  @override
  Future<void> upsertReportePersonalPorCategoria({required String idCategoria, required String idEstudiante}) async {}

  @override
  Future<void> upsertReportePromedioPersonalPorCategoria({required String idCategoria, required String idEstudiante, required String idCurso}) async {}

  @override
  Future<void> upsertReporteGrupalPorEvaluacion({required String idEvaluacion, required String idCategoria, required String nombreGrupo}) async {}

  @override
  Future<void> upsertReporteGrupalPorCategoria({required String idCategoria, required String nombreGrupo, required String idCurso}) async {}

  @override
  Future<List<ReportePromedioPersonalPorCategoriaModel>> obtenerEstudiantesBajoRendimiento(String idCurso) async => [];

  @override
  Future<List<ReporteGrupalPorCategoriaModel>> obtenerGruposBajoRendimiento(String idCurso) async => [];

  @override
  double calcularPromedio(List<String> notas) => 0.0;

  @override
  ICursoRepository get cursoRepository => throw UnimplementedError();

  @override
  IEvaluacionSource get evaluacionSource => throw UnimplementedError();

  @override
  Future<Map<String, String>> obtenerPromediosPorCategoria({required String idCategoria, required String idEstudiante}) async => {};

  @override
  Future<Map<String, String>> obtenerPromediosPorEvaluacion({required String idEvaluacion, required String idEstudiante}) async => {};

  @override
  IReporteSource get reporteSource => throw UnimplementedError();

  @override
  Future<void> generarTodo({required String idEvaluacion, required String idCategoria, required String nombreGrupo, required String idEstudiante, required String idCurso}) async {}
}

class FakeReporteSource implements IReporteSource {
  @override
  Future<void> createReporteGrupalPorCategoria({required String idCategoria, required String idGrupo, required String nota, required String idCurso}) async {}

  @override
  Future<void> createReporteGrupalPorEvaluacion({required String idEvaluacion, required String idGrupo, required String nota}) async {}

  @override
  Future<void> createReportePersonalPorCategoria({required String idCategoria, required String idEstudiante, required String notaPuntualidad, required String notaContribucion, required String notaActitud, required String notaCompromiso}) async {}

  @override
  Future<void> createReportePersonalPorEvaluacion({required String idEvaluacion, required String idEstudiante, required String notaPuntualidad, required String notaContribucion, required String notaActitud, required String notaCompromiso}) async {}

  @override
  Future<void> createReportePromedioPersonalPorCategoria({required String idCategoria, required String idEstudiante, required String nota, required String idCurso}) async {}

  @override
  Future<ReporteGrupalPorCategoriaModel> getReporteGrupalPorCategoria(String idCategoria, String idGrupo) async => throw UnimplementedError();

  @override
  Future<ReporteGrupalPorEvaluacionModel> getReporteGrupalPorEvaluacion(String idEvaluacion, String idGrupo) async => throw UnimplementedError();

  @override
  Future<ReportePersonalPorCategoriaModel> getReportePersonalPorCategoria({required String idEstudiante, required String idCategoria}) async => throw UnimplementedError();

  @override
  Future<ReportePersonalPorEvaluacionModel> getReportePersonalPorEvaluacion({required String idEstudiante, required String idEvaluacion}) async => throw UnimplementedError();

  @override
  Future<ReportePromedioPersonalPorCategoriaModel> getReportePromedioPersonalPorCategoria(String idCategoria, String idEstudiante) async => throw UnimplementedError();

  @override
  Future<List<ReporteGrupalPorCategoriaModel>> getReportesGrupalesPorCategoria(String idCategoria) async => [];

  @override
  Future<List<ReporteGrupalPorEvaluacionModel>> getReportesGrupalesPorEvaluacion(String idEvaluacion) async => [];

  @override
  Future<List<ReporteGrupalPorCategoriaModel>> getReportesGrupalesTodos(String idCurso) async => [];

  @override
  Future<List<ReportePersonalPorCategoriaModel>> getReportesPersonalPorCategoria(String idCategoria) async => [];

  @override
  Future<List<ReportePersonalPorEvaluacionModel>> getReportesPersonalPorEvaluacion(String idEvaluacion) async => [];

  @override
  Future<List<ReportePromedioPersonalPorCategoriaModel>> getReportesPromedioPersonalCategoriaTodos(String idCurso) async => [];

  @override
  Future<void> updateReporteGrupalPorCategoria({required String idReporteGrupal, required String idCategoria, required String idGrupo, required String idCurso, required String nota}) async {}

  @override
  Future<void> updateReporteGrupalPorEvaluacion({required String idReporteGrupal, required String idEvaluacion, required String idGrupo, required String nota}) async {}

  @override
  Future<void> updateReportePersonalPorCategoria({required String idReportePersonal, required String idCategoria, required String idEstudiante, required String notaPuntualidad, required String notaContribucion, required String notaActitud, required String notaCompromiso}) async {}

  @override
  Future<void> updateReportePersonalPorEvaluacion({required String idReportePersonal, required String idEvaluacion, required String idEstudiante, required String notaPuntualidad, required String notaContribucion, required String notaActitud, required String notaCompromiso}) async {}

  @override
  Future<void> updateReportePromedioPersonalPorCategoria({required String idReportePromedioPersonal, required String idEstudiante, required String idCategoria, required String nota, required String idCurso}) async {}
}

class FakeEvaluacionRepository implements IEvaluacionRepository {
  List<PreguntaEntity> preguntas = [];
  List<RespuestaEntity> respuestasEnviadas = [];
  bool failEnviar = false;

  @override
  Future<void> createEvaluacion(String idCategoria, String tipo, String fechaCreacion, String fechaFinalizacion, String nom, bool esPrivada) async {}

  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {
    if (failEnviar) throw Exception('Error enviando');
    respuestasEnviadas = List<RespuestaEntity>.from(respuestas);
  }

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria) async => [];

  @override
  Future<List<PreguntaEntity>> getPreguntas() async => preguntas;

  @override
  Future<bool> yaEvaluo(String idEvaluacion, String idEvaluador, String idEvaluado) async => false;

  @override
  Future<List<String>> getNotasPorEvaluado(String idEvaluacion, String idEvaluado, String tipo) async => [];

  @override
  Future<void> updatePrivacidad(String idEvaluacion, bool esPrivada) async {}

  @override
  Future<List<EvaluacionEntity>> getEvaluacionesIncompletasByProfe(String idCategoria) async => [];
}

class FakeCursoRepository implements ICursoRepository {
  @override
  Future<void> createCurso(String idCurso, String nom) async {}
  @override
  Future<void> updateCurso(CursoCurso curso, String NomNuevo) async {}
  @override
  Future<void> deleteCurso(String idCurso) async {}
  @override
  Future<List<CursoCurso>> getCursosByProfe() async => [];
  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(String emailEstudiante) async => [];
  @override
  Future<void> vaciarContenidoCurso(String idCurso) async {}
  @override
  Future<List<String>> getCompanerosDeGrupo(String idCat, String nombreGrupo) async => [];
  @override
  Future<List<Map<String, dynamic>>> getCategoriasByCurso(String idCurso) async => [];
  @override
  Future<List<Map<String, dynamic>>> getDatosDeGruposPorCategoria(String idCat) async => [];
}

class FakeLocalPreferences implements ILocalPreferences {
  final Map<String, dynamic> storage = {'userId': 'mi_id_de_prueba'};

  @override
  Future<String?> getString(String key) async => storage[key] as String?;
  @override
  Future<void> setString(String key, String value) async => storage[key] = value;
  @override
  Future<int?> getInt(String key) async => storage[key] as int?;
  @override
  Future<void> setInt(String key, int value) async => storage[key] = value;
  @override
  Future<double?> getDouble(String key) async => storage[key] as double?;
  @override
  Future<void> setDouble(String key, double value) async => storage[key] = value;
  @override
  Future<bool?> getBool(String key) async => storage[key] as bool?;
  @override
  Future<void> setBool(String key, bool value) async => storage[key] = value;
  @override
  Future<List<String>?> getStringList(String key) async => storage[key] as List<String>?;
  @override
  Future<void> setStringList(String key, List<String> value) async => storage[key] = value;
  @override
  Future<void> remove(String key) async => storage.remove(key);
  @override
  Future<void> clear() async => storage.clear();
}

void main() {
  late FakeEvaluacionRepository fakeRepository;
  late FakeCursoRepository fakeCursoRepository;
  late EvaluacionController controller;
  late FakeLocalPreferences fakePrefs;

  final evaluacion = EvaluacionEntity(
    id: 'eval_1',
    idCategoria: 'cat_1',
    tipo: 'Autoevaluación',
    fechaCreacion: DateTime(2026, 4, 1),
    fechaFinalizacion: DateTime(2026, 4, 10),
    nom: 'Evaluación 1',
    esPrivada: false,
  );

  setUp(() {
    Get.testMode = true;
    Get.reset();

    fakeRepository = FakeEvaluacionRepository();
    fakeCursoRepository = FakeCursoRepository();
    fakePrefs = FakeLocalPreferences();

    final fakeReporteService = FakeReporteService();
    final fakeReporteSource = FakeReporteSource();

    Get.put<ReporteController>(ReporteController(
        reporteService: fakeReporteService,
        reporteSource: fakeReporteSource
    ));

    controller = EvaluacionController(
      repository: fakeRepository,
      cursoRepository: fakeCursoRepository,
    );

    Get.put<EvaluacionController>(controller);
    Get.put<ILocalPreferences>(fakePrefs);
  });

  tearDown(() async {
    // Al final de cada test, nos aseguramos de que no queden snackbars colgados
    if (Get.isSnackbarOpen) {
      await Get.closeCurrentSnackbar();
    }
    await Get.deleteAll(force: true);
  });

  group('ResponderEvaluacionPage widget tests', () {
    testWidgets('muestra loading mientras carga preguntas', (tester) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
            grupoNombre: 'Grupo 1',
            idCat: 'cat_1',
            idCurso: 'curso_1',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('muestra mensaje si no hay preguntas', (tester) async {
      fakeRepository.preguntas = [];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
            grupoNombre: 'Grupo 1',
            idCat: 'cat_1',
            idCurso: 'curso_1',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No hay preguntas'), findsOneWidget);
    });

    testWidgets('muestra la primera pregunta y opciones', (tester) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
            grupoNombre: 'Grupo 1',
            idCat: 'cat_1',
            idCurso: 'curso_1',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('¿Cómo fue el trabajo en equipo?'), findsOneWidget);
      expect(find.text('Excelente (5)'), findsOneWidget);
      expect(find.text('Pregunta 1 de 1'), findsOneWidget);
    });

    testWidgets('activa finalizar al responder la última pregunta', (tester) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
            grupoNombre: 'Grupo 1',
            idCat: 'cat_1',
            idCurso: 'curso_1',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      
      final botonAntes = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Finalizar evaluación'));
      expect(botonAntes.onPressed, isNull);

      await tester.tap(find.text('Excelente (5)'));
      await tester.pump();

      final botonDespues = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Finalizar evaluación'));
      expect(botonDespues.onPressed, isNotNull);
    });

    testWidgets('envía respuestas al finalizar', (tester) async {
      fakeRepository.preguntas = [
        PreguntaEntity(
          idPregunta: '1',
          tipo: 'numerica',
          pregunta: '¿Cómo fue el trabajo en equipo?',
        ),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResponderEvaluacionPage(
            evaluacion: evaluacion,
            evaluadoCorreo: 'compa@uninorte.edu.co',
            grupoNombre: 'Grupo 1',
            idCat: 'cat_1',
            idCurso: 'curso_1',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      
      await tester.tap(find.text('Excelente (5)'));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Finalizar evaluación'));
      
      // 🚀 SOLUCIÓN AL ERROR:
      // 1. Pump inicial para procesar el tap y la navegación de Get.back()
      await tester.pump(); 
      
      // 2. Esperar lo suficiente para que el snackbar de "Éxito" termine su animación y temporizador
      // GetX snackbars por defecto duran 3 segundos + animaciones.
      await tester.pump(const Duration(seconds: 5));

      expect(fakeRepository.respuestasEnviadas.length, 1);
      expect(fakeRepository.respuestasEnviadas.first.idEvaluador, 'mi_id_de_prueba');
    });
  });
}
