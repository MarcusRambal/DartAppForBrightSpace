import '../../domain/entities/reportePromedioPersonalPorCategoria_entity.dart';

class ReportePromedioPersonalPorCategoriaModel {
  final String idReportePromedioPersonal;
  final String idEstudiante;
  final String idCategoria;
  final String nota;
  final String idCurso;

  ReportePromedioPersonalPorCategoriaModel({
    required this.idReportePromedioPersonal,
    required this.idEstudiante,
    required this.idCategoria,
    required this.nota,
    required this.idCurso,
  });

  // 🔽 JSON → Model
  factory ReportePromedioPersonalPorCategoriaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportePromedioPersonalPorCategoriaModel(
      idReportePromedioPersonal: json['idReportePromedioPersonal'],
      idEstudiante: json['idEstudiante'],
      idCategoria: json['idCategoria'],
      nota: json['nota'],
      idCurso: json['idCurso'],
    );
  }

  // 🔼 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'idReportePromedioPersonal': idReportePromedioPersonal,
      'idEstudiante': idEstudiante,
      'idCategoria': idCategoria,
      'nota': nota,
      'idCurso': idCurso,
    };
  }

  // 🔁 Model → Entity
  ReportePromedioPersonalPorCategoriaEntity toEntity() {
    return ReportePromedioPersonalPorCategoriaEntity(
      idReportePromedioPersonal: idReportePromedioPersonal,
      idEstudiante: idEstudiante,
      idCategoria: idCategoria,
      nota: nota,
      idCurso: idCurso,
    );
  }

  // 🔁 Entity → Model
  factory ReportePromedioPersonalPorCategoriaModel.fromEntity(
    ReportePromedioPersonalPorCategoriaEntity entity,
  ) {
    return ReportePromedioPersonalPorCategoriaModel(
      idReportePromedioPersonal: entity.idReportePromedioPersonal,
      idEstudiante: entity.idEstudiante,
      idCategoria: entity.idCategoria,
      nota: entity.nota,
      idCurso: entity.idCurso,
    );
  }
}
