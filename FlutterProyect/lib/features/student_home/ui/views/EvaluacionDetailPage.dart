//FlutterProyect/lib/features/student_home/ui/views/EvaluacionDetailPage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/i_local_preferences.dart';
import '../../../evaluaciones/domain/entities/evaluacion_entity.dart';
import '../../../student_home/ui/views/student_course_details_controller.dart';
import '../../../evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import '../../../evaluaciones/ui/views/responder_evaluacion_page.dart';
import 'student_report_page.dart';

class EvaluacionDetailPage extends StatefulWidget {
  final EvaluacionEntity evaluacion;
  final dynamic grupo;
  final dynamic cursoMatriculado;

  const EvaluacionDetailPage({
    super.key,
    required this.evaluacion,
    required this.grupo,
    required this.cursoMatriculado,
  });

  @override
  State<EvaluacionDetailPage> createState() => _EvaluacionDetailPageState();
}

class _EvaluacionDetailPageState extends State<EvaluacionDetailPage> {
  late StudentCourseDetailsController controller;
  late EvaluacionController evaluacionController;

  // 🔥 Estado local para saber quién ya fue evaluado
  Map<String, bool> estadoEvaluacion = {};

  String? miCorreo;

  @override
  void initState() {
    super.initState();

    controller = Get.find<StudentCourseDetailsController>();
    evaluacionController = Get.find<EvaluacionController>();

    // 🔍 DEBUG: inspeccionar grupo
    print("=========== GRUPO DEBUG ===========");
    print(widget.grupo);
    print("idCat: ${widget.grupo.idCat}");
    print(widget.grupo.grupoNombre);
    print("===================================");
    print(widget.cursoMatriculado.curso.id);

    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = Get.find<ILocalPreferences>();

    miCorreo = await prefs.getString('email');

    await _cargarEstadoEvaluaciones();
  }

  Future<void> _cargarEstadoEvaluaciones() async {
    final lista = controller.companerosPorCategoria[widget.grupo.idCat] ?? [];

    final companeros = lista.where((correo) => correo != miCorreo).toList();

    final futures = companeros.map((correo) async {
      final ya = await evaluacionController.yaEvaluo(
        widget.evaluacion.id,
        "", // 🔥 ya no necesitas pasar esto realmente
        correo,
      );

      return MapEntry(correo, ya);
    });

    final results = await Future.wait(futures);

    estadoEvaluacion = Map.fromEntries(results);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A365D);
    const Color backgroundColor = Color(0xFFF4F5EF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Detalle de Evaluación",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Información de la Evaluación ---
            Text(
              widget.evaluacion.nom,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Inicia: ${widget.evaluacion.fechaCreacion.toString().split('.')[0]}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              "Finaliza: ${widget.evaluacion.fechaFinalizacion.toString().split('.')[0]}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            // 🔥 BOTÓN: Ver Mis Resultados
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(
                    () => StudentReportPage(
                      idEvaluacion: widget.evaluacion.id,
                      nombreEvaluacion: widget.evaluacion.nom,
                    ),
                  );
                },
                icon: const Icon(Icons.insights, color: Colors.white),
                label: const Text(
                  "VER MIS RESULTADOS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 25),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 15),

            const Text(
              "Compañeros de Grupo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),

            // --- Lista de compañeros ---
            Expanded(
              child: Obx(() {
                final lista = controller
                    .companerosPorCategoria[widget.evaluacion.idCategoria];

                if (lista == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }

                if (lista.isEmpty) {
                  return const Center(
                    child: Text("No se encontraron compañeros."),
                  );
                }

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final correo = lista[i];
                    // No te evalúas a ti mismo
                    if (correo == miCorreo) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: primaryBlue),
                        ),
                        title: Text(
                          correo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: _buildTrailingAction(
                          estadoEvaluacion[correo],
                          widget.evaluacion.fechaCreacion.isAfter(
                            DateTime.now(),
                          ),
                          widget.evaluacion.fechaFinalizacion.isBefore(
                            DateTime.now(),
                          ),
                          correo,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO PARA LIMPIAR EL CÓDIGO ---

  Widget _buildStatusBanner({
    required Key key,
    required String text,
    required Color color,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: color.withOpacity(0.1),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrailingAction(
    bool? yaEvaluado,
    bool noHaIniciado,
    bool yaCerro,
    String correo,
  ) {
    if (yaEvaluado == null) {
      return SizedBox(
        key: Key('loadingAction_$correo'),
        width: 20,
        height: 20,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (yaEvaluado) {
      return Icon(
        key: Key('checkAction_$correo'),
        Icons.check_circle,
        color: Colors.green,
      );
    }

    // Si no ha iniciado o ya cerró, mostramos el candado
    if (noHaIniciado || yaCerro) {
      return Icon(
        key: Key('lockAction_$correo'),
        noHaIniciado ? Icons.watch_later_outlined : Icons.lock_outline,
        color: noHaIniciado ? Colors.orange : Colors.red,
      );
    }

    // Si todo está ok, mostramos el botón
    return ElevatedButton(
      key: Key('evaluarButton_$correo'),
      onPressed: () async {
        await Get.to(
          () => ResponderEvaluacionPage(
            evaluacion: widget.evaluacion,
            evaluadoCorreo: correo,
            grupoNombre: widget.grupo.grupoNombre, // 👈 AQUÍ
            idCat: widget.grupo.idCat,
            idCurso: widget.cursoMatriculado.curso.id,
          ),
        );
        await _cargarEstadoEvaluaciones();
      },
      child: const Text("Evaluar"),
    );
  }
}
