import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'teacher_course_details_controller.dart';
import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';

class TeacherGroupDetailsPage extends StatefulWidget {
  final String categoriaId;
  final String nombreCategoria;

  const TeacherGroupDetailsPage({
    super.key,
    required this.categoriaId,
    required this.nombreCategoria,
  });

  @override
  State<TeacherGroupDetailsPage> createState() => _TeacherGroupDetailsPageState();
}

class _TeacherGroupDetailsPageState extends State<TeacherGroupDetailsPage> {
  late TeacherCourseDetailsController controller;
  late EvaluacionController evaluacionController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherCourseDetailsController>();
    evaluacionController = Get.find<EvaluacionController>();

    // 🔹 Cargar detalle de la categoría (grupos e integrantes)
    controller.fetchDetalleCategoria(widget.categoriaId);

    // 🔹 Cargar evaluaciones por categoría
    evaluacionController.cargarEvaluaciones(widget.categoriaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nombreCategoria)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final gruposMap = controller.datosGrupos[widget.categoriaId] ?? {};
          final grupos = gruposMap.keys.toList();
          final isLoadingGrupos = controller.loadingDetalleCategoria[widget.categoriaId] ?? true;

          if (isLoadingGrupos || evaluacionController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // 👥 GRUPOS
              ExpansionTile(
                title: const Text(
                  "Grupos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: grupos.map((grupoNombre) {
                  final integrantes = List<String>.from(gruposMap[grupoNombre] ?? []);
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      title: Text(grupoNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: integrantes
                          .map((i) => ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(i),
                              ))
                          .toList(),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // 📝 EVALUACIONES
              ExpansionTile(
                initiallyExpanded: true,
                title: const Text(
                  "Evaluaciones",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  Obx(() {
                    final evals = evaluacionController.evaluaciones;
                    if (evals.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("No hay evaluaciones disponibles"),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: evals.length,
                      itemBuilder: (context, index) {
                        final e = evals[index];
                        return ListTile(
                          title: Text(e.nom),
                          subtitle: Text("Tipo: ${e.tipo}"),
                          leading: const Icon(Icons.assignment),
                          // 🔹 Teacher no navega a otra página
                        );
                      },
                    );
                  }),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}