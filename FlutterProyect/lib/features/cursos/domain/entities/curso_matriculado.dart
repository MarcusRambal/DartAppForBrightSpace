import 'curso_curso.dart';

class CategoriaGrupo {
  final String idCat;
  final String categoriaNombre;
  final String grupoNombre;

  CategoriaGrupo({
    required this.idCat,
    required this.categoriaNombre,
    required this.grupoNombre,
  });

  // 🔽 De JSON a Objeto
  factory CategoriaGrupo.fromJson(Map<String, dynamic> json) {
    return CategoriaGrupo(
      idCat: json['idCat'],
      categoriaNombre: json['categoriaNombre'],
      grupoNombre: json['grupoNombre'],
    );
  }

  // 🔼 De Objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'idCat': idCat,
      'categoriaNombre': categoriaNombre,
      'grupoNombre': grupoNombre,
    };
  }
}

class CursoMatriculado {
  final CursoCurso curso;
  final List<CategoriaGrupo> grupos;
  final int evaluacionesPendientes;

  CursoMatriculado({
    required this.curso,
    required this.grupos,
    this.evaluacionesPendientes = 0,
  });

  // 🔽 De JSON a Objeto
  factory CursoMatriculado.fromJson(Map<String, dynamic> json) {
    return CursoMatriculado(
      curso: CursoCurso.fromJson(json['curso']),
      grupos: List<CategoriaGrupo>.from(
        json['grupos'].map((x) => CategoriaGrupo.fromJson(x)),
      ),
      evaluacionesPendientes: json['evaluacionesPendientes'] ?? 0,
    );
  }

  // 🔼 De Objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'curso': curso.toJson(),
      'grupos': grupos.map((x) => x.toJson()).toList(),
      'evaluacionesPendientes': evaluacionesPendientes,
    };
  }
}
