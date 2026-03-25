import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/repositories/i_grupo_repository.dart';
import '../../../../features/cursos/domain/repositories/i_curso_repository.dart';

class GrupoImportController extends GetxController {
  final IGrupoRepository repository;

  GrupoImportController({required this.repository});

  var isImporting = false.obs;
  var importProgress = "".obs;

  Future<void> importarCSV(String idCurso) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        isImporting.value = true;
        final csvString = utf8.decode(result.files.single.bytes!);
        List<List<dynamic>> rows = const CsvToListConverter().convert(
          csvString,
        );

        Map<String, String> categoriasMemoria = {};
        List<Map<String, dynamic>> loteEstudiantes = [];

        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.length < 8) continue;

          String catNom = row[0].toString().trim();
          String grNom = row[1].toString().trim();
          String grCod = row[2].toString().trim();
          String correo = row[7].toString().trim();

          if (catNom.isEmpty || correo.isEmpty) continue;

          if (!categoriasMemoria.containsKey(catNom)) {
            importProgress.value = "Creando categoría: $catNom...";
            String id = await repository.createCategoria(idCurso, catNom);
            categoriasMemoria[catNom] = id;
          }

          loteEstudiantes.add({
            // 🔥 SIN _id. Usamos idGrupo como la única Primary Key que Roble exige
            "idCat": categoriasMemoria[catNom],
            "idGrupo": "${grCod}_$correo",
            "nombre": grNom,
            "Correo": correo,
          });
        }

        if (loteEstudiantes.isNotEmpty) {
          importProgress.value =
              "Enviando ${loteEstudiantes.length} estudiantes a Roble...";
          await repository.createGruposBatch(loteEstudiantes);
        }

        isImporting.value = false;
        Get.snackbar(
          "Éxito",
          "Grupos importados correctamente.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isImporting.value = false;
      logError("Error al importar CSV: $e");
      Get.snackbar(
        "Error",
        "No se pudo procesar el archivo CSV.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> actualizarCursoConNuevoCSV(String idCurso) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        isImporting.value = true;

        importProgress.value = "Limpiando datos del curso anterior...";
        final cursoRepo = Get.find<ICursoRepository>();
        await cursoRepo.vaciarContenidoCurso(idCurso);

        importProgress.value = "Procesando nuevo archivo...";
        final csvString = utf8.decode(result.files.single.bytes!);
        List<List<dynamic>> rows = const CsvToListConverter().convert(
          csvString,
        );

        Map<String, String> categoriasMemoria = {};
        List<Map<String, dynamic>> loteEstudiantes = [];

        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.length < 8) continue;

          String catNom = row[0].toString().trim();
          String grNom = row[1].toString().trim();
          String grCod = row[2].toString().trim();
          String correo = row[7].toString().trim();

          if (catNom.isEmpty || correo.isEmpty) continue;

          if (!categoriasMemoria.containsKey(catNom)) {
            importProgress.value = "Creando categoría: $catNom...";
            String id = await repository.createCategoria(idCurso, catNom);
            categoriasMemoria[catNom] = id;
          }

          loteEstudiantes.add({
            // 🔥 MISMO TRUCO AL ACTUALIZAR
            "idCat": categoriasMemoria[catNom],
            "idGrupo": "${grCod}_$correo",
            "nombre": grNom,
            "Correo": correo,
          });
        }

        if (loteEstudiantes.isNotEmpty) {
          importProgress.value = "Enviando nueva lista a Roble...";
          await repository.createGruposBatch(loteEstudiantes);
        }

        isImporting.value = false;
        Get.snackbar(
          "Éxito",
          "Lista actualizada correctamente",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isImporting.value = false;
      logError("Error al actualizar CSV: $e");
      Get.snackbar(
        "Error",
        "No se pudo actualizar la lista.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
