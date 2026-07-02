import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/base/base_notifier.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

final signInUseCaseProvider = Provider<SignIn>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignIn(repository);
});

class AuthState extends BaseState {
  final User? user;
  final String? emailOrPhoneError;
  final String? passwordError;
  final bool isFormValid;

  const AuthState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.user,
    this.emailOrPhoneError,
    this.passwordError,
    this.isFormValid = false,
  });

  @override
  AuthState copyWithBase({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    User? user,
    String? emailOrPhoneError,
    String? passwordError,
    bool? isFormValid,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      user: user ?? this.user,
      emailOrPhoneError: emailOrPhoneError ?? this.emailOrPhoneError,
      passwordError: passwordError ?? this.passwordError,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class AuthNotifier extends BaseNotifier<AuthState> {
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRememberMe = false;

  @override
  AuthState build() {
    emailOrPhoneController.addListener(_validateForm);
    passwordController.addListener(_validateForm);

    ref.onDispose(() {
      emailOrPhoneController.dispose();
      passwordController.dispose();
    });

    return AuthState();
  }

  void _validateForm() {
    final emailOrPhone = emailOrPhoneController.text;
    final password = passwordController.text;

    String? emailOrPhoneErr;
    String? passwordErr;

    if (emailOrPhone.isEmpty) {
      emailOrPhoneErr = 'Email or phone number cannot be empty';
    }
    if (password.isEmpty) {
      passwordErr = 'Password cannot be empty';
    } else if (password.length < 6) {
      passwordErr = 'Password must be at least 6 characters';
    }

    state = state.copyWith(
      emailOrPhoneError: emailOrPhoneErr,
      passwordError: passwordErr,
      isFormValid: emailOrPhoneErr == null && passwordErr == null,
    );
  }

  void toggleRememberMe(bool? val) {
    isRememberMe = val ?? false;
  }

  Future<void> submitLogin() async {
    if (!state.isFormValid) return;

    final params = SignInParams(
      emailOrPhone: emailOrPhoneController.text,
      password: passwordController.text,
    );

    final signIn = ref.read(signInUseCaseProvider);

    await executeTask(
      signIn(params),
      onSuccess: (user) {
        ref.read(localStorageProvider).saveToken(user.token);
        state = state.copyWith(user: user, successMessage: 'Welcome back, ${user.displayName}!');
      },
    );
  }
}

final authNotifierProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
