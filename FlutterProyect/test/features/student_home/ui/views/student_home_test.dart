import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_prueba/features/student_home/ui/views/student_home_page.dart';
import 'package:flutter_prueba/features/auth/ui/viewsmodels/authentication_controller.dart';
import 'package:flutter_prueba/features/cursos/domain/repositories/i_curso_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/evaluacion_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/pregunta_entity.dart';
import 'package:flutter_prueba/features/evaluaciones/domain/entities/respuesta_entity.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_matriculado.dart';
import 'package:flutter_prueba/features/cursos/domain/entities/curso_curso.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/features/auth/domain/entities/authentication_user.dart';

// --- FAKES ---

class FakeCursoRepository extends Fake implements ICursoRepository {
  List<CursoMatriculado> cursosSimulados = [];
  @override
  Future<List<CursoMatriculado>> getCursosByEstudiante(String email) async => cursosSimulados;
  @override
  Future<List<String>> getCompanerosDeGrupo(String idCat, String nombreGrupo) async => [];
}

class FakeEvaluacionRepository extends Fake implements IEvaluacionRepository {
  @override
  Future<List<EvaluacionEntity>> getEvaluacionesByProfe(String idCategoria) async => [];
  @override
  Future<bool> yaEvaluo(String idEval, String idEvaluador, String idEvaluado) async => false;
  @override
  Future<List<PreguntaEntity>> getPreguntas() async => [];
  @override
  Future<List<EvaluacionEntity>> getEvaluacionesIncompletasByProfe(String idCategoria) async => [];
  @override
  Future<void> createEvaluacion(String idCategoria, String tipo, String fechaCreacion, String fechaFinalizacion, String nom, bool esPrivada) async {}
  @override
  Future<void> createRespuestas(List<RespuestaEntity> respuestas) async {}
  @override
  Future<List<String>> getNotasPorEvaluado(String idEvaluacion, String idEvaluado, String tipo) async => [];
  @override
  Future<void> updatePrivacidad(String idEvaluacion, bool esPrivada) async {}
}

class FakeLocalPreferences extends Fake implements ILocalPreferences {
  @override
  Future<String?> getString(String key) async => "test@test.com";
}

class MockAuthController extends GetxController implements AuthenticationController {
  bool logoutCalled = false;
  
  // 🔥 CORREGIDO: Se quita 'name' y se puede añadir 'rol' si es necesario, 
  // según tu definición de AuthenticationUser
  @override
  var loggedUser = Rxn<AuthenticationUser>(AuthenticationUser(
    id: "1", 
    email: "test@test.com", 
    rol: "estudiante"
  ));
  
  @override
  var isLogged = true.obs;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeCursoRepository fakeRepo;
  late FakeEvaluacionRepository fakeEvalRepo;
  late MockAuthController mockAuth;
  const tEmail = "marcus@uninorte.edu.co";

  final cursoMock = CursoMatriculado(
    curso: CursoCurso(id: "NRC-5555", nombre: "Diseño de Sistemas", idProfesor: "P123"),
    grupos: [
      CategoriaGrupo(idCat: "cat_proj", categoriaNombre: "Proyecto", grupoNombre: "Grupo 04"),
    ],
  );

  setUp(() {
    Get.testMode = true;
    Get.reset();
    
    fakeRepo = FakeCursoRepository();
    fakeEvalRepo = FakeEvaluacionRepository();
    mockAuth = MockAuthController();

    // Inyectamos todas las dependencias necesarias para StudentHomePage
    Get.put<ICursoRepository>(fakeRepo);
    Get.put<IEvaluacionRepository>(fakeEvalRepo);
    Get.put<ILocalPreferences>(FakeLocalPreferences());
    Get.put<AuthenticationController>(mockAuth);
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('StudentHomePage Widget Tests', () {

    testWidgets('Debe mostrar indicador de carga mientras busca los cursos', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: StudentHomePage(email: tEmail)));
      
      expect(find.byKey(const Key('studentHomeLoadingIndicator')), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje de lista vacía si no hay cursos', (tester) async {
      fakeRepo.cursosSimulados = [];

      await tester.pumpWidget(GetMaterialApp(home: StudentHomePage(email: tEmail)));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Aún no estás inscrito en ningún curso.'), findsOneWidget);
    });

    testWidgets('Debe listar los cursos correctamente cuando el repo devuelve datos', (tester) async {
      fakeRepo.cursosSimulados = [cursoMock];

      await tester.pumpWidget(GetMaterialApp(home: StudentHomePage(email: tEmail)));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text("Diseño de Sistemas"), findsOneWidget);
      expect(find.text("NRC: NRC-5555"), findsOneWidget);
      expect(find.text("Grupo 04"), findsOneWidget);
    });

    testWidgets('Debe mostrar el diálogo de confirmación al presionar Logout', (WidgetTester tester) async {
      fakeRepo.cursosSimulados = [];

      await tester.pumpWidget(GetMaterialApp(home: StudentHomePage(email: tEmail)));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byKey(const Key('studentHomeLogoutButton')));
      await tester.pump();

      expect(find.text("Cerrar sesión"), findsOneWidget);
      await tester.tap(find.text("Sí"));
      await tester.pump();

      expect(mockAuth.logoutCalled, isTrue);
    });
  });
}
