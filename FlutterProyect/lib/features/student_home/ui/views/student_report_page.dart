import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/evaluaciones/data/dataSources/i_evaluacion_source.dart';
import '../../../../features/reportes/ui/viewsmodels/reporte_controller.dart';
import '../../../../features/auth/ui/viewsmodels/authentication_controller.dart';
import '../../../../features/reportes/domain/entities/reportePersonalPorEvaluacion_entity.dart';

class StudentReportPage extends StatefulWidget {
  final String idEvaluacion;
  final String nombreEvaluacion;

  const StudentReportPage({
    super.key,
    required this.idEvaluacion,
    required this.nombreEvaluacion,
  });

  @override
  State<StudentReportPage> createState() => _StudentReportPageState();
}

class _StudentReportPageState extends State<StudentReportPage> {
  final ReporteController reporteController = Get.find<ReporteController>();
  final AuthenticationController authController =
      Get.find<AuthenticationController>();

  bool isLoading = true;
  ReportePersonalPorEvaluacionEntity? miReporte;

  // 🔥 PALETA DE COLORES
  final Color backgroundColor = const Color(0xFFF4F5EF); // Crema
  final Color primaryBlue = const Color(0xFF1A365D); // Azul Marino
  final Color goldAccent = const Color(0xFFE6C363); // Dorado

  @override
  void initState() {
    super.initState();
    _cargarMisNotas();
  }

  Future<void> _cargarMisNotas() async {
    final miCorreo = authController.loggedUser.value?.email ?? '';

    try {
      final evaluacionSource = Get.find<IEvaluacionSource>();

      // 📥 1. Descargamos tus notas directamente de las respuestas originales
      final puntualidad = await evaluacionSource.getNotasPorEvaluado(
        widget.idEvaluacion,
        miCorreo,
        "Puntualidad",
      );
      final contribucion = await evaluacionSource.getNotasPorEvaluado(
        widget.idEvaluacion,
        miCorreo,
        "Contribucion",
      );
      final actitud = await evaluacionSource.getNotasPorEvaluado(
        widget.idEvaluacion,
        miCorreo,
        "Actitud",
      );
      final compromiso = await evaluacionSource.getNotasPorEvaluado(
        widget.idEvaluacion,
        miCorreo,
        "Compromiso",
      );

      // 🔍 2. Si las 4 listas están vacías, NADIE te ha evaluado aún.
      if (puntualidad.isEmpty &&
          contribucion.isEmpty &&
          actitud.isEmpty &&
          compromiso.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // 🧠 3. Helper para promediar tu lista de números
      String calcular(List<String> notas) {
        if (notas.isEmpty) return "0.0";
        final suma = notas
            .map((e) => double.tryParse(e) ?? 0)
            .reduce((a, b) => a + b);
        return (suma / notas.length).toStringAsFixed(1);
      }

      // ⚡ 4. Construimos tu reporte en la memoria sin tocar la DB
      final reporteEnMemoria = ReportePersonalPorEvaluacionEntity(
        idReportePersonal: "temporal",
        idEvaluacion: widget.idEvaluacion,
        idEstudiante: miCorreo,
        notaPuntualidad: calcular(puntualidad),
        notaContribucion: calcular(contribucion),
        notaActitud: calcular(actitud),
        notaCompromiso: calcular(compromiso),
      );

      setState(() {
        miReporte = reporteEnMemoria;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Helper para convertir el texto a número y calcular el promedio seguro
  double _calcularPromedio(ReportePersonalPorEvaluacionEntity r) {
    final p = double.tryParse(r.notaPuntualidad) ?? 0;
    final c = double.tryParse(r.notaContribucion) ?? 0;
    final a = double.tryParse(r.notaActitud) ?? 0;
    final co = double.tryParse(r.notaCompromiso) ?? 0;
    return (p + c + a + co) / 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Mis Resultados",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: primaryBlue,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : miReporte == null
          ? _buildEmptyState()
          : _buildReporteVisual(miReporte!),
    );
  }

  Widget _buildReporteVisual(ReportePersonalPorEvaluacionEntity reporte) {
    final promedio = _calcularPromedio(reporte);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 🏆 TARJETA DE PROMEDIO FINAL
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.nombreEvaluacion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Promedio Final",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: goldAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  promedio.toStringAsFixed(1), // Muestra 1 decimal
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // 📊 DESGLOSE DE NOTAS
        Text(
          "Desglose de Criterios",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 15),

        _buildNotaTile("Puntualidad", reporte.notaPuntualidad, Icons.timer),
        _buildNotaTile(
          "Contribución",
          reporte.notaContribucion,
          Icons.handshake,
        ),
        _buildNotaTile("Actitud", reporte.notaActitud, Icons.mood),
        _buildNotaTile("Compromiso", reporte.notaCompromiso, Icons.star),
      ],
    );
  }

  Widget _buildNotaTile(String titulo, String notaTexto, IconData icono) {
    final nota = double.tryParse(notaTexto) ?? 0.0;

    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: goldAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: goldAccent),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          nota.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 60,
              color: primaryBlue.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              "Aún no hay resultados",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tus resultados aparecerán aquí cuando tus compañeros te hayan evaluado y el reporte se haya generado.",
              textAlign: TextAlign.center,
              style: TextStyle(color: primaryBlue.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
