import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewsmodels/authentication_controller.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final controllerCode = TextEditingController();
  final AuthenticationController authController = Get.find();

  late String email;

  @override
  void initState() {
    super.initState();
    email = Get.arguments ?? authController.userEmail.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 80, color: Color.fromARGB(255, 218, 165, 33)),
              const SizedBox(height: 20),
              const Text("Verificar Email", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Mostramos el email que recuperamos en el initState
              Text("Enviamos un código a:\n$email", textAlign: TextAlign.center),
              const SizedBox(height: 30),

              // Campo para el código
              SizedBox(
                width: 200,
                child: TextField(
                  controller: controllerCode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(
                    hintText: "000000",
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón Verificar con estado de carga
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator(color: Color.fromARGB(255, 218, 165, 33))
                  : ElevatedButton(
                onPressed: () async {
                  try {
                    // Usamos la variable email local o la del controlador
                    await authController.validateCode(email, controllerCode.text);
                  } catch (e) {
                    Get.snackbar("Error", e.toString(), backgroundColor: Colors.red[100]);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 218, 165, 33),
                    foregroundColor: Colors.black
                ),
                child: const Text("Verificar Código"),
              ),
              ),

              const SizedBox(height: 20),

              // Botón Reenviar
              TextButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () async {
                  await authController.resendCode();
                },
                child: const Text("No recibí el código. Reenviar", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}