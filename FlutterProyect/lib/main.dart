import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'central.dart';
import 'features/auth/data/dataSources/authentication_source_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/ui/viewsmodels/authentication_controller.dart';
import 'features/auth/ui/views/login_page.dart';
import 'package:flutter_prueba/core/i_local_preferences.dart';
import 'package:flutter_prueba/core/local_preferences_secured.dart';
import 'package:flutter_prueba/core/local_preferences_shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Logging
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  // 2. Cargar Env
  await dotenv.load(fileName: ".env");

  Get.lazyPut<ILocalPreferences>(() => LocalPreferencesSecured(), fenix: true);

  Get.lazyPut<IAuthRepository>(
          () => AuthRepository(AuthenticationSourceServiceRoble()),
      fenix: true
  );

  Get.lazyPut(
          () => AuthenticationController(repository: Get.find<IAuthRepository>()),
      fenix: true
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

