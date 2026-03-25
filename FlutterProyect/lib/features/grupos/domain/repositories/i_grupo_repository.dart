abstract class IGrupoRepository {
  Future<String> createCategoria(String idCurso, String nombre);

  Future<void> createGruposBatch(List<Map<String, dynamic>> estudiantes);
}
