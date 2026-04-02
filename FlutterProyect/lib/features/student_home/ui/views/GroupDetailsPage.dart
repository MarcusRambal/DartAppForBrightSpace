//FlutterProyect/lib/features/student_home/ui/views/GroupDetailsPage.dart:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'student_course_details_controller.dart';
import 'EvaluacionDetailPage.dart';
import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';

class GroupDetailsPage extends StatefulWidget {
  final dynamic grupo;

  const GroupDetailsPage({super.key, required this.grupo});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late StudentCourseDetailsController controller;
  late EvaluacionController evaluacionController;

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      StudentCourseDetailsController(cursoRepository: Get.find()),
    );

    evaluacionController = Get.find<EvaluacionController>();

    // 🔥 Cargar compañeros
    controller.cargarCompaneros(widget.grupo.idCat, widget.grupo.grupoNombre);

    // 🔥 Cargar evaluaciones
    evaluacionController.cargarEvaluaciones(widget.grupo.idCat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.grupo.categoriaNombre)),
      body: Obx(() {
        // 🔄 Loading compañeros
        if (controller.isLoadingCategoria[widget.grupo.idCat] == true) {
          return const Center(child: CircularProgressIndicator());
        }

        final companeros =
            controller.companerosPorCategoria[widget.grupo.idCat] ?? [];

        final evaluaciones = evaluacionController.evaluaciones;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 👥 INTEGRANTES
            const Text(
              "Integrantes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: companeros.length,
              itemBuilder: (context, index) {
                final correo = companeros[index];

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(correo),
                );
              },
            ),

            const SizedBox(height: 30),

            // 📝 EVALUACIONES
            ExpansionTile(
              title: const Text(
                "Evaluaciones",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: [
                Obx(() {
                  if (evaluacionController.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (evaluaciones.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("No hay evaluaciones disponibles"),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: evaluaciones.length,
                    itemBuilder: (context, index) {
                      final eval = evaluaciones[index];

                      return ListTile(
                        title: Text(eval.nom),
                        subtitle: Text("Tipo: ${eval.tipo}"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.to(
                            () => EvaluacionDetailPage(
                              evaluacion: eval,
                              grupo: widget.grupo,
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ],
        );
      }),
    );
  }
}
