//FlutterProyect/lib/features/auth/domain/entities/authentication_user.dart
class AuthenticationUser {
  final String id;
  final String email;
  //final String name;
  final String rol; // ✅ nuevo campo

  AuthenticationUser({
    required this.id,
    required this.email,
    //required this.name,
    this.rol = "estudiante", // ✅ predeterminado
  });

  factory AuthenticationUser.fromJson(Map<String, dynamic> json) {
    return AuthenticationUser(
      id: json['userId'], // Cambié a userId porque tu JSON lo tiene así
      email: json['email'],
      //name: json['name'],
      rol: json['rol'] ?? "estudiante", // Si no viene, asumimos estudiante
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'email': email,
      //'name': name,
      'rol': rol, // ✅ incluimos rol en el JSON
    };
  }
}