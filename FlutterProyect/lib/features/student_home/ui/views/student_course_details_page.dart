import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/cursos/domain/entities/curso_matriculado.dart';
import 'student_course_details_controller.dart';

class StudentCourseDetailsPage extends StatelessWidget {
  final CursoMatriculado cursoMatriculado;

  const StudentCourseDetailsPage({super.key, required this.cursoMatriculado});

  final Color primaryGold = const Color(0xFFE6C363);
  final Color darkRed = const Color(0xFF8B0000);

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador de esta pantalla
    final controller = Get.put(
      StudentCourseDetailsController(cursoRepository: Get.find()),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Detalles del Curso",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER DEL CURSO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: darkRed,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cursoMatriculado.curso.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "NRC: ${cursoMatriculado.curso.id}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- LISTA DE GRUPOS INTERACTIVA ---
            const Text(
              "Tus Grupos de Trabajo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ...cursoMatriculado.grupos.map((grupo) {
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
                child: ExpansionTile(
                  iconColor: primaryGold,
                  collapsedIconColor: Colors.grey,
                  title: Text(
                    grupo.categoriaNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Asignación: ${grupo.grupoNombre}",
                    style: TextStyle(
                      color: darkRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 🔥 Cuando se abre, llama al controlador para buscar compañeros
                  onExpansionChanged: (isExpanded) {
                    if (isExpanded) {
                      controller.cargarCompaneros(
                        grupo.idCat,
                        grupo.grupoNombre,
                      );
                    }
                  },
                  children: [
                    Container(
                      color: Colors.grey.shade50,
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: Obx(() {
                        // 1. Estado de Carga
                        if (controller.isLoadingCategoria[grupo.idCat] ==
                            true) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // 2. Mostrar la lista de compañeros
                        final companeros =
                            controller.companerosPorCategoria[grupo.idCat] ??
                            [];

                        if (companeros.isEmpty) {
                          return const Text(
                            "No hay compañeros registrados en este grupo.",
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Integrantes:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...companeros.map(
                              (correo) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.blueGrey,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        correo,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
