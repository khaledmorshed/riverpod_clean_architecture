import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tenant.dart';

part 'tenant_model.freezed.dart';

@freezed
abstract class TenantModel with _$TenantModel implements Tenant {
  const TenantModel._();

  const factory TenantModel({
    required String domain,
    required String companyName,
    required String companyShortName,
    required String companyLogo,
  }) = _TenantModel;

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
