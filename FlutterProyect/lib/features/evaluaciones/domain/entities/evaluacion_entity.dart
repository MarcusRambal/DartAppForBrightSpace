class EvaluacionEntity {
  final String? id;
  final String idCategoria;
  final String tipo;
  final DateTime fechaCreacion;
  final DateTime fechaFinalizacion;

  EvaluacionEntity({
    this.id,
    required this.idCategoria,
    required this.tipo,
    required this.fechaCreacion,
    required this.fechaFinalizacion,
  });
}