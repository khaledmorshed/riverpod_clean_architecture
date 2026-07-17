import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/client_repository.dart';

class CreateClientParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String openingBalance;
  final String creditDueLimit;
  final String partyTypeId;

  CreateClientParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.openingBalance,
    required this.creditDueLimit,
    required this.partyTypeId,
  });
}

class CreateClient implements UseCase<String, CreateClientParams> {
  final ClientRepository repository;

  CreateClient(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateClientParams params) async {
    return await repository.createClient(params);
  }
}
