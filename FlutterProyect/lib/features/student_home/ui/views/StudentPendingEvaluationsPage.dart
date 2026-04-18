//FlutterProyect/lib/features/student_home/ui/views/StudentPendingEvaluationsPage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import '../../../student_home/ui/views/EvaluacionDetailPage.dart';
import '../../../../features/cursos/domain/entities/curso_matriculado.dart';
import "student_course_details_controller.dart";

class StudentPendingEvaluationsPage extends StatefulWidget {
  final dynamic cursoMatriculado;

  const StudentPendingEvaluationsPage({
    super.key,
    required this.cursoMatriculado,
  });

  @override
  State<StudentPendingEvaluationsPage> createState() =>
      _StudentPendingEvaluationsPageState();
}

class _StudentPendingEvaluationsPageState
    extends State<StudentPendingEvaluationsPage> {
  late EvaluacionController evaluacionController;

  final Color backgroundColor = const Color(0xFFF4F5EF);
  final Color primaryBlue = const Color(0xFF1A365D);
  final Color goldAccent = const Color(0xFFE6C363);

  @override
  void initState() {
    super.initState();

    evaluacionController = Get.find<EvaluacionController>();

    if (!Get.isRegistered<StudentCourseDetailsController>()) {
      Get.put(StudentCourseDetailsController(cursoRepository: Get.find()));
    }

    final grupos = widget.cursoMatriculado.grupos;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      evaluacionController.cargarEvaluacionesIncompletasPorGrupos(grupos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Evaluaciones Pendientes"),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: primaryBlue,
        elevation: 0,
      ),
      body: Obx(() {
        final evaluaciones = evaluacionController.evaluacionesIncompletas;

        print("BUILD -> Evaluaciones cargadas: ${evaluaciones.length}");

        if (evaluacionController.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: goldAccent));
        }

        if (evaluaciones.isEmpty) {
          return const Center(child: Text("No tienes evaluaciones pendientes"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: evaluaciones.length,
          itemBuilder: (context, index) {
            final eval = evaluaciones[index];

            final List<CategoriaGrupo> grupos = widget.cursoMatriculado.grupos
                .cast<CategoriaGrupo>();

            final grupo = grupos.firstWhere(
              (g) => g.idCat.toString() == eval.idCategoria.toString(),
              orElse: () => grupos.first,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(Icons.assignment, color: goldAccent),

                title: Text(
                  eval.nom,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Categoría: ${grupo.categoriaNombre}"),
                    Text("Tipo: ${eval.tipo}"),
                  ],
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 14),

                onTap: () async {
                  await Get.to(
                    () => EvaluacionDetailPage(
                      evaluacion: eval,
                      grupo: grupo,
                      cursoMatriculado: widget.cursoMatriculado,
                    ),
                    binding: BindingsBuilder(() {
                      if (!Get.isRegistered<StudentCourseDetailsController>()) {
                        Get.put(
                          StudentCourseDetailsController(
                            cursoRepository: Get.find(),
                          ),
                        );
                      }
                    }),
                  );

                  // 🔄 RECARGA AL VOLVER
                  final grupos = widget.cursoMatriculado.grupos;

                  print("🔄 VOLVI A LA VISTA -> recargando evaluaciones");

                  evaluacionController.cargarEvaluacionesIncompletasPorGrupos(
                    grupos,
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
