import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/client.dart';

abstract class ClientRepository {
  Future<Either<Failure, List<Client>>> getClients(int page, String search);
  Future<Either<Failure, String>> createClient({
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
