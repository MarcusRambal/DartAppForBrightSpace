import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/reportes/ui/viewsmodels/reporte_controller.dart';
import '../../../../features/cursos/ui/viewsmodels/curso_controller.dart';
import '../../../../features/cursos/data/dataSources/i_curso_source.dart';

class AlertaEstudiante {
  final String cursoNombre;
  final String categoriaNombre;
  final String grupoNombre;
  final String correo;
  final double nota;

  AlertaEstudiante({
    required this.cursoNombre,
    required this.categoriaNombre,
    required this.grupoNombre,
    required this.correo,
    required this.nota,
  });
}

class TeacherAlertsPage extends StatefulWidget {
  const TeacherAlertsPage({super.key});

  @override
  State<TeacherAlertsPage> createState() => _TeacherAlertsPageState();
}

class _TeacherAlertsPageState extends State<TeacherAlertsPage> {
  final ReporteController reporteCtrl = Get.find<ReporteController>();
  final CursoController cursoCtrl = Get.find<CursoController>();
  final ICursoSource cursoSource = Get.find<ICursoSource>();

  bool isLoading = true;
  List<AlertaEstudiante> listaAlertas = [];

  static const Color backgroundColor = Color(0xFFF4F5EF);
  static const Color primaryBlue = Color(0xFF1A365D);
  static const Color alertRed = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();

    const isTesting = String.fromEnvironment('IS_TESTING', defaultValue: 'false');

    if (isTesting == 'true') {
      setState(() {
        listaAlertas = [
          AlertaEstudiante(
            cursoNombre: "Móvil",
            categoriaNombre: "CategoríaPyFlutter",
            grupoNombre: "Grupo 3",
            correo: "mpreston@uninorte.edu.co",
            nota: 2.0,
          ),
          AlertaEstudiante(
            cursoNombre: "Móvil",
            categoriaNombre: "CategoríaPyFlutter",
            grupoNombre: "Grupo 3",
            correo: "acoronellm@uninorte.edu.co",
            nota: 3.0,
          ),
        ];
        isLoading = false;
      });
    } else {
      _cargarDetallesAlertas();
    }
  }

  Future<void> _cargarDetallesAlertas() async {
    setState(() => isLoading = true);
    List<AlertaEstudiante> temporales = [];

    try {
      for (var curso in cursoCtrl.cursos) {
        final cursoId = curso.id.toString();
        final bajosRendimientos = await reporteCtrl
            .getEstudiantesBajoRendimiento(cursoId);

        for (var reporte in bajosRendimientos) {
          String idCatReporte = reporte.idCategoria.toString().trim();
          String correoReporte = reporte.idEstudiante
              .toString()
              .toLowerCase()
              .trim();

          String nombreCat = "Categoría Desconocida";
          String nombreGrupo = "Sin Grupo";

          // 1. BUSCAR CATEGORÍA: Usando exclusivamente 'idcat' y 'nombre'
          try {
            final categorias = await cursoSource.getCategoriasByCurso(cursoId);
            for (var c in categorias) {
              if (c['idcat']?.toString().trim() == idCatReporte) {
                nombreCat = c['nombre']?.toString() ?? "Categoría Desconocida";
                break;
              }
            }
          } catch (_) {}

          // 2. BUSCAR GRUPO: Usando exclusivamente 'Correo' y 'nombre'
          try {
            final gruposData = await cursoSource.getDatosDeGruposPorCategoria(
              idCatReporte,
            );
            for (var g in gruposData) {
              if (g['Correo']?.toString().toLowerCase().trim() ==
                  correoReporte) {
                nombreGrupo = g['nombre']?.toString() ?? "Sin Grupo";
                break;
              }
            }
          } catch (_) {}

          temporales.add(
            AlertaEstudiante(
              cursoNombre: curso.nombre,
              categoriaNombre: nombreCat,
              grupoNombre: nombreGrupo,
              correo: reporte.idEstudiante,
              nota: double.tryParse(reporte.nota.toString()) ?? 0.0,
            ),
          );
        }
      }

      temporales.sort((a, b) => a.nota.compareTo(b.nota));

      setState(() {
        listaAlertas = temporales;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('teacherAlertsScaffold'),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        key: const Key('teacherAlertsAppBar'),
        title: const Text(
          "Alertas de Rendimiento",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: alertRed,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              key: Key('teacherAlertsLoadingIndicator'),
              color: alertRed,
            ))
          : listaAlertas.isEmpty
              ? _buildEmptyState()
              : _buildListaAlertas(),
    );
  }

  Widget _buildListaAlertas() {
    return ListView.builder(
      key: const Key('teacherAlertsListView'),
      padding: const EdgeInsets.all(16),
      itemCount: listaAlertas.length,
      itemBuilder: (context, index) {
        final alerta = listaAlertas[index];

        return Card(
          key: Key('teacherAlertsCard_${alerta.correo}_$index'),
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: alertRed.withOpacity(0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: CircleAvatar(
              backgroundColor: alertRed.withOpacity(0.1),
              child: const Icon(Icons.warning_amber_rounded, color: alertRed),
            ),
            title: Text(
              alerta.correo,
              key: Key('teacherAlertsEmail_${alerta.correo}'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  "Curso: ${alerta.cursoNombre}",
                  key: Key('teacherAlertsCourse_${alerta.correo}'),
                ),
                Text(
                  "Categoría: ${alerta.categoriaNombre}",
                  key: Key('teacherAlertsCategory_${alerta.correo}'),
                ), // 🔥 Texto corregido
                Text(
                  "Grupo: ${alerta.grupoNombre}",
                  key: Key('teacherAlertsGroup_${alerta.correo}'),
                ),
              ],
            ),
            trailing: Text(
              alerta.nota.toStringAsFixed(1),
              key: Key('teacherAlertsGrade_${alerta.correo}'),
              style: const TextStyle(
                color: alertRed,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No hay alertas de bajo rendimiento.",
        key: Key('teacherAlertsEmptyText'),
      ),
    );
  }
}
