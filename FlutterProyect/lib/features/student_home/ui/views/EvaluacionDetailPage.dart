//FlutterProyect/lib/features/student_home/ui/views/EvaluacionDetailPage.dart:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/i_local_preferences.dart';
import '../../../evaluaciones/domain/entities/evaluacion_entity.dart';
import '../../../student_home/ui/views/student_course_details_controller.dart';
import '../../../evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import '../../../evaluaciones/ui/views/responder_evaluacion_page.dart';

class EvaluacionDetailPage extends StatefulWidget {
  final EvaluacionEntity evaluacion;
  final dynamic grupo;

  const EvaluacionDetailPage({
    super.key,
    required this.evaluacion,
    required this.grupo,
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
    const Color backgroundColor = Color(0xFFF4F5EF);
    const Color primaryBlue = Color(0xFF1A365D);

    if (miCorreo == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lista = controller.companerosPorCategoria[widget.grupo.idCat] ?? [];
    final companeros = lista.where((correo) => correo != miCorreo).toList();

    // 🕒 OBTENEMOS LA HORA ACTUAL
    final now = DateTime.now();

    // 🚪 LAS DOS LLAVES DEL CANDADO
    final bool noHaIniciado = now.isBefore(widget.evaluacion.fechaCreacion);
    final bool yaCerro = now.isAfter(widget.evaluacion.fechaFinalizacion);
    final bool estaDisponible = !noHaIniciado && !yaCerro;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.evaluacion.nom),
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 📢 AVISOS DE ESTADO
          if (noHaIniciado)
            _buildStatusBanner(
              "Esta evaluación iniciará a las ${widget.evaluacion.fechaCreacion.hour}:${widget.evaluacion.fechaCreacion.minute.toString().padLeft(2, '0')}",
              Colors.orange,
            ),

          if (yaCerro)
            _buildStatusBanner("Esta evaluación ha cerrado.", Colors.red),

          Expanded(
            child: ListView.builder(
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
                    trailing: _buildTrailingAction(
                      yaEvaluado,
                      noHaIniciado,
                      yaCerro,
                      correo,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO PARA LIMPIAR EL CÓDIGO ---

  Widget _buildStatusBanner(String text, Color color) {
    return Container(
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
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (yaEvaluado) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    // Si no ha iniciado o ya cerró, mostramos el candado
    if (noHaIniciado || yaCerro) {
      return Icon(
        noHaIniciado ? Icons.watch_later_outlined : Icons.lock_outline,
        color: noHaIniciado ? Colors.orange : Colors.red,
      );
    }

    // Si todo está ok, mostramos el botón
    return ElevatedButton(
      onPressed: () async {
        await Get.to(
          () => ResponderEvaluacionPage(
            evaluacion: widget.evaluacion,
            evaluadoCorreo: correo,
          ),
        );
        await _cargarEstadoEvaluaciones();
      },
      child: const Text("Evaluar"),
    );
  }
}
