import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/tenant_remote_datasource.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantRemoteDataSource remoteDataSource;

  TenantRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Tenant>> verifyDomain(String domainUrl) async {
    try {
      final tenant = await remoteDataSource.verifyDomain(domainUrl);
      return Right(tenant);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
