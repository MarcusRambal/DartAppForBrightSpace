import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/evaluacion_entity.dart';
import '../../domain/entities/respuesta_entity.dart';
import '../../domain/entities/pregunta_entity.dart';
import '../viewmodels/evaluaciones_controller.dart';
import '../../../../core/i_local_preferences.dart';

class ResponderEvaluacionPage extends StatefulWidget {
  final EvaluacionEntity evaluacion;
  final String evaluadoCorreo;

  const ResponderEvaluacionPage({
    super.key,
    required this.evaluacion,
    required this.evaluadoCorreo,
  });

  @override
  State<ResponderEvaluacionPage> createState() =>
      _ResponderEvaluacionPageState();
}

class _ResponderEvaluacionPageState
    extends State<ResponderEvaluacionPage> {
  final controller = Get.find<EvaluacionController>();

  int index = 0;

  List<int> valores = [5, 4, 3, 2];
  List<String> opciones = [
    "Excelente",
    "Bueno",
    "Adecuado",
    "Podría mejorar",
  ];

  String? miId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = Get.find<ILocalPreferences>();
    miId = await prefs.getString('userId');

    await controller.cargarPreguntas(); // 🔥 carga real del backend
    controller.limpiarRespuestas();

    setState(() {});
  }

  void responder(int valor) {
    final PreguntaEntity pregunta = controller.preguntas[index];

    // 🔥 crear respuesta REAL
    final respuesta = RespuestaEntity(
      idEvaluacion: widget.evaluacion.id.toString(),
      idEvaluador: miId!,
      idEvaluado: widget.evaluadoCorreo,
      idPregunta: pregunta.idPregunta.toString(),
      tipo: pregunta.tipo,
      valorComentario: valor.toString(),
    );

    controller.agregarRespuesta(respuesta);

    if (index < controller.preguntas.length - 1) {
      setState(() {
        index++;
      });
    } else {
      _enviar();
    }
  }

  Future<void> _enviar() async {
    await controller.enviarRespuestas();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingPreguntas.value || miId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.preguntas.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No hay preguntas")),
      );
    }

    final pregunta = controller.preguntas[index];

    return Scaffold(
      appBar: AppBar(
        title: Text("Evaluando a ${widget.evaluadoCorreo}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🧠 Pregunta
            Text(
              pregunta.pregunta,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 🔘 Opciones
            ...List.generate(opciones.length, (i) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () => responder(valores[i]),
                  child: Text("${opciones[i]} (${valores[i]})"),
                ),
              );
            }),

            const Spacer(),

            Text(
              "Pregunta ${index + 1} de ${controller.preguntas.length}",
            ),
          ],
        ),
      ),
    );
  }
}