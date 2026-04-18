//FlutterProyect/lib/features/student_home/ui/views/GroupDetailsPage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'student_course_details_controller.dart';
import 'EvaluacionDetailPage.dart';
import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';

class GroupDetailsPage extends StatefulWidget {
  final dynamic grupo;
  final dynamic cursoMatriculado;

  const GroupDetailsPage({super.key, required this.grupo, required this.cursoMatriculado});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late StudentCourseDetailsController controller;
  late EvaluacionController evaluacionController;

  // 🔥 PALETA DE COLORES
  final Color backgroundColor = const Color(0xFFF4F5EF); // Crema
  final Color primaryBlue = const Color(0xFF1A365D); // Azul Marino
  final Color goldAccent = const Color(0xFFE6C363); // Dorado

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      StudentCourseDetailsController(cursoRepository: Get.find()),
    );
    evaluacionController = Get.find<EvaluacionController>();

    controller.cargarCompaneros(widget.grupo.idCat, widget.grupo.grupoNombre);
    evaluacionController.cargarEvaluaciones(widget.grupo.idCat);
    print("=========== GRUPO DEBUG ===========");
    print(widget.grupo.grupoNombre);
    print("===================================");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('groupDetailsScaffold'),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        key: const Key('groupDetailsAppBar'),
        title: const Text(
          "Detalles del Grupo",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: primaryBlue, // Íconos y texto de la barra en azul
      ),
      body: Obx(() {
        if (controller.isLoadingCategoria[widget.grupo.idCat] == true) {
          return Center(
            child: CircularProgressIndicator(
              key: const Key('groupDetailsLoadingCompaneros'),
              color: primaryBlue,
            ),
          );
        }

        final listaCompaneros =
            controller.companerosPorCategoria[widget.grupo.idCat] ?? [];

        return ListView(
          key: const Key('groupDetailsMainList'),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // --- SECCIÓN: COMPAÑEROS ---
            Text(
              "Compañeros",
              key: const Key('groupDetailsCompanerosTitle'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
                letterSpacing: 0.5,
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
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    child: Icon(Icons.person, color: primaryBlue),
                  ),
                  title: Text(
                    correo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 35),

            // --- SECCIÓN: EVALUACIONES ---
            Text(
              "Evaluaciones",
              key: const Key('groupDetailsEvaluacionesTitle'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),

            Obx(() {
              final evaluaciones = evaluacionController.evaluaciones;
              // 🔥 EL FILTRO LÓGICO SE MANTIENE INTACTO
              final evaluacionesPublicas = evaluaciones
                  .where((e) => !e.esPrivada)
                  .toList();

              if (evaluacionController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      key: const Key('groupDetailsLoadingEvaluaciones'),
                      color: goldAccent,
                    ),
                  ),
                );
              }

              if (evaluacionesPublicas.isEmpty) {
                return _buildEmptyState(
                  key: const Key('groupDetailsEmptyEvaluaciones'),
                  message: "No hay evaluaciones disponibles en este momento.",
                  icon: Icons.assignment_outlined,
                );
              }

              return ListView.builder(
                key: const Key('groupDetailsEvaluacionesList'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: evaluacionesPublicas.length,
                itemBuilder: (context, index) {
                  final eval = evaluacionesPublicas[index];

                  return Container(
                    key: Key('evaluationCard_${eval.id}'),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: goldAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in,
                          color: goldAccent,
                        ),
                      ),
                      title: Text(
                        eval.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            // 🔥 ETIQUETA ESTILO "BADGE"
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                eval.tipo,
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: backgroundColor,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: primaryBlue,
                        ),
                      ),
                      onTap: () {
                        Get.to(
                          () => EvaluacionDetailPage(
                            evaluacion: eval,
                            grupo: widget.grupo,
                            cursoMatriculado: widget.cursoMatriculado,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 30), // Espacio extra al final
          ],
        );
      }),
    );
  }

  // Widget reutilizable para cuando no hay datos (se ve mucho mejor que un texto plano)
  Widget _buildEmptyState({
    required Key key,
    required String message,
    required IconData icon,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: primaryBlue.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: primaryBlue.withOpacity(0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
