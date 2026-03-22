import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/ui/views/signup_page.dart';
import 'features/auth/ui/viewsmodels/authentication_controller.dart';
import 'features/auth/ui/views/login_page.dart';
import 'features/auth/ui/views/verificationEmail_page.dart';
import 'features/student_home/ui/views/student_home_page.dart';


class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationController authController = Get.find();

    return Obx(() {
      if (authController.isLogged.value) return const StudentHomePage(email: '',);
      if (authController.isWaitingVerification.value) return const VerificationPage();
      if (authController.isRegistering.value) return const SignUpPage();

      return const LoginPage();
    });
  }
}