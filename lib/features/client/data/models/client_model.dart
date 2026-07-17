import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client.dart';

part 'client_model.freezed.dart';

@freezed
abstract class ClientModel with _$ClientModel implements Client {
  const ClientModel._();

  const factory ClientModel({
    required String id,
    required String displayName,
    required String email,
    required String phone,
    required String address,
    required String status,
    required String totalDue,
    required String totalPaid,
    required String currentBalance,
  }) = _ClientModel;

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String? ?? '',
      displayName: json['client'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalDue: json['total_due']?.toString() ?? '0',
      totalPaid: json['total_paid']?.toString() ?? '0',
      currentBalance: json['current_balance']?.toString() ?? '0',
    );
  }
}
