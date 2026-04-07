import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'student_home_controller.dart'; // Importamos el controlador que acabas de crear
import '../../../../features/cursos/domain/entities/curso_matriculado.dart';
import 'student_course_details_page.dart';
import '../../../../features/auth/ui/viewsmodels/authentication_controller.dart';

class StudentHomePage extends StatelessWidget {
  final String email;

  const StudentHomePage({super.key, required this.email});

  // Colores de diseño
  final Color primaryGold = const Color(0xFFE6C363);
  final Color backgroundColor = const Color(0xFFF4F5EF);

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Inyectamos el controlador pasándole el repositorio (que ya está en main.dart) y el email
    final controller = Get.put(
      StudentHomeController(cursoRepository: Get.find(), studentEmail: email),
    );
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
              // Header
              const SizedBox(height: 20),
              Row(
                key: const Key('studentHomeHeaderRow'),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ulogo.png',
                    width: 50,
                    height: 50,
                    key: const Key('studentHomeLogo'),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Bienvenido',
                      key: Key('studentHomeWelcomeText'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // 🔥 BOTÓN DE LOGOUT
                  IconButton(
                    key: const Key('studentHomeLogoutButton'),
                    icon: const Icon(Icons.logout, color: Colors.black),
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

              // --- TARJETA EVALUACIONES ---
              _buildSummaryCard(),
              const SizedBox(height: 20),

              // --- LISTA DE CURSOS (REACTIVA CON ROBLE) ---
              Expanded(
                child: Obx(() {
                  // Mientras carga, mostramos el indicador
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        key: Key('studentHomeLoadingIndicator'),
                        color: Color(0xFF8B0000),
                      ),
                    );
                  }

                  // Si terminó de cargar y la lista está vacía
                  if (controller.cursos.isEmpty) {
                    return Center(
                      child: Column(
                        key: const Key('studentHomeEmptyCursosColumn'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.folder_off,
                            size: 80,
                            color: Colors.grey,
                            key: Key('studentHomeEmptyIcon'),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aún no estás inscrito en ningún curso.',
                            key: Key('studentHomeEmptyText'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Paleta de colores para alternar en las tarjetas
                  final cardColors = [
                    const Color(0xFF8B0000), // Rojo Uninorte
                    const Color(0xFFE6C363), // Dorado
                    const Color(0xFF2E8B57), // Verde
                    const Color(0xFF4682B4), // Azul
                  ];

                  // Dibujamos la lista con los cursos reales
                  return ListView.builder(
                    key: const Key('studentHomeCoursesListView'),
                    itemCount: controller.cursos.length,
                    itemBuilder: (context, index) {
                      final curso = controller.cursos[index];
                      // Alternamos los colores usando el índice
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

  // --- WIDGETS PRIVADOS DE DISEÑO (Se mantienen intactos) ---

  Widget _buildSummaryCard() {
    return Container(
      key: const Key('studentHomeSummaryCard'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            key: const Key('studentHomeSummaryTextColumn'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Evaluaciones pendientes",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 5),
              Text(
                "3 Tareas",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Container(
            key: const Key('studentHomeSummaryIconContainer'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment, color: primaryGold, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CursoMatriculado cursoMatriculado, Color color) {
    return GestureDetector(
      key: Key('courseGestureDetector_${cursoMatriculado.curso.id}'),
      onTap: () {
        // 🔥 Navegamos a la nueva pantalla pasando la información
        Get.to(
          () => StudentCourseDetailsPage(cursoMatriculado: cursoMatriculado),
        );
      },
      child: Container(
        key: Key('courseCardContainer_${cursoMatriculado.curso.id}'),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              key: Key('courseCardColorBand_${cursoMatriculado.curso.id}'),
              height: 15, // Banda superior un poco más delgada
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
                    key: Key('courseName_${cursoMatriculado.curso.id}'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "NRC: ${cursoMatriculado.curso.id}",
                    key: Key('courseNrc_${cursoMatriculado.curso.id}'),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 🔴 AQUÍ DIBUJAMOS LOS GRUPOS AGRUPADOS
                  const Text(
                    "Tus Asignaciones:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...cursoMatriculado.grupos.map((grupo) {
                    return Padding(
                      key: Key('groupRow_${cursoMatriculado.curso.id}_${grupo.idCat}'),
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: color),
                          const SizedBox(width: 8),
                          Text(
                            "${grupo.categoriaNombre}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(grupo.grupoNombre),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 15),
                  Container(
                    key: Key('pendingEvaluationsContainer_${cursoMatriculado.curso.id}'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Evaluaciones pendientes: ${cursoMatriculado.evaluacionesPendientes}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black,
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
