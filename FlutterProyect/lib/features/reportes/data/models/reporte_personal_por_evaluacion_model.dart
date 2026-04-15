import '../../domain/entities/reportePersonalPorEvaluacion_entity.dart';

class ReportePersonalPorEvaluacionModel {
  final String idReportePersonal;
  final String idEvaluacion;
  final String idEstudiante;
  final String notaPuntualidad;
  final String notaContribucion;
  final String notaActitud;
  final String notaCompromiso;

  ReportePersonalPorEvaluacionModel({
    required this.idReportePersonal,
    required this.idEvaluacion,
    required this.idEstudiante,
    required this.notaPuntualidad,
    required this.notaContribucion,
    required this.notaActitud,
    required this.notaCompromiso,
  });

  // 🔽 JSON → Model
  factory ReportePersonalPorEvaluacionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportePersonalPorEvaluacionModel(
      idReportePersonal: json['idReportePersonal'],
      idEvaluacion: json['idEvaluacion'],
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
      'idEvaluacion': idEvaluacion,
      'idEstudiante': idEstudiante,
      'notaPuntualidad': notaPuntualidad,
      'notaContribucion': notaContribucion,
      'notaActitud': notaActitud,
      'notaCompromiso': notaCompromiso,
    };
  }

  // 🔁 Model → Entity
  ReportePersonalPorEvaluacionEntity toEntity() {
    return ReportePersonalPorEvaluacionEntity(
      idReportePersonal: idReportePersonal,
      idEvaluacion: idEvaluacion,
      idEstudiante: idEstudiante,
      notaPuntualidad: notaPuntualidad,
      notaContribucion: notaContribucion,
      notaActitud: notaActitud,
      notaCompromiso: notaCompromiso,
    );
  }

  // 🔁 Entity → Model
  factory ReportePersonalPorEvaluacionModel.fromEntity(
    ReportePersonalPorEvaluacionEntity entity,
  ) {
    return ReportePersonalPorEvaluacionModel(
      idReportePersonal: entity.idReportePersonal,
      idEvaluacion: entity.idEvaluacion,
      idEstudiante: entity.idEstudiante,
      notaPuntualidad: entity.notaPuntualidad,
      notaContribucion: entity.notaContribucion,
      notaActitud: entity.notaActitud,
      notaCompromiso: entity.notaCompromiso,
    );
  }
}