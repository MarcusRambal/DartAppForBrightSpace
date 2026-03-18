import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'features/auth/data/dataSources/authentication_source_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/ui/viewsmodels/authentication_controller.dart';
import 'features/auth/ui/views/login_page.dart';

void main() {
  // Inicializar logging
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  // 1️⃣ Registrar repositorio de autenticación simulado
  Get.put<IAuthRepository>(
    AuthRepository(
      AuthenticationSourceServiceRoble(),
    ),
  );

  // 2️⃣ Registrar el controller de autenticación
  Get.put(
    AuthenticationController(Get.find()),
  );

  // 3️⃣ Correr la app
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
      home: const LoginPage(), // Pantalla inicial de prueba
    );
  }
}