import '../../domain/entities/reporteGrupalPorCategoria_entity.dart';

class ReporteGrupalPorCategoriaModel {
  final String idReporteGrupal;
  final String idCategoria;
  final String idGrupo;
  final String nota;
  final String idCurso;

  ReporteGrupalPorCategoriaModel({
    required this.idReporteGrupal,
    required this.idCategoria,
    required this.idGrupo,
    required this.nota,
    required this.idCurso,
  });

  // 🔽 JSON → Model
  factory ReporteGrupalPorCategoriaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReporteGrupalPorCategoriaModel(
      idReporteGrupal: json['idReporteGrupal'],
      idCategoria: json['idCategoria'],
      idGrupo: json['idGrupo'],
      nota: json['nota'],
      idCurso: json['idCurso'],
    );
  }

  // 🔼 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'idReporteGrupal': idReporteGrupal,
      'idCategoria': idCategoria,
      'idGrupo': idGrupo,
      'nota': nota,
      'idCurso': idCurso,
    };
  }

  // 🔁 Model → Entity
  ReporteGrupalPorCategoriaEntity toEntity() {
    return ReporteGrupalPorCategoriaEntity(
      idReporteGrupal: idReporteGrupal,
      idCategoria: idCategoria,
      idGrupo: idGrupo,
      nota: nota,
      idCurso: idCurso,
    );
  }

  // 🔁 Entity → Model
  factory ReporteGrupalPorCategoriaModel.fromEntity(
    ReporteGrupalPorCategoriaEntity entity,
  ) {
    return ReporteGrupalPorCategoriaModel(
      idReporteGrupal: entity.idReporteGrupal,
      idCategoria: entity.idCategoria,
      idGrupo: entity.idGrupo,
      nota: entity.nota,
      idCurso: entity.idCurso,
    );
  }
}