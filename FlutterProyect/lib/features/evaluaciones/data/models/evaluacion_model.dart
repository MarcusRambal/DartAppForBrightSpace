import '../../domain/entities/evaluacion_entity.dart';

class EvaluacionModel extends EvaluacionEntity {
  EvaluacionModel({
    super.id,
    required super.idCategoria,
    required super.tipo,
    required super.fechaCreacion,
    required super.fechaFinalizacion,
  });

  factory EvaluacionModel.fromJson(Map<String, dynamic> json) {
    return EvaluacionModel(
      id: json['id']?.toString(),
      idCategoria: json['idCategoria']?.toString() ?? '',
      tipo: json['tipo'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaFinalizacion: DateTime.parse(json['fechaFinalizacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'idEvaluacion': id,
      'idCategoria': idCategoria,
      'tipo': tipo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaFinalizacion': fechaFinalizacion.toIso8601String(),
    };
  }
}