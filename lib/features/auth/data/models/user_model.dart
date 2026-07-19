import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';

@freezed
abstract class UserModel with _$UserModel implements User {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String displayName,
    required String email,
    required String phone,
    required String token,
    required String roleId,
    required String warehouseId,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>?;
    final token = results?['access_token'] as String? ?? '';
    final user = results?['user'] as Map<String, dynamic>?;

    final selectedRole = user?['selected_role'] as Map<String, dynamic>?;
    final selectedRoleWarehouse = user?['selected_role_warehouse'] as Map<String, dynamic>?;

    return UserModel(
      id: user?['id'] as String? ?? '',
      displayName: user?['display_name'] as String? ?? '',
      email: user?['email'] as String? ?? '',
      phone: user?['phone'] as String? ?? '',
      token: token,
      roleId: selectedRole?['id'] as String? ?? '',
      warehouseId: selectedRoleWarehouse?['id'] as String? ?? '',
    );
  }
}
