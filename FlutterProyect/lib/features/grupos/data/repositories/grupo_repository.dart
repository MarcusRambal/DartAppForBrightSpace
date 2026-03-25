import '../../domain/repositories/i_grupo_repository.dart';
import '../dataSources/i_grupo_source.dart';

class GrupoRepository implements IGrupoRepository {
  final IGrupoSource grupoSource;

  GrupoRepository(this.grupoSource);

  @override
  Future<String> createCategoria(String idCurso, String nombre) async =>
      await grupoSource.createCategoria(idCurso, nombre);

  @override
  Future<void> createGruposBatch(
    List<Map<String, dynamic>> estudiantes,
  ) async => await grupoSource.createGruposBatch(estudiantes);
}
