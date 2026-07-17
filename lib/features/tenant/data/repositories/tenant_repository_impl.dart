import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../../domain/usecases/verify_domain.dart';
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
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  final remoteDataSource = ref.watch(tenantRemoteDataSourceProvider);
  return TenantRepositoryImpl(remoteDataSource);
});

final verifyDomainUseCaseProvider = Provider<VerifyDomain>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return VerifyDomain(repository);
});
