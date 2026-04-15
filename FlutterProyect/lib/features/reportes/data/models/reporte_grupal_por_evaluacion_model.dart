import '../../domain/entities/reporteGrupalPorEvaluacion_entity.dart';

class ReporteGrupalPorEvaluacionModel {
  final String idReporteGrupal;
  final String idEvaluacion;
  final String idGrupo;
  final String nota;

  ReporteGrupalPorEvaluacionModel({
    required this.idReporteGrupal,
    required this.idEvaluacion,
    required this.idGrupo,
    required this.nota,
  });

  // 🔽 JSON → Model
  factory ReporteGrupalPorEvaluacionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReporteGrupalPorEvaluacionModel(
      idReporteGrupal: json['idReporteGrupal'],
      idEvaluacion: json['idEvaluacion'],
      idGrupo: json['idGrupo'],
      nota: json['nota'],
    );
  }

  // 🔼 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'idReporteGrupal': idReporteGrupal,
      'idEvaluacion': idEvaluacion,
      'idGrupo': idGrupo,
      'nota': nota,
    };
  }

  // 🔁 Model → Entity
  ReporteGrupalPorEvaluacionEntity toEntity() {
    return ReporteGrupalPorEvaluacionEntity(
      idReporteGrupal: idReporteGrupal,
      idEvaluacion: idEvaluacion,
      idGrupo: idGrupo,
      nota: nota,
    );
  }

  // 🔁 Entity → Model
  factory ReporteGrupalPorEvaluacionModel.fromEntity(
    ReporteGrupalPorEvaluacionEntity entity,
  ) {
    return ReporteGrupalPorEvaluacionModel(
      idReporteGrupal: entity.idReporteGrupal,
      idEvaluacion: entity.idEvaluacion,
      idGrupo: entity.idGrupo,
      nota: entity.nota,
    );
  }
}