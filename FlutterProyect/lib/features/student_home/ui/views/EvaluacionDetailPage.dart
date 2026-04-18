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

  Map<String, bool> estadoEvaluacion = {};
  String? miCorreo;

  @override
  void initState() {
    super.initState();

    controller = Get.find<StudentCourseDetailsController>();
    evaluacionController = Get.find<EvaluacionController>();

    _init();
  }

  /// 🔥 FLUJO SEGURO
  Future<void> _init() async {
    await controller.cargarCompaneros(
      widget.grupo.idCat,
      widget.grupo.grupoNombre,
    );

    await _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = Get.find<ILocalPreferences>();
    miCorreo = await prefs.getString('email');

    await _cargarEstadoEvaluaciones();
  }

  Future<void> _cargarEstadoEvaluaciones() async {
    print("===== INICIO _cargarEstadoEvaluaciones =====");

    final lista =
        controller.companerosPorCategoria[widget.grupo.idCat] ?? [];

    print("LISTA BRUTA: $lista");
    print("MI CORREO: $miCorreo");

    final companeros =
        lista.where((correo) => correo != miCorreo).toList();

    print("COMPANEROS FILTRADOS: $companeros");

    if (companeros.isEmpty) {
      print("⚠️ NO HAY COMPAÑEROS PARA EVALUAR");

      if (!mounted) return;
      setState(() {
        estadoEvaluacion = {};
      });

      return;
    }

    final results = await Future.wait(
      companeros.map((correo) async {
        try {
          print("➡️ consultando yaEvaluo: $correo");

          final ya = await evaluacionController.yaEvaluo(
            widget.evaluacion.id,
            "",
            correo,
          );

          print("✔️ resultado yaEvaluo $correo = $ya");

          return MapEntry(correo, ya);
        } catch (e) {
          print("❌ ERROR yaEvaluo $correo: $e");
          return MapEntry(correo, false);
        }
      }),
    );

    if (!mounted) return;

    setState(() {
      estadoEvaluacion = Map.fromEntries(results);
    });

    print("RESULTADOS FINALES: $results");
    print("===== FIN _cargarEstadoEvaluaciones =====");
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

            /// 🔥 BOTÓN RESULTADOS
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
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 25),
            const Divider(),
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

            /// 🔥 LISTA
            Expanded(
              child: Obx(() {
                final lista = controller
                    .companerosPorCategoria[widget.evaluacion.idCategoria];

                if (lista == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
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

                    if (correo == miCorreo) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(correo),
                        trailing: _buildTrailingAction(
                          estadoEvaluacion[correo],
                          widget.evaluacion.fechaCreacion
                              .isAfter(DateTime.now()),
                          widget.evaluacion.fechaFinalizacion
                              .isBefore(DateTime.now()),
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

  Widget _buildTrailingAction(
    bool? yaEvaluado,
    bool noHaIniciado,
    bool yaCerro,
    String correo,
  ) {
    if (yaEvaluado == null) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (yaEvaluado) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (noHaIniciado || yaCerro) {
      return Icon(
        noHaIniciado ? Icons.watch_later_outlined : Icons.lock_outline,
        color: noHaIniciado ? Colors.orange : Colors.red,
      );
    }

    return ElevatedButton(
      onPressed: () {
        Get.to(
          () => ResponderEvaluacionPage(
            evaluacion: widget.evaluacion,
            evaluadoCorreo: correo,
            grupoNombre: widget.grupo.grupoNombre,
            idCat: widget.grupo.idCat,
            idCurso: widget.cursoMatriculado.curso.id,
          ),
        )?.whenComplete(() async {
          await _cargarEstadoEvaluaciones();
        });
      },
      child: const Text("Evaluar"),
    );
  }
}