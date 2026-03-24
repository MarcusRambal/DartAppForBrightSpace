abstract class IGrupoRepository {
  Future<String> createCategoria(String idCurso, String nombre);

  // Sincronizado con el Source
  Future<void> createGrupo(
    String idCat,
    String nombre,
    String idGrupo,
    String correo,
  );
}
