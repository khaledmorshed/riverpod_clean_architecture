import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/create_client.dart';
import '../../domain/usecases/get_clients.dart';
import '../datasources/client_remote_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;

  ClientRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Client>>> getClients(int page, String search) async {
    try {
      final clients = await remoteDataSource.getClients(page, search);
      return Right(clients);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createClient(CreateClientParams params) async {
    try {
      final message = await remoteDataSource.createClient(params);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final remoteDataSource = ref.watch(clientRemoteDataSourceProvider);
  return ClientRepositoryImpl(remoteDataSource);
});

final getClientsUseCaseProvider = Provider<GetClients>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return GetClients(repository);
});

final createClientUseCaseProvider = Provider<CreateClient>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return CreateClient(repository);
});
