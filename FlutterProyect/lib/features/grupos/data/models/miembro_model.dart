import '../../domain/entities/miembro_entity.dart';

class MiembroModel extends MiembroEntity {
  MiembroModel({required super.idGrupo, required super.correo});

  factory MiembroModel.fromJson(Map<String, dynamic> json) {
    return MiembroModel(
      idGrupo: json['idgrupo']?.toString() ?? '',
      correo: json['correo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'idgrupo': idGrupo, 'correo': correo};
  }
}
