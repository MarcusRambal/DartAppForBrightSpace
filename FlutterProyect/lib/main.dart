//FlutterProyect/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;

import 'central.dart';
import 'features/auth/data/dataSources/authentication_source_service.dart';
import 'features/auth/data/dataSources/i_authentication_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/ui/viewsmodels/authentication_controller.dart';

import 'features/cursos/data/dataSources/curso_source_service.dart';
import 'features/cursos/data/dataSources/i_curso_source.dart';
import 'features/cursos/data/repositories/curso_repository.dart';
import 'features/cursos/domain/repositories/i_curso_repository.dart';
import 'features/cursos/ui/viewsmodels/curso_controller.dart';

import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/core/local_preferences_secured.dart';
import 'core/refresh_client.dart';

import 'features/grupos/data/dataSources/grupo_source_service_roble.dart';
import 'features/grupos/data/dataSources/i_grupo_source.dart';
import 'features/grupos/data/repositories/grupo_repository.dart';
import 'features/grupos/domain/repositories/i_grupo_repository.dart';
import 'features/grupos/ui/viewmodels/grupo_import_controller.dart';

import 'features/evaluaciones/data/dataSources/evaluacion_source_service.dart';
import 'features/evaluaciones/data/dataSources/i_evaluacion_source.dart';
import 'features/evaluaciones/data/repositories/evaluacion_repository.dart';
import 'features/evaluaciones/domain/repositories/i_evaluacion_repository.dart';
import 'features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'features/shared/domain/services/i_notification_service.dart';
import 'features/shared/infrastructure/services/notification_service.dart';
import 'features/cursos/data/dataSources/local_curso_cache_source.dart';

import 'features/reportes/data/dataSources/i_reporte_source.dart';
import 'features/reportes/data/dataSources/reporte_source_service.dart';
import 'features/reportes/domain/services/ReporteService.dart';
import 'features/reportes/ui/viewsmodels/reporte_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  await dotenv.load(fileName: ".env");

  Get.lazyPut<INotificationService>(() => NotificationService(), fenix: true);

  // 🔐 Storage (donde se guarda el token)
  Get.lazyPut<ILocalPreferences>(() => LocalPreferencesSecured(), fenix: true);

  // 🔥 NUEVO: Registramos el servicio de autenticación
  // Este contiene el método refreshToken()
  Get.lazyPut<IAuthenticationSource>(
    () => AuthenticationSourceServiceRoble(),
    fenix: true,
  );

  // 🔥 NUEVO: Cliente HTTP con interceptor (RefreshClient)
  // Este reemplaza al http.Client normal
  // Aquí ocurre automáticamente:
  // - añadir token
  // - detectar 401
  // - hacer refresh
  // - reintentar request
  Get.put<http.Client>(
    RefreshClient(http.Client(), Get.find<IAuthenticationSource>()),
    tag: 'apiClient', // 🔑 importante para usarlo después
    permanent: true,
  );

  // 🔄 MODIFICADO: ahora el repo usa el auth source desde Get
  Get.lazyPut<IAuthRepository>(
    () => AuthRepository(Get.find<IAuthenticationSource>()),
    fenix: true,
  );

  // Controller (sin cambios)
  Get.lazyPut(
    () => AuthenticationController(
      repository: Get.find<IAuthRepository>(),
      notificationService: Get.find<INotificationService>(),
    ),
    fenix: true,
  );
  // 📚 CURSOS

  // DataSource Cursos
  Get.lazyPut<ICursoSource>(
    () => CursoSourceServiceRoble(
      client: Get.find<http.Client>(tag: 'apiClient'),
    ),
    fenix: true,
  );

  // Registramos la clase del Caché
  Get.lazyPut<LocalCursoCacheSource>(
    () => LocalCursoCacheSource(Get.find<ILocalPreferences>()),
    fenix: true,
  );

  // Repository Cursos
  Get.lazyPut<ICursoRepository>(
    () => CursoRepository(
      Get.find<ICursoSource>(),
      Get.find<
        LocalCursoCacheSource
      >(), // 🔥 Le pasamos el caché al repositorio
    ),
    fenix: true,
  );

  // Controller
  Get.lazyPut(
    () => CursoController(repository: Get.find<ICursoRepository>()),
    fenix: true,
  );

  // 👥 GRUPOS
  Get.lazyPut<IGrupoSource>(
    () => GrupoSourceServiceRoble(
      client: Get.find<http.Client>(tag: 'apiClient'),
    ),
    fenix: true,
  );
  Get.lazyPut<IGrupoRepository>(
    () => GrupoRepository(Get.find<IGrupoSource>()),
    fenix: true,
  );
  Get.lazyPut(
    () => GrupoImportController(repository: Get.find<IGrupoRepository>()),
    fenix: true,
  );
  // 📝 EVALUACIONES

  // DataSource
  Get.lazyPut<IEvaluacionSource>(
    () => EvaluacionSourceService(
      client: Get.find<http.Client>(tag: 'apiClient'),
    ),
    fenix: true,
  );

  // Repository
  Get.lazyPut<IEvaluacionRepository>(
    () => EvluacionRepository(Get.find<IEvaluacionSource>()),
    fenix: true,
  );

  // Controller
  Get.lazyPut(
    () => EvaluacionController(repository: Get.find<IEvaluacionRepository>(),cursoRepository: Get.find<ICursoRepository>(),),
    fenix: true,
  );

  // 📊 REPORTES

  // DataSource
  Get.lazyPut<IReporteSource>(
    () => ReporteSourceService(client: Get.find<http.Client>(tag: 'apiClient')),
    fenix: true,
  );

  // Service
  Get.lazyPut<ReporteService>(
    () => ReporteService(
      Get.find<IEvaluacionSource>(),
      Get.find<IReporteSource>(),
      Get.find<ICursoRepository>(),
    ),
    fenix: true,
  );

  // Controller
  Get.lazyPut(
    () => ReporteController(
      reporteService: Get.find<ReporteService>(),
      reporteSource: Get.find<IReporteSource>(),
    ),
    fenix: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Login Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const Central(),
    );
  }
}
