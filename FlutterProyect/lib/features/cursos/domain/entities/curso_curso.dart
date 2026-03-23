class CursoCurso {
  final String id;
  final String nombre;
  //final String name;
  final String idProfesor; 

  CursoCurso({
    required this.id,
    required this.nombre,
    //required this.name,
    required this.idProfesor,
  });

  factory CursoCurso.fromJson(Map<String, dynamic> json) {
    return CursoCurso(
      id: json['idcurso'], 
      nombre: json['nom'],
      //name: json['name'],
      idProfesor: json['idprofe'] , 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idcurso': id,
      'nom': nombre,
      //'name': name,
      'idprofesor': idProfesor, // ✅ incluimos rol en el JSON
    };
  }
}