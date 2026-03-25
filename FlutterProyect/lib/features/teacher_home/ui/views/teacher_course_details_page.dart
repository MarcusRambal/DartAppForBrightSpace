import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/cursos/domain/entities/curso_curso.dart';
import 'teacher_course_details_controller.dart';

class TeacherCourseDetailsPage extends StatelessWidget {
  final CursoCurso curso;
  const TeacherCourseDetailsPage({super.key, required this.curso});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TeacherCourseDetailsController(repository: Get.find()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategorias(curso.id!);
    });

    return Scaffold(
      appBar: AppBar(title: Text(curso.nombre ?? "Detalle")),
      body: Obx(() {
        if (controller.isLoadingCategorias.value)
          return const Center(child: CircularProgressIndicator());

        return ListView(
          padding: const EdgeInsets.all(16),
          children: controller.categorias.map((cat) {
            final idCat = cat['idcat'].toString();
            return Card(
              child: ExpansionTile(
                title: Text(cat['nombre']),
                onExpansionChanged: (open) =>
                    open ? controller.fetchDetalleCategoria(idCat) : null,
                children: [
                  Obx(() {
                    if (controller.loadingDetalleCategoria[idCat] == true)
                      return const LinearProgressIndicator();
                    final grupos = controller.datosGrupos[idCat] ?? {};
                    return Column(
                      children: grupos.entries
                          .map(
                            (g) => ExpansionTile(
                              title: Text("Grupo: ${g.key}"),
                              subtitle: Text("${g.value.length} integrantes"),
                              children: g.value
                                  .map(
                                    (c) =>
                                        ListTile(title: Text(c), dense: true),
                                  )
                                  .toList(),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
