//FlutterProyect/lib/features/teacher_home/ui/views/teacher_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'teacher_course_details_page.dart';

import '../../../../features/cursos/ui/viewsmodels/curso_controller.dart';
import '../../../../features/cursos/domain/entities/curso_curso.dart';
import '../../../../features/grupos/ui/viewmodels/grupo_import_controller.dart';
import '../../../../features/auth/ui/viewsmodels/authentication_controller.dart';

class TeacherHomePage extends StatelessWidget {
  final String email;

  TeacherHomePage({super.key, required this.email});

  final Color primaryGold = const Color(0xFFE6C363);
  final Color backgroundColor = const Color(0xFFF4F5EF);
  final Color accentButtonColor = const Color(0xFFB8860B);

  // 1️⃣ Inyectamos los controladores
  final CursoController cursoController = Get.find();
  final GrupoImportController grupoController =
      Get.find(); // 🔥 NUEVO CONTROLADOR
  final authController = Get.find<AuthenticationController>();

  // 2️⃣ Menú de opciones del Floating Action Button
  void _showOptionsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        key: const Key('teacherOptionsBottomSheet'),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Text(
              "Opciones",
              key: Key('teacherOptionsTitle'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ListTile(
              key: const Key('teacherCreateCourseOption'),
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
        key: const Key('createCourseDialog'),
        title: const Text("Nuevo Curso"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('createCourseNameField'),
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre del curso (Ej: Prog Móvil)",
                ),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: const Key('createCourseCodeField'),
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
            key: const Key('createCourseCancelButton'),
            onPressed: () => Get.back(),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          Obx(
            () => cursoController.isCreating.value
                ? const CircularProgressIndicator()
                : FilledButton(
                    key: const Key('createCourseSubmitButton'),
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
      key: const Key('teacherHomeScaffold'),
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        key: const Key('teacherHomeFAB'),
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
                key: const Key('teacherHomeHeaderRow'),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ulogo.png',
                    width: 50,
                    height: 50,
                    key: const Key('teacherHomeLogo'),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Hola, Profesor',
                      key: Key('teacherHomeWelcomeText'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // 🔥 BOTÓN DE LOGOUT
                  IconButton(
                    key: const Key('teacherHomeLogoutButton'),
                    icon: const Icon(Icons.logout, color: Colors.black),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Cerrar sesión",
                        middleText: "¿Seguro que quieres cerrar sesión?",
                        textConfirm: "Sí",
                        textCancel: "Cancelar",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.red,
                        onConfirm: () {
                          Get.back();
                          authController.logout();
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTeacherSummaryCard(),
              const SizedBox(height: 20),

              const Text(
                "Mis Cursos Reales",
                key: Key('teacherHomeCursosTitle'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 4️⃣ Lista Reactiva de Cursos conectada a la Base de Datos
              Expanded(
                child: Obx(() {
                  if (cursoController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        key: Key('teacherHomeLoadingIndicator'),
                      ),
                    );
                  }

                  if (cursoController.cursos.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aún no has creado ningún curso.\nPresiona el botón '+' para empezar.",
                        key: Key('teacherHomeEmptyText'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    key: const Key('teacherHomeCursosList'),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cursoController.cursos.length,
                    itemBuilder: (context, index) {
                      final curso = cursoController.cursos[index];
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
      key: const Key('teacherHomeSummaryCard'),
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
              Obx(
                () => _buildSummaryItem(
                  "Mis Cursos",
                  cursoController.cursos.length.toString(),
                  const Key('teacherSummary_cursos'),
                ),
              ), // 🔥 Enlace dinámico
              _buildSummaryItem("Alertas", "0", const Key('teacherSummary_alertas')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Key key) {
    return Column(
      key: key,
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
    // 🔥 ENVOLVEMOS TODO EN ESTO:
    return GestureDetector(
      key: Key('teacherCourseGesture_${curso.id}'),
      onTap: () {
        // Al tocar, navegamos a la página de detalles pasando el curso actual
        Get.to(() => TeacherCourseDetailsPage(curso: curso));
      },
      child: Container(
        key: Key('teacherCourseCard_${curso.id}'),
        // Este es tu Container original
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
              key: Key('teacherCourseBanner_${curso.id}'),
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
                  // 🔴 AQUÍ INYECTAMOS EL BOTÓN DE ELIMINAR (Papelera)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          curso.nombre,
                          key: Key('teacherCourseName_${curso.id}'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        key: Key('teacherCourseDeleteButton_${curso.id}'),
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFF8B0000),
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Eliminar Curso",
                            middleText:
                                "¿Estás seguro? Se perderán todos los grupos.",
                            textConfirm: "Sí, borrar",
                            textCancel: "Cancelar",
                            confirmTextColor: Colors.white,
                            buttonColor: const Color(0xFF8B0000),
                            onConfirm: () {
                              Get.back();
                              cursoController.eliminarCurso(curso.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Text(
                    "Código: ${curso.id}",
                    key: Key('teacherCourseCode_${curso.id}'),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 15),

                  // 6️⃣ Botón para adjuntar el CSV (AHORA FUNCIONAL CON ANIMACIÓN) 🔥
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      if (grupoController.isImporting.value) {
                        return OutlinedButton(
                          key: Key('teacherCourseImportingButton_${curso.id}'),
                          onPressed:
                              null, // Deshabilita el botón mientras carga
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accentButtonColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  grupoController.importProgress.value,
                                  style: TextStyle(
                                    color: accentButtonColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 🟡 AQUÍ REEMPLAZAMOS EL BOTÓN ÚNICO POR LOS DOS BOTONES NUEVOS
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            key: Key('teacherCourseUploadCSVButton_${curso.id}'),
                            onPressed: () {
                              grupoController.importarCSV(curso.id);
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Subir grupos por primera vez"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accentButtonColor,
                              side: BorderSide(color: accentButtonColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            key: Key('teacherCourseUpdateCSVButton_${curso.id}'),
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Actualizar Grupos",
                                middleText:
                                    "Esto borrará la lista actual y cargará la del nuevo archivo. ¿Continuar?",
                                textConfirm: "Sí, actualizar",
                                textCancel: "Cancelar",
                                confirmTextColor: Colors.white,
                                buttonColor: accentButtonColor,
                                onConfirm: () {
                                  Get.back();
                                  grupoController.actualizarCursoConNuevoCSV(
                                    curso.id,
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.sync),
                            label: const Text("Actualizar lista (.csv)"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueGrey,
                              side: const BorderSide(color: Colors.blueGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
