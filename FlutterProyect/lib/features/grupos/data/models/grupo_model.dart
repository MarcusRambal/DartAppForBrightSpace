import '../../domain/entities/grupo_entity.dart';

class GrupoModel extends GrupoEntity {
  GrupoModel({
    super.id,
    required super.idCat,
    required super.nom,
    required super.codigo,
  });

  factory GrupoModel.fromJson(Map<String, dynamic> json) {
    return GrupoModel(
      id: json['id']?.toString(),
      idCat: json['idcat']?.toString() ?? '',
      nom: json['nom'],
      codigo: json['codigo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'idcat': idCat,
      'nom': nom,
      'codigo': codigo,
    };
  }
}
