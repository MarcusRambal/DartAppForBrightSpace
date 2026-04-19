import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../features/reportes/ui/viewsmodels/reporte_controller.dart';
import '../../../../features/reportes/domain/entities/reportePersonalPorEvaluacion_entity.dart';
import 'teacher_course_details_controller.dart';

class TeacherReportPage extends StatefulWidget {
  final String idEvaluacion;
  final String nombreEvaluacion;
  final String idCategoria; // 🔥 Recibimos la categoría para saber los grupos

  const TeacherReportPage({
    super.key,
    required this.idEvaluacion,
    required this.nombreEvaluacion,
    required this.idCategoria,
  });

  @override
  State<TeacherReportPage> createState() => _TeacherReportPageState();
}

class _TeacherReportPageState extends State<TeacherReportPage> {
  final ReporteController reporteController = Get.find<ReporteController>();
  final TeacherCourseDetailsController courseController =
      Get.find<TeacherCourseDetailsController>();

  bool isLoading = true;
  List<ReportePersonalPorEvaluacionEntity> reportes = [];

  // Paleta de Colores
  static const Color backgroundColor = Color(0xFFF4F5EF);
  static const Color primaryBlue = Color(0xFF1A365D);
  static const Color goldAccent = Color(0xFFE6C363);

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  // --- 📥 DESCARGA DE DATOS EN TIEMPO REAL ---
  Future<void> _cargarReportes() async {
    setState(() => isLoading = true);
    try {
      final client = Get.find<http.Client>(tag: 'apiClient');
      final contract = dotenv.env['EXPO_PUBLIC_ROBLE_PROJECT_ID'] ?? '';

      final url = Uri.https(
        'roble-api.openlab.uninorte.edu.co',
        '/database/$contract/read',
        {"tableName": "respuesta", "idEvaluacion": widget.idEvaluacion},
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);
        final Map<String, Map<String, List<double>>> agrupado = {};

        for (var r in records) {
          final correo = r['idEvaluado']?.toString().trim().toLowerCase() ?? '';
          final tipo = r['tipo']?.toString().trim().toLowerCase() ?? '';
          final nota =
              double.tryParse(r['valor_comentario']?.toString() ?? '0') ?? 0.0;

          if (correo.isEmpty) continue;

          if (!agrupado.containsKey(correo)) {
            agrupado[correo] = {
              'puntualidad': [],
              'contribucion': [],
              'actitud': [],
              'compromiso': [],
            };
          }

          if (tipo.contains('puntuali'))
            agrupado[correo]!['puntualidad']!.add(nota);
          else if (tipo.contains('contribu'))
            agrupado[correo]!['contribucion']!.add(nota);
          else if (tipo.contains('actitud'))
            agrupado[correo]!['actitud']!.add(nota);
          else if (tipo.contains('compromis'))
            agrupado[correo]!['compromiso']!.add(nota);
        }

        List<ReportePersonalPorEvaluacionEntity> reportesCalculados = [];
        agrupado.forEach((correo, notas) {
          double promedio(List<double> lista) => lista.isEmpty
              ? 0.0
              : lista.reduce((a, b) => a + b) / lista.length;
          reportesCalculados.add(
            ReportePersonalPorEvaluacionEntity(
              idReportePersonal: "temp_$correo",
              idEvaluacion: widget.idEvaluacion,
              idEstudiante: correo,
              notaPuntualidad: promedio(
                notas['puntualidad']!,
              ).toStringAsFixed(1),
              notaContribucion: promedio(
                notas['contribucion']!,
              ).toStringAsFixed(1),
              notaActitud: promedio(notas['actitud']!).toStringAsFixed(1),
              notaCompromiso: promedio(notas['compromiso']!).toStringAsFixed(1),
            ),
          );
        });

        setState(() {
          reportes = reportesCalculados;
          isLoading = false;
        });
      } else {
        throw Exception("Error descargando respuestas");
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // --- 🧮 MATEMÁTICA ---
  double _calcularPromedio(ReportePersonalPorEvaluacionEntity r) {
    final p = double.tryParse(r.notaPuntualidad) ?? 0;
    final c = double.tryParse(r.notaContribucion) ?? 0;
    final a = double.tryParse(r.notaActitud) ?? 0;
    final co = double.tryParse(r.notaCompromiso) ?? 0;
    return (p + c + a + co) / 4;
  }

  // --- 🎨 INTERFAZ GRÁFICA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.nombreEvaluacion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarReportes,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : _buildVistaJerarquica(),
    );
  }

