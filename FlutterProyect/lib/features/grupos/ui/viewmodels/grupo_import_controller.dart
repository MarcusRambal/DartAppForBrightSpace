import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/repositories/i_grupo_repository.dart';

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
        int total = 0;

        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          // Validamos que la fila tenga suficientes columnas (el email está en la 7)
          if (row.length < 8) continue;

          String catNom = row[0].toString().trim(); // Group Category Name
          String grNom = row[1].toString().trim(); // Group Name
          String grCod = row[2].toString().trim(); // Group Code
          String correo = row[7].toString().trim(); // Email Address (Columna 7)

          if (catNom.isEmpty || correo.isEmpty) continue;

          // Crear categoría una sola vez
          if (!categoriasMemoria.containsKey(catNom)) {
            importProgress.value = "Creando categoría: $catNom...";
            String id = await repository.createCategoria(idCurso, catNom);
            categoriasMemoria[catNom] = id;
          }

          String idCatActual = categoriasMemoria[catNom]!;
          importProgress.value = "Insertando estudiante: $correo...";

          await repository.createGrupo(idCatActual, grNom, grCod, correo);
          total++;
        }

        isImporting.value = false;
        Get.snackbar("Éxito", "Importados $total registros.");
      }
    } catch (e) {
      isImporting.value = false;
      logError(e);
      Get.snackbar("Error", "No se pudo completar la importación.");
    }
  }
}
