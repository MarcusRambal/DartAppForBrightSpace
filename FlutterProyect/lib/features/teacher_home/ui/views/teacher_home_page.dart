import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/cursos/ui/viewsmodels/curso_controller.dart';
import '../../../../features/cursos/domain/entities/curso_curso.dart';

class TeacherHomePage extends StatelessWidget {
  final String email;

  TeacherHomePage({super.key, required this.email});

  final Color primaryGold = const Color(0xFFE6C363);
  final Color backgroundColor = const Color(0xFFF4F5EF);
  final Color accentButtonColor = const Color(0xFFB8860B);

  // 1️⃣ Inyectamos el controlador de cursos
  final CursoController cursoController = Get.find();

  // 2️⃣ Menú de opciones del Floating Action Button
  void _showOptionsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Text(
              "Opciones",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.class_, color: accentButtonColor),
              title: const Text("Crear curso"),
              onTap: () {
                Get.back(); // Cierra el menú de opciones
                _showCreateCourseDialog(context); // Abre el formulario
              },
            ),
          ],
        ),
      ),
    );
  }

  // 3️⃣ Formulario de creación de curso
  void _showCreateCourseDialog(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController codigoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text("Nuevo Curso"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre del curso (Ej: Prog Móvil)",
                ),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: codigoController,
                decoration: const InputDecoration(
                  labelText: "Código (Ej: 202610_1852)",
                ),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          Obx(
            () => cursoController.isCreating.value
                ? const CircularProgressIndicator()
                : FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accentButtonColor,
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        cursoController.crearCurso(
                          codigoController.text.trim(),
                          nombreController.text.trim(),
                        );
                        Get.back(); // Cierra el diálogo al guardar
                      }
                    },
                    child: const Text("Crear"),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptionsBottomSheet(context),
        backgroundColor: accentButtonColor,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/ulogo.png', width: 50, height: 50),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Hola, Profesor',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTeacherSummaryCard(),
              const SizedBox(height: 20),

              const Text(
                "Mis Cursos Reales",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 4️⃣ Lista Reactiva de Cursos conectada a la Base de Datos
              Expanded(
                child: Obx(() {
                  if (cursoController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (cursoController.cursos.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aún no has creado ningún curso.\nPresiona el botón '+' para empezar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: cursoController.cursos.length,
                    itemBuilder: (context, index) {
                      final curso = cursoController.cursos[index];
                      // Usamos un patrón de colores para las tarjetas
                      final List<Color> colores = [
                        Colors.blueAccent,
                        Colors.teal,
                        Colors.indigo,
                      ];
                      return _buildCourseCard(
                        curso,
                        colores[index % colores.length],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGold,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            "RESUMEN ACADÉMICO",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                "Mis Cursos",
                "0",
              ), // Podrías enlazar esto al .length de la lista luego
              _buildSummaryItem("Alertas", "0"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 5️⃣ La tarjeta de curso ahora recibe el objeto completo y muestra el botón del CSV
  Widget _buildCourseCard(CursoCurso curso, Color colorBanner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorBanner,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curso.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Código: ${curso.id}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 15),

                // 6️⃣ El Botón para adjuntar el CSV (Aún sin función activa)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar lógica de carga de CSV aquí
                      Get.snackbar(
                        "Próximamente",
                        "Aquí abriremos el selector de archivos CSV para el curso ${curso.nombre}",
                      );
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Adjuntar archivo de grupos (.csv)"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentButtonColor,
                      side: BorderSide(color: accentButtonColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
