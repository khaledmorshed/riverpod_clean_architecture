import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clean_architecture_flutter/core/providers/core_providers.dart';
import 'package:clean_architecture_flutter/core/storage/local_storage.dart';
import 'package:clean_architecture_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:clean_architecture_flutter/features/auth/domain/usecases/sign_in.dart';
import 'package:clean_architecture_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clean_architecture_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_architecture_flutter/features/auth/domain/entities/user.dart';
import 'package:clean_architecture_flutter/core/error/failures.dart';

class FakeSignIn implements SignIn {
  final Either<Failure, User> response;
  FakeSignIn(this.response);

  @override
  late final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return response;
  }
}

void main() {
  late ProviderContainer container;
  late LocalStorage localStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorage(prefs);
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer makeContainer({required SignIn mockSignIn}) {
    container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
        signInUseCaseProvider.overrideWithValue(mockSignIn),
      ],
    );
    return container;
  }

  test('Initial state is empty and invalid', () {
    final mockSignIn = FakeSignIn(Left(ServerFailure('')));
    final c = makeContainer(mockSignIn: mockSignIn);

    final state = c.read(authNotifierProvider);

    expect(state.emailOrPhone, '');
    expect(state.password, '');
    expect(state.isFormValid, false);
    expect(state.user, null);
  });

  test('Form validation behaves correctly', () {
    final mockSignIn = FakeSignIn(Left(ServerFailure('')));
    final c = makeContainer(mockSignIn: mockSignIn);

    final notifier = c.read(authNotifierProvider.notifier);

    notifier.updateEmailOrPhone('test@example.com');
    expect(c.read(authNotifierProvider).isFormValid, false);

    notifier.updatePassword('12345');
    expect(c.read(authNotifierProvider).isFormValid, false);

    notifier.updatePassword('123456');
    expect(c.read(authNotifierProvider).isFormValid, true);
  });

  test('submitLogin success updates state and saves token', () async {
    final testUser = User(
      id: '1',
      displayName: 'Khaled',
      email: 'test@example.com',
      phone: '123456',
      token: 'jwt_token',
    );

    final mockSignIn = FakeSignIn(Right(testUser));
    final c = makeContainer(mockSignIn: mockSignIn);

    final notifier = c.read(authNotifierProvider.notifier);
    notifier.updateEmailOrPhone('test@example.com');
    notifier.updatePassword('123456');

    await notifier.submitLogin();

    final state = c.read(authNotifierProvider);
    expect(state.user, testUser);
    expect(state.successMessage, 'Welcome back, Khaled!');
    expect(localStorage.getToken(), 'jwt_token');
  });

  test('submitLogin failure sets error message', () async {
    final mockSignIn = FakeSignIn(Left(ServerFailure('Invalid credentials')));
    final c = makeContainer(mockSignIn: mockSignIn);

    final notifier = c.read(authNotifierProvider.notifier);
    notifier.updateEmailOrPhone('test@example.com');
    notifier.updatePassword('123456');

    await notifier.submitLogin();

    final state = c.read(authNotifierProvider);
    expect(state.user, null);
    expect(state.errorMessage, 'Invalid credentials');
    expect(localStorage.getToken(), null);
  });
}
