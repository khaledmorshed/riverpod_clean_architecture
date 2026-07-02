import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/tenant_model.dart';

abstract class TenantRemoteDataSource {
  Future<TenantModel> verifyDomain(String domainUrl);
}

class TenantRemoteDataSourceImpl implements TenantRemoteDataSource {
  final DioClient dioClient;

  TenantRemoteDataSourceImpl(this.dioClient);

  @override
  Future<TenantModel> verifyDomain(String domainUrl) async {
    try {
      final response = await dioClient.dio.post(
        'tenants/verify',
        data: {
          'domain': domainUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TenantModel.fromJson(response.data, domainUrl);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to verify domain');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Server error';
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
