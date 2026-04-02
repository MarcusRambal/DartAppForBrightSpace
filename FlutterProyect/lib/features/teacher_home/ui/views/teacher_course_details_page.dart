import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/cursos/domain/entities/curso_curso.dart';
import 'teacher_course_details_controller.dart';
import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'teacher_group_details_page.dart';

class TeacherCourseDetailsPage extends StatelessWidget {
  final CursoCurso curso;
  const TeacherCourseDetailsPage({super.key, required this.curso});

  final Color backgroundColor = const Color(0xFFF4F5EF);
  final Color primaryRed = const Color(0xFF8B1E1E);
  final Color goldAccent = const Color(0xFFE6C363);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TeacherCourseDetailsController(repository: Get.find()),
    );

    final evaluacionController = Get.put(
      EvaluacionController(repository: Get.find()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategorias(curso.id!);
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Categorías",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingCategorias.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categorias.isEmpty) {
          return const Center(child: Text("No hay categorías disponibles"));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: controller.categorias.map((cat) {
            final idCat = cat['idcat'].toString();
            final nombreCategoria = (cat['nombre'] ?? 'Sin nombre').toString();

            return GestureDetector(
              onTap: () {
                Get.to(() => TeacherGroupDetailsPage(categoriaId: idCat, nombreCategoria: nombreCategoria));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryRed.withOpacity(0.12),
                      child: Icon(Icons.category_rounded, color: primaryRed),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        nombreCategoria,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: goldAccent),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}