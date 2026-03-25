abstract class IGrupoSource {
  Future<String> createCategoria(String idCurso, String nombre);

  // 🔥 NUEVO: Recibe una lista completa para guardar de un solo golpe
  Future<void> createGruposBatch(List<Map<String, dynamic>> estudiantes);
}
