import '../../domain/entities/categoria_entity.dart';

class CategoriaModel extends CategoriaEntity {
  CategoriaModel({super.id, required super.nom, required super.idCurso});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id']
          ?.toString(), // .toString() por si Roble lo devuelve como int
      nom: json['nom'],
      idCurso: json['idCurso']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'nom': nom, 'idCurso': idCurso};
  }
}
