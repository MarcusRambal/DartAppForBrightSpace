abstract class IGrupoSource {
  Future<String> createCategoria(String idCurso, String nombre);

  // Ahora recibe 4 parámetros incluyendo el correo
  Future<void> createGrupo(
    String idCat,
    String nombre,
    String idGrupo,
    String correo,
  );
}
