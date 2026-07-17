import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/client.dart';
import '../usecases/create_client.dart';

abstract class ClientRepository {
  Future<Either<Failure, List<Client>>> getClients(int page, String search);
  Future<Either<Failure, String>> createClient(CreateClientParams params);
}
