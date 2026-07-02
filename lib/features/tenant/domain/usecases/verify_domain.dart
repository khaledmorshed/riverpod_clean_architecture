import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class VerifyDomain implements UseCase<Tenant, String> {
  final TenantRepository repository;

  VerifyDomain(this.repository);

  @override
  Future<Either<Failure, Tenant>> call(String params) async {
    return await repository.verifyDomain(params);
  }
}
