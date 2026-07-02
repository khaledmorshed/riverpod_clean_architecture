import '../../domain/entities/client.dart';

class ClientModel extends Client {
  ClientModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.phone,
    required super.address,
    required super.status,
    required super.totalDue,
    required super.totalPaid,
    required super.currentBalance,
  });

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
