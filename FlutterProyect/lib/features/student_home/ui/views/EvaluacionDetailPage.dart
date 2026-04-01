import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/i_local_preferences.dart';
import '../../../evaluaciones/domain/entities/evaluacion_entity.dart';
import '../../../student_home/ui/views/student_course_details_controller.dart';
import '../../../evaluaciones/ui/viewmodels/evaluaciones_controller.dart';

class EvaluacionDetailPage extends StatefulWidget {
  final EvaluacionEntity evaluacion;
  final dynamic grupo;

  const EvaluacionDetailPage({
    super.key,
    required this.evaluacion,
    required this.grupo,
  });

  @override
  State<EvaluacionDetailPage> createState() =>
      _EvaluacionDetailPageState();
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

    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = Get.find<ILocalPreferences>();

    miCorreo = await prefs.getString('email');

    await _cargarEstadoEvaluaciones();
  }

  Future<void> _cargarEstadoEvaluaciones() async {
    final lista =
        controller.companerosPorCategoria[widget.grupo.idCat] ?? [];

    final companeros = lista
        .where((correo) => correo != miCorreo)
        .toList();

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
    // 🔥 Mientras carga el usuario
    if (miCorreo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lista =
        controller.companerosPorCategoria[widget.grupo.idCat] ?? [];

    final companeros = lista
        .where((correo) => correo != miCorreo)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evaluacion.nom),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: companeros.length,
        itemBuilder: (context, index) {
          final correo = companeros[index];
          final yaEvaluado = estadoEvaluacion[correo];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(correo),

              trailing: yaEvaluado == null
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : yaEvaluado
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: () {
                            print("Evaluar a $correo");

                            // 🔥 aquí luego mandas a responder preguntas
                          },
                          child: const Text("Evaluar"),
                        ),
            ),
          );
        },
      ),
    );
  }
}