import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String emailOrPhone;
  final String password;

  SignInParams({required this.emailOrPhone, required this.password});
}

class SignIn implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signIn(params.emailOrPhone, params.password);
  }
}
