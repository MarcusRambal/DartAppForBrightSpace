import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/entities/authentication_user.dart';
import '../viewsmodels/authentication_controller.dart';
import 'signup_page.dart';
import '../../../student_home/ui/views/student_home_page.dart';
import '../../../teacher_home/ui/views/teacher_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final AuthenticationController authenticationController = Get.find();

  Future<void> _login(String email, String password) async {
    final cleanEmail = controllerEmail.text.trim().toLowerCase();

    logInfo('_login $email $password');

    try {
      bool success = await authenticationController.login(cleanEmail, password);


      if (!success) {
        Get.snackbar(
          "Login failed",
          "Invalid email or password",
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        if (authenticationController.role == UserRole.teacher) {
          Get.off(() => TeacherHomePage(email: cleanEmail));
        } else {
          Get.off(() => StudentHomePage(email: cleanEmail));
        }
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
        color: const Color.fromARGB(245, 244, 245, 239),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/ulogo.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 0),
                  Form(
                    key: _formKey,
                    child: Container(
                      width: 350,
                      margin: const EdgeInsets.only(top: 50),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
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
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 2,
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
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 2,
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
                                    ),
                                    foregroundColor: WidgetStateProperty.all(
                                      Colors.black,
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
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
