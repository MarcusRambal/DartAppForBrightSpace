//FlutterProyect/lib/features/student_home/ui/views/GroupDetailsPage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'student_course_details_controller.dart';
import 'EvaluacionDetailPage.dart';
import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';

class GroupDetailsPage extends StatefulWidget {
  final dynamic grupo;
  final dynamic cursoMatriculado;

  const GroupDetailsPage({
    super.key,
    required this.grupo,
    required this.cursoMatriculado,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late StudentCourseDetailsController controller;
  late EvaluacionController evaluacionController;

  final Color backgroundColor = const Color(0xFFF4F5EF);
  final Color primaryBlue = const Color(0xFF1A365D);
  final Color goldAccent = const Color(0xFFE6C363);

  bool isScreenLoading = true;

  @override
  void initState() {
    super.initState();

    controller = Get.find<StudentCourseDetailsController>();
    evaluacionController = Get.find<EvaluacionController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarTodo();
    });
  }

  // 🔥 CARGA ORDENADA + REUTILIZABLE
  Future<void> _cargarTodo() async {
    try {
      setState(() => isScreenLoading = true);

      await controller.cargarCompaneros(
        widget.grupo.idCat,
        widget.grupo.grupoNombre,
      );

      await evaluacionController.cargarEvaluaciones(widget.grupo.idCat);

      await evaluacionController.cargarEvaluacionesIncompletasPorGrupos([
        widget.grupo,
      ]);
    } finally {
      if (mounted) {
        setState(() => isScreenLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isScreenLoading) {
      return Scaffold(
        key: const Key('groupDetailsScreenLoadingScaffold'),
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            key: const Key('groupDetailsScreenLoadingIndicator'),
            color: primaryBlue,
          ),
        ),
      );
    }

    return Scaffold(
      key: const Key('groupDetailsScaffold'),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        key: const Key('groupDetailsAppBar'),
        title: const Text("Detalles del Grupo"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: primaryBlue,
        actions: [
          IconButton(
            key: const Key('groupDetailsRefreshButton'),
            icon: const Icon(Icons.refresh),
            onPressed: _cargarTodo, // 🔥 recarga completa
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingCategoria[widget.grupo.idCat] == true) {
          return Center(
            child: CircularProgressIndicator(
              key: const Key('groupDetailsObxLoadingIndicator'),
              color: primaryBlue,
            ),
          );
        }

        final listaCompaneros =
            controller.companerosPorCategoria[widget.grupo.idCat] ?? [];

        final evaluaciones = evaluacionController.evaluaciones;

        return ListView(
          key: const Key('groupDetailsMainList'),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // ---------------- EVALUACIONES ----------------
            Text(
              "Evaluaciones",
              key: const Key('groupDetailsEvaluacionesTitle'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 15),

            if (evaluaciones.isEmpty)
              _buildEmptyState(
                key: const Key('groupDetailsEmptyEvaluaciones'),
                message: "No hay evaluaciones disponibles.",
                icon: Icons.assignment_outlined,
              )
            else
              ListView.builder(
                key: const Key('groupDetailsEvaluacionesList'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: evaluaciones.length,
                itemBuilder: (context, index) {
                  final eval = evaluaciones[index];
                  final completa = evaluacionController.estaCompleta(eval.id);

                  final tipo = eval.esPrivada ? "Privada" : "Pública";

                  return Container(
                    key: Key('evaluationCard_${eval.id}'),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: goldAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.assignment, color: goldAccent),
                      ),
                      title: Text(
                        eval.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tipo: ${eval.tipo}"),
                          const SizedBox(height: 6),
                          Container(
                            key: Key('evaluationBadge_${eval.id}'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: eval.esPrivada
                                  ? Colors.red.withOpacity(0.15)
                                  : Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tipo,
                              style: TextStyle(
                                color: eval.esPrivada
                                    ? Colors.red
                                    : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        key: Key('evaluationStatusIcon_${eval.id}'),
                        completa ? Icons.check_circle : Icons.arrow_forward_ios,
                        color: completa ? Colors.green : primaryBlue,
                        size: 20,
                      ),
                      onTap: () {
                        Get.to(
                          () => EvaluacionDetailPage(
                            evaluacion: eval,
                            grupo: widget.grupo,
                            cursoMatriculado: widget.cursoMatriculado,
                          ),
                        )?.then((_) {
                          _cargarTodo(); // 🔥 recarga al volver
                        });
                      },
                    ),
                  );
                },
              ),

            const SizedBox(height: 35),

            // ---------------- COMPAÑEROS ----------------
            Text(
              "Compañeros",
              key: const Key('groupDetailsCompanerosTitle'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 15),

            if (listaCompaneros.isEmpty)
              _buildEmptyState(
                key: const Key('groupDetailsEmptyCompaneros'),
                message: "No hay compañeros asignados.",
                icon: Icons.group_off,
              ),

            ...listaCompaneros.map((correo) {
              return Container(
                key: Key('companeroCard_$correo'),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    child: Icon(Icons.person, color: primaryBlue),
                  ),
                  title: Text(correo),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState({required Key key, required String message, required IconData icon}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
