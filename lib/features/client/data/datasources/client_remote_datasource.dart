import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/usecases/create_client.dart';
import '../models/client_model.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients(int page, String search);
  Future<String> createClient(CreateClientParams params);
}

class ClientRemoteDataSourceImpl extends BaseRemoteDataSource implements ClientRemoteDataSource {
  final DioClient dioClient;

  ClientRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ClientModel>> getClients(int page, String search) async {
    final dioCall = dioClient.dio.get(
      'clients',
      queryParameters: {
        'page': page,
        'search': search,
        'limit': 15,
      },
    );

    try {
      final response = await callApiWithErrorParser(dioCall);
      if (response.statusCode == 200) {
        final results = response.data['results'] as Map<String, dynamic>?;
        final data = results?['data'] as List<dynamic>? ?? [];
        return data.map((json) => ClientModel.fromJson(json)).toList();
      } else {
        final msg = response.data is Map ? response.data['message']?.toString() : null;
        throw ServerException(msg ?? 'Failed to get clients');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createClient(CreateClientParams params) async {
    final dioCall = dioClient.dio.post(
      'clients',
      data: {
        'first_name': params.firstName,
        'last_name': params.lastName,
        'email': params.email,
        'phone': params.phone,
        'address': params.address,
        'opening_balance': params.openingBalance,
        'credit_due_limit': params.creditDueLimit,
        'party_type_id': params.partyTypeId,
        'latitude': '0',
        'longitude': '0',
      },
    );

    try {
      final response = await callApiWithErrorParser(dioCall);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg = response.data is Map ? response.data['message']?.toString() : null;
        return msg ?? 'Client created successfully';
      } else {
        final msg = response.data is Map ? response.data['message']?.toString() : null;
        throw ServerException(msg ?? 'Failed to create client');
      }
    } catch (e) {
      rethrow;
    }
  }
}

final clientRemoteDataSourceProvider = Provider<ClientRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ClientRemoteDataSourceImpl(dioClient);
});
