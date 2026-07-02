import '../../domain/entities/tenant.dart';

class TenantModel extends Tenant {
  TenantModel({
    required super.domain,
    required super.companyName,
    required super.companyShortName,
    required super.companyLogo,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json, String domain) {
    final results = json['results'] as Map<String, dynamic>?;
    return TenantModel(
      domain: domain,
      companyName: results?['company_name']?.toString() ?? '',
      companyShortName: results?['company_short_name']?.toString() ?? '',
      companyLogo: results?['company_logo']?.toString() ?? '',
    );
  }
}
