import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/client_model.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients(int page, String search);
  Future<String> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String openingBalance,
    required String creditDueLimit,
    required String partyTypeId,
  });
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final DioClient dioClient;

  ClientRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ClientModel>> getClients(int page, String search) async {
    try {
      final response = await dioClient.dio.get(
        'clients',
        queryParameters: {
          'page': page,
          'search': search,
          'limit': 15,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as Map<String, dynamic>?;
        final data = results?['data'] as List<dynamic>? ?? [];
        return data.map((json) => ClientModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to get clients');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Server error';
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String openingBalance,
    required String creditDueLimit,
    required String partyTypeId,
  }) async {
    try {
      final response = await dioClient.dio.post(
        'clients',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'opening_balance': openingBalance,
          'credit_due_limit': creditDueLimit,
          'party_type_id': partyTypeId,
          'latitude': '0',
          'longitude': '0',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'] ?? 'Client created successfully';
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to create client');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Server error';
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
