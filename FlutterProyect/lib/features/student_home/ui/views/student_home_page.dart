import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'student_home_controller.dart'; // Importamos el controlador que acabas de crear

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

    return Scaffold(
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
                children: [
                  Image.asset('assets/images/ulogo.png', width: 50, height: 50),
                  const SizedBox(width: 15),
                  const Text(
                    "Bienvenido",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
                        color: Color(0xFF8B0000),
                      ),
                    );
                  }

                  // Si terminó de cargar y la lista está vacía
                  if (controller.cursos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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

                  // Paleta de colores para alternar en las tarjetas
                  final cardColors = [
                    const Color(0xFF8B0000), // Rojo Uninorte
                    const Color(0xFFE6C363), // Dorado
                    const Color(0xFF2E8B57), // Verde
                    const Color(0xFF4682B4), // Azul
                  ];

                  // Dibujamos la lista con los cursos reales
                  return ListView.builder(
                    itemCount: controller.cursos.length,
                    itemBuilder: (context, index) {
                      final curso = controller.cursos[index];
                      // Alternamos los colores usando el índice
                      final color = cardColors[index % cardColors.length];

                      return _buildCourseCard(
                        color,
                        curso.nombre, // Nombre real del curso
                        "Curso Activo", // Subtítulo
                        "NRC: ${curso.id}", // Usamos el ID como NRC
                        0, // Evaluaciones (por ahora 0)
                      );
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

  Widget _buildCourseCard(
    Color color,
    String title,
    String subtitle,
    String id,
    int pending,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banda de color superior
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          // Información del curso
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  id,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  "Evaluaciones pendientes: $pending.",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
