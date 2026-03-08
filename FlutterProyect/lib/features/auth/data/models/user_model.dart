import '../../domain/entities/authentication_user.dart';

class UserModel extends AuthenticationUser {
  UserModel({
    super.id,
    required super.email,
    required super.name,
    required super.password,
    super.rol,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      rol: UserRole.values.firstWhere(
            (e) => e.name == (json['rol'] ?? 'student'),
        orElse: () => UserRole.student,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'rol': rol.name,
    };
  }
}