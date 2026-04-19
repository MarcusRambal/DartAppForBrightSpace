import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'teacher_course_details_controller.dart';
import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'teacher_report_page.dart';

class TeacherGroupDetailsPage extends StatefulWidget {
  final String categoriaId;
  final String nombreCategoria;

  const TeacherGroupDetailsPage({
    super.key,
    required this.categoriaId,
    required this.nombreCategoria,
  });

  @override
  State<TeacherGroupDetailsPage> createState() =>
      _TeacherGroupDetailsPageState();
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
    // 🔥 Definimos los colores de la paleta
    const Color backgroundColor = Color(0xFFF4F5EF); // Crema
    const Color primaryBlue = Color(0xFF1A365D); // Azul Marino
    const Color goldAccent = Color(0xFFE6C363); // Dorado

    return Scaffold(
      key: const Key('teacherGroupDetailsScaffold'),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        key: const Key('teacherGroupDetailsAppBar'),
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: primaryBlue, // Texto y flecha en azul marino
        centerTitle: true,
        title: Text(
          widget.nombreCategoria,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        // 🔥 AQUÍ ESTÁ TU LÓGICA ORIGINAL INTACTA
        final gruposMap = controller.datosGrupos[widget.categoriaId] ?? {};
        final grupos = gruposMap.keys.toList();
        final isLoadingGrupos =
            controller.loadingDetalleCategoria[widget.categoriaId] ?? true;

        if (isLoadingGrupos || evaluacionController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              key: Key('teacherGroupDetailsLoadingIndicator'),
              color: primaryBlue,
            ),
          );
        }

        return ListView(
          key: const Key('teacherGroupDetailsMainList'),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // 👥 SECCIÓN: GRUPOS E COMPAÑEROS
            const Text(
              "Grupos",
              key: Key('teacherGroupDetailsGruposTitle'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),

            if (grupos.isEmpty)
              _buildEmptyState(
                key: const Key('teacherGroupDetailsEmptyGrupos'),
                message: "No hay grupos disponibles.",
                icon: Icons.group_off,
                primaryBlue: primaryBlue,
              ),

            ...grupos.map((grupoNombre) {
              final integrantes = List<String>.from(
                gruposMap[grupoNombre] ?? [],
              );

              return Container(
                key: Key('teacherGroupCard_$grupoNombre'),
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
                child: Theme(
                  // Quitamos las líneas divisorias que trae por defecto el ExpansionTile
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: Key('teacherGroupExpansion_$grupoNombre'),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      grupoNombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    children: integrantes
                        .map(
                          (i) => ListTile(
                            key: Key('teacherIntegrante_$i'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 0,
                            ),
                            leading: const Icon(
                              Icons.person,
                              color: primaryBlue,
                              size: 18,
                            ),
                            title: Text(
                              i,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 35),

            // 📝 SECCIÓN: EVALUACIONES
            const Text(
              "Evaluaciones",
              key: Key('teacherGroupDetailsEvaluacionesTitle'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),

            Obx(() {
              final evals = evaluacionController.evaluaciones;

              if (evals.isEmpty) {
                return _buildEmptyState(
                  key: const Key('teacherGroupDetailsEmptyEvaluaciones'),
                  message: "No hay evaluaciones creadas.",
                  icon: Icons.assignment_outlined,
                  primaryBlue: primaryBlue,
                );
              }

              return ListView.builder(
                key: const Key('teacherGroupDetailsEvaluacionesList'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: evals.length,
                itemBuilder: (context, index) {
                  final e = evals[index];

                  return Container(
                    key: Key('teacherEvaluationCard_${e.id}'),
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
                        child: const Icon(
                          Icons.assignment_turned_in,
                          color: goldAccent,
                        ),
                      ),
                      title: Text(
                        e.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            // 🏷️ ETIQUETA DE TIPO (General)
                            Container(
                              key: Key('teacherEvaluationTypeBadge_${e.id}'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e.tipo,
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 🔒 ETIQUETA DE ESTADO (Privada / Pública) PARA EL PROFESOR
                            Container(
                              key: Key('teacherEvaluationStatusBadge_${e.id}'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: e.esPrivada
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    e.esPrivada ? Icons.lock : Icons.public,
                                    size: 12,
                                    color: e.esPrivada
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    e.esPrivada ? "Privada" : "Pública",
                                    style: TextStyle(
                                      color: e.esPrivada
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 🔥 AQUÍ ESTÁ EL BOTÓN DE RESULTADOS INTEGRADO
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => evaluacionController.cambiarPrivacidad(
                              e.id,
                              e.esPrivada,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: e.esPrivada
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: e.esPrivada
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    e.esPrivada
                                        ? Icons.lock_outline
                                        : Icons.public,
                                    size: 14,
                                    color: e.esPrivada
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    e.esPrivada
                                        ? "Privada"
                                        : "Pública", // En UI usamos Pública
                                    style: TextStyle(
                                      color: e.esPrivada
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // --- 📊 BOTÓN DE RESULTADOS (El que ya tenías) ---
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.to(
                                () => TeacherReportPage(
                                  idEvaluacion: e.id!,
                                  nombreEvaluacion: e.nom,
                                  idCategoria: widget.categoriaId,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.analytics_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "RESULTADOS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }

  // Widget auxiliar para cuando las listas están vacías
  Widget _buildEmptyState({required Key key, required String message, required IconData icon, required Color primaryBlue}) {
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
