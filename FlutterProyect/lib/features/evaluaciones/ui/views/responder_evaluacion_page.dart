//FlutterProyect/lib/features/evaluaciones/ui/views/responder_evaluacion_page.dart
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

class _ResponderEvaluacionPageState extends State<ResponderEvaluacionPage> {
  final controller = Get.find<EvaluacionController>();

  int index = 0;
  String? miId;

  List<int> valores = [5, 4, 3, 2];
  List<String> opciones = ["Excelente", "Bueno", "Adecuado", "Podría mejorar"];

  // Temporales en memoria para guardar las respuestas hasta finalizar
  List<RespuestaEntity> respuestasTemp = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = Get.find<ILocalPreferences>();
    miId = await prefs.getString('userId');

    await controller.cargarPreguntas();
    setState(() {});
  }

void seleccionarOpcion(int valor) {
  final pregunta = controller.preguntas[index];
  final idPreguntaStr = pregunta.idPregunta.toString();

  // 🔹 Buscar si ya existe respuesta para esta pregunta
  final indexExistente = respuestasTemp.indexWhere((r) => r.idPregunta == idPreguntaStr);

  if (indexExistente != -1) {
    // 🔹 Si existe, actualizar el valor
    respuestasTemp[indexExistente] = RespuestaEntity(
      idEvaluacion: widget.evaluacion.id.toString(),
      idEvaluador: miId!,
      idEvaluado: widget.evaluadoCorreo,
      idPregunta: idPreguntaStr,
      tipo: pregunta.tipo,
      valorComentario: valor.toString(),
    );
  } else {
    // 🔹 Si no existe, agregar nueva
    respuestasTemp.add(
      RespuestaEntity(
        idEvaluacion: widget.evaluacion.id.toString(),
        idEvaluador: miId!,
        idEvaluado: widget.evaluadoCorreo,
        idPregunta: idPreguntaStr,
        tipo: pregunta.tipo,
        valorComentario: valor.toString(),
      ),
    );
  }

  // 🔹 Actualizamos el índice solo si no es la última pregunta
  if (index < controller.preguntas.length - 1) {
    index++;
  }

  // 🔹 Refrescar UI siempre para activar el botón si es la última
  setState(() {});
}

  Future<void> finalizarEvaluacion() async {
    try {
      // Agregar todas las respuestas al controlador
      for (var r in respuestasTemp) {
        controller.agregarRespuesta(r);
      }

      // 🔹 Volver inmediatamente
      Get.back(result: true);

      // 🔹 Enviar respuestas en segundo plano
      controller.enviarRespuestas().catchError((e) {
        Get.snackbar("Error", "No se pudo enviar la evaluación: $e");
      });
    } catch (e) {
      Get.snackbar("Error", "No se pudo enviar la evaluación: $e");
    }
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
            // Pregunta
            Text(
              pregunta.pregunta,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Opciones de respuesta
            ...List.generate(opciones.length, (i) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () => seleccionarOpcion(valores[i]),
                  child: Text("${opciones[i]} (${valores[i]})"),
                ),
              );
            }),

            const Spacer(),

            // Mostrar progreso
            Text("Pregunta ${index + 1} de ${controller.preguntas.length}"),

            // 🔹 Botón finalizar solo activo si ya respondí la última pregunta
            if (index == controller.preguntas.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: respuestasTemp.any(
                          (r) => r.idPregunta == pregunta.idPregunta.toString())
                      ? finalizarEvaluacion
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Finalizar evaluación"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}