import '../../domain/entities/reportePromedioPersonalPorCategoria_entity.dart';

class ReportePromedioPersonalPorCategoriaModel {
  final String idReportePromedioPersonal;
  final String idReportePersonal;
  final String nota;
  final String idCurso;

  ReportePromedioPersonalPorCategoriaModel({
    required this.idReportePromedioPersonal,
    required this.idReportePersonal,
    required this.nota,
    required this.idCurso,
  });

  // 🔽 JSON → Model
  factory ReportePromedioPersonalPorCategoriaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportePromedioPersonalPorCategoriaModel(
      idReportePromedioPersonal: json['idReportePromedioPersonal'],
      idReportePersonal: json['idReportePersonal'],
      nota: json['nota'],
      idCurso: json['idCurso'],
    );
  }

  // 🔼 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'idReportePromedioPersonal': idReportePromedioPersonal,
      'idReportePersonal': idReportePersonal,
      'nota': nota,
      'idCurso': idCurso,
    };
  }

  // 🔁 Model → Entity
  ReportePromedioPersonalPorCategoriaEntity toEntity() {
    return ReportePromedioPersonalPorCategoriaEntity(
      idReportePromedioPersonal: idReportePromedioPersonal,
      idReportePersonal: idReportePersonal,
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
      idReportePersonal: entity.idReportePersonal,
      nota: entity.nota,
      idCurso: entity.idCurso,
    );
  }
}