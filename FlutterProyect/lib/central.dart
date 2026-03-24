import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/ui/views/signup_page.dart';
import 'features/auth/ui/viewsmodels/authentication_controller.dart';
import 'features/auth/ui/views/login_page.dart';
import 'features/auth/ui/views/verificationEmail_page.dart';
import 'features/student_home/ui/views/student_home_page.dart';
import 'features/teacher_home/ui/views/teacher_home_page.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticationController authController = Get.find();

    return Obx(() {
      // Usuario logueado
      if (authController.isLogged.value) {
        // Verificamos rol del usuario
        final user = authController.loggedUser.value;
        if (user != null && user.rol == 'estudiante') {
          return StudentHomePage(email: user.email);
        } else {
          if (user != null && user.rol == 'profesor') {
            return TeacherHomePage(email: user.email);
          } else {
            // Si no es estudiante, se puede redirigir a otra página o mostrar un mensaje
            return Scaffold(
              body: Center(child: Text('No tienes permisos para acceder.')),
            );
          }
        }
      }

      if (authController.isWaitingVerification.value) {
        return const VerificationPage();
      }
      if (authController.isRegistering.value) return const SignUpPage();

      return const LoginPage();
    });
  }
}
