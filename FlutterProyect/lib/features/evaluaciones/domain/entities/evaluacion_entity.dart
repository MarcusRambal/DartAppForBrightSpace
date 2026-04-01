class EvaluacionEntity {
  final String id;
  final String idCategoria;
  final String tipo;
  final String nom;
  final DateTime fechaCreacion;
  final DateTime fechaFinalizacion;

  EvaluacionEntity({
    required this.id,
    required this.idCategoria,
    required this.tipo,
    required this.fechaCreacion,
    required this.fechaFinalizacion,
    required this.nom,
  });
}