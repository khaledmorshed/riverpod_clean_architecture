import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createClient({
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
      final message = await remoteDataSource.createClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        openingBalance: openingBalance,
        creditDueLimit: creditDueLimit,
        partyTypeId: partyTypeId,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
