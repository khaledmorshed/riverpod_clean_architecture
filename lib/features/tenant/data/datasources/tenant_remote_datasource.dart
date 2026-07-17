import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/tenant_model.dart';

abstract class TenantRemoteDataSource {
  Future<TenantModel> verifyDomain(String domainUrl);
}

class TenantRemoteDataSourceImpl extends BaseRemoteDataSource implements TenantRemoteDataSource {
  final DioClient dioClient;

  TenantRemoteDataSourceImpl(this.dioClient);

  @override
  Future<TenantModel> verifyDomain(String domainUrl) async {
    final dioCall = dioClient.dio.post(
      'tenants/verify',
      data: {
        'domain': domainUrl,
      },
    );

    try {
      final response = await callApiWithErrorParser(dioCall);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TenantModel.fromJson(response.data, domainUrl);
      } else {
        final msg = response.data is Map ? response.data['message']?.toString() : null;
        throw ServerException(msg ?? 'Failed to verify domain');
      }
    } catch (e) {
      rethrow;
    }
  }
}

final tenantRemoteDataSourceProvider = Provider<TenantRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TenantRemoteDataSourceImpl(dioClient);
});
