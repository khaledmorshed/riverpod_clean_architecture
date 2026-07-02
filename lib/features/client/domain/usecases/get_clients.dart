import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientsParams {
  final int page;
  final String search;

  GetClientsParams({required this.page, this.search = ''});
}

class GetClients implements UseCase<List<Client>, GetClientsParams> {
  final ClientRepository repository;

  GetClients(this.repository);

  @override
  Future<Either<Failure, List<Client>>> call(GetClientsParams params) async {
    return await repository.getClients(params.page, params.search);
  }
}
