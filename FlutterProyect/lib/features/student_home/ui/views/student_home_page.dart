//FlutterProyect/lib/features/student_home/ui/views/StudentHomePage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'student_home_controller.dart';
import '../../../../features/cursos/domain/entities/curso_matriculado.dart';
import 'student_course_details_page.dart';
import '../../../../features/auth/ui/viewsmodels/authentication_controller.dart';
import 'StudentPendingEvaluationsPage.dart';
import "../../../evaluaciones/ui/viewmodels/evaluaciones_controller.dart";

class StudentHomePage extends StatefulWidget {
  final String email;

  const StudentHomePage({super.key, required this.email});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final Color primaryGold = const Color(0xFFE6C363);
  final Color backgroundColor = const Color(0xFFF4F5EF);

  late StudentHomeController controller;
  late EvaluacionController evaluacionController;

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      StudentHomeController(
        cursoRepository: Get.find(),
        studentEmail: widget.email,
      ),
    );

    evaluacionController = Get.put(
      EvaluacionController(
        repository: Get.find(),
        cursoRepository: Get.find(),
      ),
    );

    // 🔥 FUNCIÓN CENTRALIZADA
    void cargarEvaluacionesPendientes() {
      final cursos = controller.cursos;

      if (cursos.isNotEmpty) {
        final grupos = cursos.expand((c) => c.grupos).toList();

        evaluacionController.cargarEvaluacionesIncompletasPorGrupos(grupos);
      }
    }

    // 🔥 REACTIVO (cuando cambien cursos)
    ever(controller.cursos, (_) {
      cargarEvaluacionesPendientes();
    });

    // 🔥 INICIAL (PRIMERA VEZ - ESTE ES EL FIX IMPORTANTE)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarEvaluacionesPendientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthenticationController>();

    return Scaffold(
      key: const Key('studentHomeScaffold'),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/ulogo.png', width: 50, height: 50),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Cerrar sesión",
                        middleText: "¿Seguro que quieres cerrar sesión?",
                        textConfirm: "Sí",
                        textCancel: "Cancelar",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.red,
                        onConfirm: () {
                          Get.back();
                          authController.logout();
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildSummaryCard(),

              const SizedBox(height: 20),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.cursos.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_off, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aún no estás inscrito en ningún curso.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final cardColors = [
                    const Color(0xFF8B0000),
                    const Color(0xFFE6C363),
                    const Color(0xFF2E8B57),
                    const Color(0xFF4682B4),
                  ];

                  return ListView.builder(
                    itemCount: controller.cursos.length,
                    itemBuilder: (context, index) {
                      final curso = controller.cursos[index];
                      final color = cardColors[index % cardColors.length];

                      return _buildCourseCard(curso, color);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Evaluaciones pendientes",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 5),

              Obx(() {
                if (evaluacionController.isLoading.value) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                final cantidad =
                    evaluacionController.evaluacionesIncompletas.length;

                return Text(
                  "$cantidad Tareas",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment, color: primaryGold),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CursoMatriculado cursoMatriculado, Color color) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => StudentCourseDetailsPage(cursoMatriculado: cursoMatriculado),
        )?.then((_) {
          final grupos =
              controller.cursos.expand((c) => c.grupos).toList();

          evaluacionController
              .cargarEvaluacionesIncompletasPorGrupos(grupos);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 15,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cursoMatriculado.curso.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "NRC: ${cursoMatriculado.curso.id}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text(
                    "Tus Asignaciones:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ...cursoMatriculado.grupos.map((grupo) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: color),
                          const SizedBox(width: 8),
                          Text(
                            "${grupo.categoriaNombre}: ",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(grupo.grupoNombre),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => StudentPendingEvaluationsPage(
                          cursoMatriculado: cursoMatriculado,
                        ),
                      )?.then((_) {
                        final grupos =
                            controller.cursos.expand((c) => c.grupos).toList();

                        evaluacionController
                            .cargarEvaluacionesIncompletasPorGrupos(grupos);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Evaluaciones pendientes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}