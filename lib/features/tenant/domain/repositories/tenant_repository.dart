import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/tenant.dart';

abstract class TenantRepository {
  Future<Either<Failure, Tenant>> verifyDomain(String domainUrl);
}
