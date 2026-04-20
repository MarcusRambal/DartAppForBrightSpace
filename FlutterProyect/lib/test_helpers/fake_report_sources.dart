import '../features/reportes/data/dataSources/i_reporte_source.dart';
import '../features/reportes/data/models/reporte_promedio_personal_por_categoria_model.dart';

class FakeReporteSource implements IReporteSource {
  @override
  Future<List<ReportePromedioPersonalPorCategoriaModel>> getReportesPromedioPersonalCategoriaTodos(String idCurso) async {
    return [
      ReportePromedioPersonalPorCategoriaModel(
        idReportePromedioPersonal: "rep2",
        idCategoria: "1774449735424",
        idEstudiante: "mpreston@uninorte.edu.co",
        nota: "2.0",
        idCurso: 'Grupo 3',
      ),
      ReportePromedioPersonalPorCategoriaModel(
        idReportePromedioPersonal: "rep3",
        idCategoria: "1774449735424",
        idEstudiante: "acoronellm@uninorte.edu.co",
        nota: "3.0",
        idCurso: 'Grupo 3',
      ),
    ];
  }

  // Si necesitas más métodos, simplemente añádelos aquí.
  // Para los que no uses, puedes dejar que lancen error o retornar vacío:
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}