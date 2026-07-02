class Client {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String totalDue;
  final String totalPaid;
  final String currentBalance;

  Client({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.totalDue,
    required this.totalPaid,
    required this.currentBalance,
  });
}
