import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String emailOrPhone, String password);
}

class AuthRemoteDataSourceImpl extends BaseRemoteDataSource implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> signIn(String emailOrPhone, String password) async {
    final dioCall = dioClient.dio.post(
      'login',
      data: {
        'identifier': emailOrPhone,
        'password': password,
      },
    );

    try {
      final response = await callApiWithErrorParser(dioCall);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        final msg = response.data is Map ? response.data['message']?.toString() : null;
        throw ServerException(msg ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});
