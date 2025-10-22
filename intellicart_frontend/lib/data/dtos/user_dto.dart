// lib/data/dtos/user_dto.dart

class UserDto {
  final String id;
  final String email;
  final String name;
  final String role;
  
  UserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
  
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'buyer',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}