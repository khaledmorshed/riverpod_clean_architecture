import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/base/base_notifier.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthState extends BaseState {
  final User? user;
  final String emailOrPhone;
  final String password;
  final bool isRememberMe;
  final String? emailOrPhoneError;
  final String? passwordError;
  final bool isFormValid;

  const AuthState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.user,
    this.emailOrPhone = '',
    this.password = '',
    this.isRememberMe = false,
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
    String? emailOrPhone,
    String? password,
    bool? isRememberMe,
    String? emailOrPhoneError,
    String? passwordError,
    bool? isFormValid,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      user: user ?? this.user,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      password: password ?? this.password,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      emailOrPhoneError: emailOrPhoneError ?? this.emailOrPhoneError,
      passwordError: passwordError ?? this.passwordError,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class AuthNotifier extends BaseNotifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  void updateEmailOrPhone(String val) {
    state = state.copyWith(emailOrPhone: val);
    _validateForm();
  }

  void updatePassword(String val) {
    state = state.copyWith(password: val);
    _validateForm();
  }

  void toggleRememberMe(bool? val) {
    state = state.copyWith(isRememberMe: val ?? false);
  }

  void _validateForm() {
    final emailOrPhone = state.emailOrPhone;
    final password = state.password;

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
      isFormValid: emailOrPhoneErr == null && passwordErr == null && emailOrPhone.isNotEmpty && password.isNotEmpty,
    );
  }

  Future<void> submitLogin() async {
    if (!state.isFormValid) return;

    final params = SignInParams(
      emailOrPhone: state.emailOrPhone,
      password: state.password,
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
