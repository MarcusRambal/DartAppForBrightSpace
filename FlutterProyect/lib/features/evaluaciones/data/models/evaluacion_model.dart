import '../../domain/entities/evaluacion_entity.dart';

class EvaluacionModel extends EvaluacionEntity {
  EvaluacionModel({
    required super.id,
    required super.idCategoria,
    required super.tipo,
    required super.fechaCreacion,
    required super.fechaFinalizacion,
    required super.nom,
    required super.esPrivada,
  });

  factory EvaluacionModel.fromJson(Map<String, dynamic> json) {
    // Roble guarda "Privada" o "General" en el campo 'tipo'
    final String tipoDb = json['tipo']?.toString() ?? 'General';

    return EvaluacionModel(
      // Roble usa idEvaluacion o id, aseguramos capturarlo
      id: (json['idEvaluacion'] ?? json['id'] ?? json['_id']).toString(),
      idCategoria: json['idCategoria']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      tipo: tipoDb,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaFinalizacion: DateTime.parse(json['fechaFinalizacion']),
      // 🔥 Mapeo: Si es "Privada" en DB, esPrivada es true en la App
      esPrivada: tipoDb == "Privada",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'idEvaluacion':
          id, // Usamos el nombre de campo que Roble requiere para cambios
      'idCategoria': idCategoria,
      'nom': nom,
      // 🔥 Traducimos de vuelta: true -> "Privada", false -> "General"
      'tipo': esPrivada ? "Privada" : "General",
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaFinalizacion': fechaFinalizacion.toIso8601String(),
    };
  }
}
