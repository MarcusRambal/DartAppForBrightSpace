import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../viewsmodels/authentication_controller.dart';
import 'signup_page.dart'; // Para poder navegar a la página de registro
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1️⃣ Clave para el formulario y controladores de texto
  final _formKey = GlobalKey<FormState>();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final AuthenticationController authenticationController = Get.find();

  // 2️⃣ Método que llama al controller para hacer login
  Future<void> _login(String email, String password) async {
    logInfo('_login $email $password');
    try {
      bool success = await authenticationController.login(email, password);
      if (!success) {
        Get.snackbar(
          "Login failed",
          "Invalid email or password",
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Login exitoso -> ir a HomePage y pasar el email
        Get.to(() => HomePage(email: email));
      }
    } catch (err) {
      Get.snackbar(
        "Error",
        err.toString(),
        icon: const Icon(Icons.error, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(245, 244, 245, 239), // color de fondo
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/ulogo.png', // tu imagen
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(
                    height: 0,
                  ), // espacio entre imagen y formulario

                  Form(
                    key: _formKey,

                    child: Container(
                      width: 350,
                      margin: EdgeInsets.only(top: 50),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 3️⃣ Campo de email
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: controllerEmail,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Colors
                                    .grey, // color cuando el campo está enfocado o flotando
                                fontWeight: FontWeight
                                    .bold, // opcional: que resalte más
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey, // 👈 color cuando el usuario escribe
                                  width: 2, // ancho del borde cuando enfocado
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter email";
                              } else if (!value.contains('@')) {
                                return "Enter valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // 4️⃣ Campo de contraseña
                          TextFormField(
                            controller: controllerPassword,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Colors
                                    .grey, // color cuando el campo está enfocado o flotando
                                fontWeight: FontWeight
                                    .bold, // opcional: que resalte más
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey, // 👈 color cuando el usuario escribe
                                  width: 2, // ancho del borde cuando enfocado
                                ),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter password";
                              } else if (value.length < 6) {
                                return "Password must have at least 6 characters";
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) async {
                              if (_formKey.currentState!.validate()) {
                                await _login(
                                  controllerEmail.text,
                                  controllerPassword.text,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          // 5️⃣ Botón de login
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonal(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await _login(
                                        controllerEmail.text,
                                        controllerPassword.text,
                                      );
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      const Color.fromARGB(255, 218, 165, 33),
                                    ), // color de fondo
                                    foregroundColor: WidgetStateProperty.all(
                                      Colors.black,
                                    ), // color del texto
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ), // bordes redondeados
                                    ),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // 6️⃣ Botón para ir a registro
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Create account",
                              style: TextStyle(
                                color: Color.fromARGB(255, 136, 136, 135),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
