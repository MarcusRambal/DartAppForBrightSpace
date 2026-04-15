import '../../domain/entities/reportePersonalPorCategoria_entity.dart';

class ReportePersonalPorCategoriaModel {
  final String idReportePersonal;
  final String idCategoria;
  final String idEstudiante;
  final String notaPuntualidad;
  final String notaContribucion;
  final String notaActitud;
  final String notaCompromiso;

  ReportePersonalPorCategoriaModel({
    required this.idReportePersonal,
    required this.idCategoria,
    required this.idEstudiante,
    required this.notaPuntualidad,
    required this.notaContribucion,
    required this.notaActitud,
    required this.notaCompromiso,
  });

  // 🔽 JSON → Model
  factory ReportePersonalPorCategoriaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportePersonalPorCategoriaModel(
      idReportePersonal: json['idReportePersonal'],
      idCategoria: json['idCategoria'],
      idEstudiante: json['idEstudiante'],
      notaPuntualidad: json['notaPuntualidad'],
      notaContribucion: json['notaContribucion'],
      notaActitud: json['notaActitud'],
      notaCompromiso: json['notaCompromiso'],
    );
  }

  // 🔼 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'idReportePersonal': idReportePersonal,
      'idCategoria': idCategoria,
      'idEstudiante': idEstudiante,
      'notaPuntualidad': notaPuntualidad,
      'notaContribucion': notaContribucion,
      'notaActitud': notaActitud,
      'notaCompromiso': notaCompromiso,
    };
  }

  // 🔁 Model → Entity
  ReportePersonalPorCategoriaEntity toEntity() {
    return ReportePersonalPorCategoriaEntity(
      idReportePersonal: idReportePersonal,
      idCategoria: idCategoria,
      idEstudiante: idEstudiante,
      notaPuntualidad: notaPuntualidad,
      notaContribucion: notaContribucion,
      notaActitud: notaActitud,
      notaCompromiso: notaCompromiso,
    );
  }

  // 🔁 Entity → Model
  factory ReportePersonalPorCategoriaModel.fromEntity(
    ReportePersonalPorCategoriaEntity entity,
  ) {
    return ReportePersonalPorCategoriaModel(
      idReportePersonal: entity.idReportePersonal,
      idCategoria: entity.idCategoria,
      idEstudiante: entity.idEstudiante,
      notaPuntualidad: entity.notaPuntualidad,
      notaContribucion: entity.notaContribucion,
      notaActitud: entity.notaActitud,
      notaCompromiso: entity.notaCompromiso,
    );
  }
}