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
import 'features/auth/ui/views/login_page.dart';

import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/core/local_preferences_secured.dart';
import 'package:flutter_prueba/core/local_preferences_shared.dart';
import 'core/refresh_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  await dotenv.load(fileName: ".env");

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
    RefreshClient(
      http.Client(),
      Get.find<IAuthenticationSource>(),
    ),
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
    () => AuthenticationController(repository: Get.find<IAuthRepository>()),
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

