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

    const Color backgroundColor = Color(0xFFF4F5EF);
    const Color primaryRed = Color(0xFF8B1E1E);
    const Color goldAccent = Color(0xFFE6C363);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Categorías",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingCategorias.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Categorías",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            ...controller.categorias.map((cat) {
              final idCat = cat['idcat'].toString();
              final nombreCategoria = (cat['nombre'] ?? 'Sin nombre')
                  .toString();

              return _buildCategoriaCard(
                idCat: idCat,
                nombreCategoria: nombreCategoria,
                controller: controller,
                primaryRed: primaryRed,
                goldAccent: goldAccent,
              );
            }).toList(),
          ],
        );
      }),
    );
  }

  Widget _buildCategoriaCard({
    required String idCat,
    required String nombreCategoria,
    required TeacherCourseDetailsController controller,
    required Color primaryRed,
    required Color goldAccent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: CircleAvatar(
            backgroundColor: primaryRed.withOpacity(0.12),
            child: Icon(Icons.category_rounded, color: primaryRed),
          ),
          title: Text(
            nombreCategoria,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Haz clic para ver grupos e integrantes",
            style: TextStyle(
              color: primaryRed.withOpacity(0.85),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.expand_more_rounded,
            color: goldAccent.withOpacity(0.9),
          ),
          onExpansionChanged: (open) {
            if (open) {
              controller.fetchDetalleCategoria(idCat);
            }
          },
          children: [
            Obx(() {
              if (controller.loadingDetalleCategoria[idCat] == true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      color: primaryRed,
                      backgroundColor: primaryRed.withOpacity(0.12),
                    ),
                  ),
                );
              }

              final grupos = controller.datosGrupos[idCat] ?? {};

              if (grupos.isEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    "No hay grupos o integrantes registrados en esta categoría.",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                );
              }

              return Column(
                children: grupos.entries.map((g) {
                  return _buildGrupoCard(
                    nombreGrupo: g.key,
                    integrantes: List<String>.from(g.value),
                    primaryRed: primaryRed,
                    goldAccent: goldAccent,
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupoCard({
    required String nombreGrupo,
    required List<String> integrantes,
    required Color primaryRed,
    required Color goldAccent,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups_rounded, color: primaryRed, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Grupo: $nombreGrupo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryRed,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: goldAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "${integrantes.length} integrantes",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(integrantes.length, (index) {
            final integrante = integrantes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: primaryRed.withOpacity(0.10),
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      integrante,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
