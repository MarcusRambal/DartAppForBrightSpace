enum UserRole { student, teacher, admin }

class AuthenticationUser {
  final int? id;
  final String email;
  final String name;
  final String password;
  final UserRole rol;

  AuthenticationUser({
    this.id,
    required this.email,
    required this.name,
    required this.password,
    this.rol = UserRole.student, // Por defecto es estudiante
  });

}