  Widget _buildVistaJerarquica() {
    // 1. Traemos los grupos desde el controlador de la clase
    final gruposMap = courseController.datosGrupos[widget.idCategoria] ?? {};

    // 2. Calculamos el promedio de toda el aula
    double promedioGeneral = 0.0;
    if (reportes.isNotEmpty) {
      promedioGeneral =
          reportes.map((r) => _calcularPromedio(r)).reduce((a, b) => a + b) /
          reportes.length;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🏆 TARJETA: PROMEDIO GENERAL
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                "PROMEDIO DE LA EVALUACIÓN",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                reportes.isEmpty ? "0.0" : promedioGeneral.toStringAsFixed(1),
                style: const TextStyle(
                  color: goldAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${reportes.length} estudiantes evaluados",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),
        const Text(
          "Desempeño por Grupos",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 15),

        // 👥 LISTA DE GRUPOS DESPLEGABLES
        ...gruposMap.entries.map((entry) {
          final nombreGrupo = entry.key;
          final integrantes = entry.value;

          // Filtramos solo los reportes de los estudiantes que pertenecen a este grupo
          final reportesGrupo = reportes
              .where(
                (r) => integrantes.any(
                  (i) => i.toLowerCase() == r.idEstudiante.toLowerCase(),
                ),
              )
              .toList();

          // Calculamos el promedio específico de este grupo
          double promedioGrupo = 0.0;
          if (reportesGrupo.isNotEmpty) {
            promedioGrupo =
                reportesGrupo
                    .map((r) => _calcularPromedio(r))
                    .reduce((a, b) => a + b) /
                reportesGrupo.length;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: goldAccent.withOpacity(0.2),
                  child: const Icon(Icons.group, color: primaryBlue),
                ),
                title: Text(
                  "Grupo: $nombreGrupo",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                subtitle: Text(
                  reportesGrupo.isEmpty
                      ? "Aún no hay calificaciones"
                      : "Promedio: ${promedioGrupo.toStringAsFixed(1)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: reportesGrupo.isEmpty
                        ? Colors.grey
                        : (promedioGrupo >= 3.0 ? Colors.green : Colors.red),
                  ),
                ),

                // 👤 ESTUDIANTES DEL GRUPO (Al desplegar)
                children: integrantes.map((correo) {
                  // Buscamos si el estudiante ya tiene un reporte calculado
                  ReportePersonalPorEvaluacionEntity? reporteEstudiante;
                  try {
                    reporteEstudiante = reportes.firstWhere(
                      (r) =>
                          r.idEstudiante.toLowerCase() == correo.toLowerCase(),
                    );
                  } catch (_) {
                    reporteEstudiante =
                        null; // Si no lo encuentra, da error, lo capturamos y queda nulo
                  }

                  // Si aún no lo evalúan, lo mostramos pendiente
                  if (reporteEstudiante == null) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 0,
                      ),
                      leading: const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      title: Text(
                        correo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: const Text(
                        "Pendiente",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  // Si sí fue evaluado, calculamos su promedio y mostramos sus detalles
                  final promEstudiante = _calcularPromedio(reporteEstudiante);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 0,
                    ),
                    leading: const Icon(
                      Icons.person,
                      color: primaryBlue,
                      size: 20,
                    ),
                    title: Text(
                      correo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "P: ${reporteEstudiante.notaPuntualidad} | C: ${reporteEstudiante.notaContribucion} | A: ${reporteEstudiante.notaActitud} | Co: ${reporteEstudiante.notaCompromiso}",
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: promEstudiante >= 3.0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        promEstudiante.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: promEstudiante >= 3.0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 30),
      ],
    );
  }
}
