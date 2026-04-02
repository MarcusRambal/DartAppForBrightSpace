import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/cursos/domain/entities/curso_curso.dart';
import 'teacher_course_details_controller.dart';
import '../../../../features/evaluaciones/ui/viewmodels/evaluaciones_controller.dart';
import 'teacher_group_details_page.dart';

class TeacherCourseDetailsPage extends StatelessWidget {
  final CursoCurso curso;
  const TeacherCourseDetailsPage({super.key, required this.curso});

  final Color backgroundColor = const Color(0xFFF4F5EF);
  final Color goldAccent = const Color(0xFFE6C363);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TeacherCourseDetailsController(repository: Get.find()),
    );

    final evaluacionController = Get.put(
      EvaluacionController(repository: Get.find()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategorias(curso.id!);
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showOptionsBottomSheet(context, evaluacionController, controller),
        backgroundColor: goldAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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

        if (controller.categorias.isEmpty) {
          return const Center(child: Text("No hay categorías disponibles"));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: controller.categorias.map((cat) {
            final idCat = cat['idcat'].toString();
            final nombreCategoria = (cat['nombre'] ?? 'Sin nombre').toString();

            return GestureDetector(
              onTap: () {
                Get.to(
                  () => TeacherGroupDetailsPage(
                    categoriaId: idCat,
                    nombreCategoria: nombreCategoria,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: backgroundColor,
                      child: Icon(Icons.category_rounded, color: goldAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        nombreCategoria,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: goldAccent),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    EvaluacionController evaluacionController,
    TeacherCourseDetailsController controller,
  ) {
    final nombreController = TextEditingController();
    final fechaInicioController = TextEditingController();
    final fechaFinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? selectedCategoriaId;

    // 🔥 VARIABLE REACTIVA PARA EL SWITCH
    RxBool esPrivada = true.obs;

    Future<void> pickDateTime(bool isInicio) async {
      DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (date != null) {
        TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (time != null) {
          final fullDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          final formattedDate = fullDateTime.toIso8601String().split('.')[0];

          if (isInicio) {
            fechaInicioController.text = formattedDate;
          } else {
            fechaFinController.text = formattedDate;
          }
        }
      }
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Nueva Evaluación"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    items: controller.categorias.map((c) {
                      return DropdownMenuItem(
                        value: c['idcat'].toString(),
                        child: Text(c['nombre']),
                      );
                    }).toList(),
                    onChanged: (v) => selectedCategoriaId = v,
                    decoration: const InputDecoration(labelText: "Categoría"),
                    validator: (v) => v == null ? "Seleccione categoría" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: fechaInicioController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Fecha inicio",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => pickDateTime(true),
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: fechaFinController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Fecha fin",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => pickDateTime(false),
                    validator: (v) => v!.isEmpty ? "Requerido" : null,
                  ),

                  // 🔥 SWITCH ARREGLADO (Sintaxis limpia)
                  const SizedBox(height: 15),
                  SwitchListTile(
                    title: const Text(
                      "Privada",
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: const Text(
                      "Oculta para estudiantes hasta publicarla.",
                      style: TextStyle(fontSize: 12),
                    ),
                    value: esPrivada.value,
                    activeColor: goldAccent,
                    onChanged: (val) => esPrivada.value = val,
                  ),
                ],
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar"),
          ),
          Obx(() {
            if (evaluacionController.isCreating.value) {
              return const CircularProgressIndicator();
            }

            return FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  evaluacionController.crearEvaluacion(
                    selectedCategoriaId!,
                    "General",
                    fechaInicioController.text,
                    fechaFinController.text,
                    nombreController.text,
                    esPrivada.value,
                  );
                  Get.back();
                }
              },
              child: const Text("Crear"),
            );
          }),
        ],
      ),
    );
  }
}
