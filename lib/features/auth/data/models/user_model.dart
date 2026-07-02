import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.phone,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>?;
    final token = results?['access_token'] as String? ?? '';
    final user = results?['user'] as Map<String, dynamic>?;

    return UserModel(
      id: user?['id'] as String? ?? '',
      displayName: user?['display_name'] as String? ?? '',
      email: user?['email'] as String? ?? '',
      phone: user?['phone'] as String? ?? '',
      token: token,
    );
  }
}
